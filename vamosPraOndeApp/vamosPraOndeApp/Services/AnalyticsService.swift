//
//  AnalyticsService.swift
//  vamosPraOndeApp
//
//  Fachada fininha sobre o Firebase Analytics: eventos com nomes estáveis,
//  sem espalhar imports do Firebase pelas telas.
//

import Foundation
import FirebaseAnalytics

enum Track {
    static func destinationSaved(isWishlist: Bool, isEditing: Bool) {
        Analytics.logEvent("destination_saved", parameters: [
            "is_wishlist": isWishlist ? "true" : "false",
            "is_editing": isEditing ? "true" : "false",
        ])
    }

    static func destinationDeleted() {
        Analytics.logEvent("destination_deleted", parameters: nil)
    }

    static func countdownShared() {
        Analytics.logEvent("countdown_shared", parameters: nil)
    }
}
