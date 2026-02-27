import SwiftUI

@main
struct PWHLScheduleApp: App {
    @StateObject private var service = PWHLScheduleService()

    var body: some Scene {
        MenuBarExtra("PWHL", systemImage: "figure.hockey") {
            ScheduleView()
                .environmentObject(service)
        }
        .menuBarExtraStyle(.window)
    }
}
