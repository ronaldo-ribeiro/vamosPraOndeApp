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

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
