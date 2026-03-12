import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:true_time/models/local_time_result.dart';
import 'package:true_time/services/time_calculator_service.dart';

/// Manages the state of the TruTime clock.
///
/// Responsibilities:
/// - Request and handle location permissions
/// - Fetch user's GPS longitude
/// - Update Local Mean Time every second
/// - Provide loading and error states to the UI
class TrueTimeProvider extends ChangeNotifier {
  final TimeCalculatorService _timeCalculator = TimeCalculatorService();
  static const String _is24HourModeKey = 'is_24_hour_mode';

  // State properties
  bool _isLoading = true;
  String? _error;
  double? _longitude;
  LocalTimeResult? _currentTimeResult;
  bool _is24HourMode = false;
  Timer? _timer;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get longitude => _longitude;
  LocalTimeResult? get currentTimeResult => _currentTimeResult;
  bool get is24HourMode => _is24HourMode;

  /// Initializes the provider by requesting permissions and fetching location.
  Future<void> initialize({required bool default24HourMode}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load persisted time format, defaulting to the system preference.
      await _load24HourModePreference(default24HourMode);

      // Step 1: Request location permissions
      await _requestLocationPermission();

      // Step 2: Fetch the user's current GPS longitude
      await _fetchLongitude();

      // Step 3: Start the timer to update time every second
      _startTimerUpdates();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _load24HourModePreference(bool default24HourMode) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_is24HourModeKey)) {
      _is24HourMode = prefs.getBool(_is24HourModeKey) ?? default24HourMode;
      return;
    }

    _is24HourMode = default24HourMode;
    await prefs.setBool(_is24HourModeKey, _is24HourMode);
  }

  Future<void> set24HourMode(bool value) async {
    if (_is24HourMode == value) {
      return;
    }

    _is24HourMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_is24HourModeKey, value);
  }

  /// Requests location permission (When In Use).
  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied by user.');
    } else if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission permanently denied. Enable in settings.');
    }
    // If permission is granted (whileInUse or always), proceed
  }

  /// Fetches the user's current GPS longitude.
  Future<void> _fetchLongitude() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _longitude = position.longitude;
  }

  /// Starts a timer that updates TruTime every second.
  void _startTimerUpdates() {
    // Immediate first calculation
    _updateTime();

    // Then set up recurring updates every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });

    _isLoading = false;
    notifyListeners();
  }

  /// Pauses the timer when the app goes to background.
  void pauseTimer() {
    _timer?.cancel();
  }

  /// Resumes the timer when the app comes to foreground.
  void resumeTimer() {
    if (_longitude != null) {
      _startTimerUpdates();
    }
  }

  /// Calculates and updates the current Local Mean Time.
  void _updateTime() {
    if (_longitude == null) return;

    _currentTimeResult = _timeCalculator.calculateLocalMeanTime(_longitude!);
    notifyListeners();
  }

  /// Requests a fresh GPS location update.
  /// Useful if the user wants to re-lock onto a new location.
  Future<void> refreshLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _fetchLongitude();

      // Reset timer and start fresh
      _timer?.cancel();
      _startTimerUpdates();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cleans up resources (especially the timer).
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
