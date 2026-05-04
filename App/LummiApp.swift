import SwiftUI
import SwiftData


@main
struct LummiApp: App {
    
    @AppStorage("appLanguage") private var selectedLanguage: AppLanguage = .english
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([JoyEntry.self])

        let isUITesting = ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("-UI_TESTING") })
        
        // If these are tests, the database lives only in RAM
        // If it's a standart launch, the database is saved to the hard drive
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: selectedLanguage.rawValue))
        }
        .modelContainer(sharedModelContainer)
    }
}
