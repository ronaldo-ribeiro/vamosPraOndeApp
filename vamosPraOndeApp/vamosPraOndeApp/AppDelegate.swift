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
        // Cache generoso para as fotos dos destinos (Unsplash/Wikipedia):
        // 50 MB em memória + 200 MB em disco. AsyncImage usa a URLSession
        // compartilhada, então se beneficia automaticamente.
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024
        )
        // Ativar aqui (e não só na UI) garante que toggles de checklist
        // vindos do relógio cheguem mesmo com o app relançado em background.
        WatchSyncService.shared.activate()
        return true
    }
}
