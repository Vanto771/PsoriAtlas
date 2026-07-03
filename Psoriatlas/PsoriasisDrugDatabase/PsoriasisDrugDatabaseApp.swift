import SwiftUI

@main
struct PsoriasisDrugDatabaseApp: App {
    @StateObject private var databaseManager = DatabaseManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(databaseManager)
        }
    }
}
