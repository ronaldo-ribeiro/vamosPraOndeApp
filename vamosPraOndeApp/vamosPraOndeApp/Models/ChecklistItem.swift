//
//  ChecklistItem.swift
//  vamosPraOndeApp
//
//  Item da checklist de mala/preparativos de uma viagem.
//

import Foundation

struct ChecklistItem: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var isDone: Bool = false
}

extension Array where Element == ChecklistItem {
    var doneCount: Int { filter(\.isDone).count }

    /// "3 de 10 prontos" (ou "tudo pronto! 🎉" quando completo).
    var progressPhrase: String {
        guard !isEmpty else { return String(localized: "toque para montar a checklist") }
        if doneCount == count { return String(localized: "tudo pronto! 🎉") }
        return String(localized: "\(doneCount) de \(count) prontos")
    }
}
