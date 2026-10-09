//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// Root view: owns the theme and navigation, shows the top-level screens in a native tab bar and the record page above it.
struct ContentView: View {
    var syncError: Binding<(any Error)?> = .constant(nil)

    @State private var themeManager = ThemeManager()
    @Environment(\.modelContext) private var modelContext

    @State private var navigation = NavigationState()
    @State private var isKeyboardVisible = false

    var body: some View {
        ZStack {
            tabs
                .accessibilityHidden(navigation.screen == .record)

            if navigation.screen == .record {
                // MARK: - Record Input
                recordPage
                    .transition(.opacity)
            }
        }
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
        .environment(themeManager)
        .preferredColorScheme(themeManager.isDark ? .dark : .light)
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

    // Insights' nested pages and the keyboard hide the tab bar, as the floating toolbar used to do.
    var isTabBarVisible: Bool { navigation.showsToolbar && !isKeyboardVisible }

    var tabs: some View {
        TabView(selection: tabSelection) {
            Tab(value: Screen.home) {
                tabPage { homeContent }
            } label: {
                Label(LocalizedStringResource("Home"), systemImage: "house.fill")
            }
            .accessibilityIdentifier(navigation.isHomeActive() ? "HomeButton_Active" : "HomeButton_Inactive")

            Tab(value: Screen.insights) {
                tabPage {
                    InsightsView(isShowingAllJoys: $navigation.isShowingAllJoys, isShowingTrends: $navigation.isShowingTrends)
                }
            } label: {
                Label(LocalizedStringResource("Insights"), systemImage: "chart.pie.fill")
            }
            .accessibilityIdentifier(navigation.isInsightsActive ? "InsightsButton_Active" : "InsightsButton_Inactive")

            Tab(value: Screen.settings) {
                tabPage { SettingsView() }
            } label: {
                Label(LocalizedStringResource("Settings"), systemImage: "gearshape.fill")
            }
            .accessibilityIdentifier(navigation.isSettingsActive ? "SettingsButton_Active" : "SettingsButton_Inactive")

            // A detached tab becomes its own round button, the place the record button used to have.
            // It is an action rather than a page, so it never stays selected (see `tabSelection`).
            Tab(value: Screen.record, role: recordTabRole) {
                Color.clear
            } label: {
                Label(LocalizedStringResource("New Joy"), systemImage: "plus")
            }
            .accessibilityIdentifier("MainRecordButton")
        }
        .tint(themeManager.currentTheme.textColor)
        .toolbar(isTabBarVisible ? .visible : .hidden, for: .tabBar)
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
    // returning the tab it was opened from, so the tab bar snaps back to it.
    var tabSelection: Binding<Screen> {
        Binding(
            get: { navigation.selectedTab },
            set: { screen in
                withAnimation(.lummiSpring) {
                    navigation.navigate(to: screen)
                }
            }
        )
    }

    // Each tab paints its own background: the TabView would otherwise put its opaque system backdrop behind it.
    func tabPage<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(themeManager.currentTheme.bgGradient.ignoresSafeArea())
    }

    var recordPage: some View {
        RecordInput(
            recordDate: navigation.recordDate(),
            onDismiss: {
                withAnimation(.lummiSpring) {
                    navigation.closeRecord()
                }
            }
        )
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(themeManager.currentTheme.bgGradient.ignoresSafeArea())
    }

    // MARK: - Home tab

    var homeContent: some View {
        ZStack(alignment: .top) {
            if navigation.isCalendarExpanded {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.lummiSpring) {
                            navigation.dismissCalendar()
                        }
                    }
            }

            VStack(spacing: 15) {
                // MARK: - Header View
                HeaderView(
                    date: navigation.isCalendarExpanded ? navigation.visibleMonth : navigation.selectedDate,
                    isExpanded: navigation.isCalendarExpanded,
                    onTap: {
                        withAnimation(.lummiSpring) {
                            navigation.toggleCalendar()
                        }
                    }
                )

                if navigation.isCalendarExpanded {
                    // MARK: - Calendar View
                    MainCalendarView(
                        selectedDate: $navigation.selectedDate,
                        isCalendarExpanded: $navigation.isCalendarExpanded,
                        visibleMonth: $navigation.visibleMonth
                    )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 18)
                    .frame(maxWidth: AdaptiveLayout.isPad ? 420 : .infinity)
                    .frame(height: 340)
                    .adaptiveGlass(in: RoundedRectangle(cornerRadius: 24))
                    .transition(.opacity)
                    .padding(.top, 28)
                    .padding(.horizontal, 20)
                    .onTapGesture { }
                } else {
                    // MARK: - Selected Day View
                    SelectedDayDetailView(
                        selectedDate: navigation.selectedDate
                    )
                    .transition(.opacity)
                }

                Spacer()
            }
            // Lets the day's entries scroll under the tab bar, as Insights and All Joys do.
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .modelContainer(PreviewSupport.makeContainer())
}
#endif
