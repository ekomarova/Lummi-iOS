//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// Root view: owns the theme and navigation, shows the top-level screens in a native tab bar. Each tab has its own
// `NavigationStack`, and the record page is pushed onto the current one, so the system swipe-back gesture works.
struct ContentView: View {
    var syncError: Binding<(any Error)?> = .constant(nil)

    @State private var themeManager = ThemeManager()
    @Environment(\.modelContext) private var modelContext

    @State private var navigation = NavigationState()
    @State private var isKeyboardVisible = false

    var body: some View {
        tabs
        .alert(
            "iCloud Sync Error",
            isPresented: Binding(
                get: { syncError.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented { syncError.wrappedValue = nil }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                syncError.wrappedValue = nil
            }
        } message: {
            Text(syncError.wrappedValue?.localizedDescription ?? "")
        }

        // Listenen to system keyboard notifications
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeOut(duration: 0.2)) {
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.2)) {
                isKeyboardVisible = false
            }
        }
        .appTheme(themeManager)
        // MARK: For tests only
        .onAppear {
#if DEBUG
            MockDataManager.injectIfNeeded(modelContext: modelContext)
#endif
        }
    }
}

private extension ContentView {
    // MARK: - Native tab bar

    var tabs: some View {
        TabView(selection: tabSelection) {
            Tab(value: Screen.home) {
                tabStack(for: .home) { homeContent }
            } label: {
                Label(LocalizedStringResource("Home"), systemImage: "house.fill")
            }
            .accessibilityIdentifier(navigation.isHomeActive() ? "HomeButton_Active" : "HomeButton_Inactive")

            Tab(value: Screen.insights) {
                tabStack(for: .insights) {
                    InsightsView(onNavigate: { navigation.push($0) })
                }
            } label: {
                Label(LocalizedStringResource("Insights"), systemImage: "chart.pie.fill")
            }
            .accessibilityIdentifier(navigation.isInsightsActive ? "InsightsButton_Active" : "InsightsButton_Inactive")

            Tab(value: Screen.settings) {
                tabStack(for: .settings) {
                    SettingsView(onNavigate: { navigation.push($0) })
                }
            } label: {
                Label(LocalizedStringResource("Settings"), systemImage: "gearshape.fill")
            }
            .accessibilityIdentifier(navigation.isSettingsActive ? "SettingsButton_Active" : "SettingsButton_Inactive")

            // A detached tab becomes its own round button, the place the record button used to have.
            // It is an action rather than a page, so it never stays selected (see `tabSelection`).
            Tab(value: Screen.record, role: recordTabRole) {
                Color.clear
            } label: {
                Label(LocalizedStringResource("New Joy"), systemImage: "pencil")
            }
            .accessibilityIdentifier("MainRecordButton")
        }
        // Tab bar only, with no iPad sidebar. On iOS 18 and 26 an open sidebar is lost for good when a pushed page hides the
        // tab bar and the user goes back (Issue: FB25190777). On iOS 27 the left edge belongs to the sidebar, so the swipe-back
        // gesture does not work there.
        .tabViewStyle(.tabBarOnly)
        .tint(themeManager.currentTheme.selectedTabColor)
    }

    // The role that detaches the record tab from the bar. Up to iOS 26 that is `.search`; on iOS 27 `.search` stays
    // inline in the bar and the detached button belongs to `.prominent`. The compiler check keeps Xcode 26 building.
    var recordTabRole: TabRole {
#if compiler(>=6.4)
        if #available(iOS 27, *) { return .prominent }
#endif
        return .search
    }

    // A tab's `set` runs on every tap, including a tap on the tab that is already selected, so tapping Home again
    // returns to today just as the old toolbar did. Record is never written back as the selection: the getter keeps
    // returning the current tab, so the tab bar snaps back to it while the record page is pushed.
    var tabSelection: Binding<Screen> {
        Binding(
            get: { navigation.screen },
            set: { screen in
                if screen == .record {
                    // Pushed once the tab bar has snapped back to the current tab. Pushing during the tap leaves the
                    // tab bar hidden after the page is closed.
                    Task { @MainActor in navigation.navigate(to: .record) }
                } else {
                    withAnimation(.lummiSpring) {
                        navigation.navigate(to: screen)
                    }
                }
            }
        )
    }

    // Each tab has its own stack. Its root page keeps the theme's text color for the tab bar's tint and paints its own
    // background: the TabView would otherwise put its opaque system backdrop behind it. The root draws its own title,
    // so the navigation bar only appears on pushed pages.
    func tabStack<Root: View>(for tab: Screen, @ViewBuilder root: () -> Root) -> some View {
        NavigationStack(path: pathBinding(for: tab)) {
            root()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                .toolbar(.hidden, for: .navigationBar)
                // Pushed pages and the keyboard hide the tab bar, as the floating toolbar used to do.
                .toolbar(isTabBarVisible(for: tab) ? .visible : .hidden, for: .tabBar)
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                        .pageBackground()
                        // Set again on the page itself: on iOS 26 the UIKit bar item hosts that build the toolbar items
                        // evaluate the page's own view and may not get the environment set at the root (a crash). 
                        // Issue: FB25190661.
                        .environment(themeManager)
                }
        }
        // The tab bar's tint would cascade into the pages, which keep the theme's text color.
        .tint(themeManager.currentTheme.textColor)
    }

    func isTabBarVisible(for tab: Screen) -> Bool {
        !(navigation.paths[tab]?.last?.hidesTabBar ?? false) && !isKeyboardVisible
    }

    func pathBinding(for tab: Screen) -> Binding<[Route]> {
        Binding(
            get: { navigation.paths[tab] ?? [] },
            set: { navigation.paths[tab] = $0 }
        )
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .allJoys:
            AllJoysView(onOpenYear: { navigation.push(.joysYear($0)) })
        case .trends:
            TrendsView(onOpenYear: { navigation.push(.trendsYear($0)) })
        case .joysYear(let year):
            YearJoysView(year: year)
        case .trendsYear(let year):
            YearTrendsView(year: year)
        case .language:
            LanguageSelectionView()
        case .record:
            RecordInput(recordDate: navigation.recordDate())
        }
    }

    // MARK: - Home tab

    var homeContent: some View {
        // The title's protected zone takes 12pt of the old 20pt gap (see `scrollHeaderBackground`), as on Insights and Settings.
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Header View
            HeaderView(date: navigation.selectedDate)
                .scrollHeaderBackground(alignment: .leading)

            // MARK: - Selected Day View
            SelectedDayDetailView(
                selectedDate: navigation.selectedDate
            )

            Spacer()
        }
        // Lets the day's entries scroll under the tab bar, as Insights and All Joys do.
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#if DEBUG
#Preview {
    ContentView()
        .modelContainer(PreviewSupport.makeContainer())
}
#endif
