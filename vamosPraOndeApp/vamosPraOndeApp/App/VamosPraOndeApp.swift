//
//  VamosPraOndeApp.swift
//  vamosPraOndeApp
//
//  Ponto de entrada SwiftUI. O AppDelegate é mantido apenas
//  para inicializar o Firebase.
//

import SwiftUI

@main
struct VamosPraOndeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var auth = AuthService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
        }
    }
}
