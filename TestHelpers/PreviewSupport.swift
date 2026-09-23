#if DEBUG
import SwiftUI
import SwiftData

// In-memory data and environment for SwiftUI previews. Never touches real user data.
enum PreviewSupport {
    @MainActor
    static func makeContainer(withSampleEntries: Bool = true) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        guard let container = try? ModelContainer(for: JoyEntry.self, configurations: configuration) else {
            preconditionFailure("Could not create the in-memory preview container")
        }
        guard withSampleEntries else { return container }

        let calendar = Calendar.current
        let now = Date()
        let samples: [(String, Int)] = [
            ("Coffee on the balcony", 0),
            ("A long walk with music", 0),
            ("Called an old friend", -1),
            ("Found a great book", -3),
            ("Sunset over the river", -40)
        ]
        for (text, dayOffset) in samples {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: now) ?? now
            container.mainContext.insert(JoyEntry(text: text, date: date))
        }
        return container
    }
}

// Reads the theme from the environment, so the background follows theme switches made inside a preview.
private struct PreviewThemeBackground: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        themeManager.currentTheme.bgGradient.ignoresSafeArea()
    }
}

extension View {
    // Injects the theme manager, the theme background and an in-memory container with sample entries.
    // Views draw on top of the app background, so without it their light text would be invisible.
    // `isDark` forces the starting theme, useful for previews that compare light and dark side by side.
    @MainActor
    func previewEnvironment(withSampleEntries: Bool = true, isDark: Bool = true) -> some View {
        let manager = ThemeManager()
        manager.isDark = isDark
        return ZStack {
            PreviewThemeBackground()
            self
        }
        .environment(manager)
        .modelContainer(PreviewSupport.makeContainer(withSampleEntries: withSampleEntries))
    }
}
#endif
