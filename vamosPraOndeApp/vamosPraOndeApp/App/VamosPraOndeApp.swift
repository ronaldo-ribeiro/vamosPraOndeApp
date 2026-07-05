//
//  VamosPraOndeApp.swift
//  vamosPraOndeApp
//
//  Ponto de entrada SwiftUI. O AppDelegate é mantido apenas
//  para inicializar o Firebase.
//

import SwiftUI
import GoogleSignIn

@main
struct VamosPraOndeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var auth = AuthService()
    @StateObject private var userLocation = UserLocationProvider()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(userLocation)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
