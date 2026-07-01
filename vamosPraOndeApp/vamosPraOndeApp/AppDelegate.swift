//
//  AppDelegate.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 10/11/22.
//
//  Mantido apenas para inicializar o Firebase no ciclo de vida SwiftUI
//  (via @UIApplicationDelegateAdaptor em VamosPraOndeApp).
//

import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
