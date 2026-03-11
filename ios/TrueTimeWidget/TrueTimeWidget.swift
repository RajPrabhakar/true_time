import SwiftUI
import WidgetKit

private let appGroupId = "group.com.stellorah.truetime"
private let bgHexKey = "bgHex"
private let textHexKey = "textHex"

struct TrueTimeEntry: TimelineEntry {
    let date: Date
    let backgroundColor: Color
    let textColor: Color
}

struct TrueTimeProvider: TimelineProvider {
    func placeholder(in context: Context) -> TrueTimeEntry {
        TrueTimeEntry(
            date: Date(),
            backgroundColor: .black,
            textColor: .white
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TrueTimeEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TrueTimeEntry>) -> Void) {
        let now = Date()
        let nextMinute = Calendar.current.date(
            byAdding: .minute,
            value: 1,
            to: now
        ) ?? now.addingTimeInterval(60)

        let timeline = Timeline(entries: [loadEntry()], policy: .after(nextMinute))
        completion(timeline)
    }

    private func loadEntry() -> TrueTimeEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let bgHex = defaults?.string(forKey: bgHexKey)
        let textHex = defaults?.string(forKey: textHexKey)

        return TrueTimeEntry(
            date: Date(),
            backgroundColor: Color(hex: bgHex) ?? .black,
            textColor: Color(hex: textHex) ?? .white
        )
    }
}

struct TrueTimeWidgetEntryView: View {
    var entry: TrueTimeProvider.Entry

    var body: some View {
        Text(entry.date, style: .time)
            .font(
                .system(
                    size: 44,
                    weight: .bold,
                    design: .monospaced
                )
            )
            .foregroundColor(entry.textColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(entry.backgroundColor)
            .containerBackground(entry.backgroundColor, for: .widget)
    }
}

struct TrueTimeWidget: Widget {
    let kind: String = "TrueTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrueTimeProvider()) { entry in
            TrueTimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TrueTime")
        .description("Ultra-minimal clock synced with your app theme.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
        ])
    }
}

@main
struct TrueTimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        TrueTimeWidget()
    }
}

private extension Color {
    init?(hex: String?) {
        guard var hex else { return nil }
        hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        guard hex.count == 6, let value = Int(hex, radix: 16) else {
            return nil
        }

        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0

        self = Color(red: red, green: green, blue: blue)
    }
}
