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
        guard !isEmpty else { return "toque para montar a checklist" }
        if doneCount == count { return "tudo pronto! 🎉" }
        return "\(doneCount) de \(count) prontos"
    }
}
