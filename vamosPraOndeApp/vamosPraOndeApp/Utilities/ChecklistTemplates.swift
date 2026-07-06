//
//  ChecklistTemplates.swift
//  vamosPraOndeApp
//
//  Modelos prontos de checklist de mala.
//

import Foundation

enum ChecklistTemplate: String, CaseIterable, Identifiable {
    case essenciais = "Essenciais"
    case praia = "Praia"
    case frio = "Frio"
    case internacional = "Internacional"

    var id: String { rawValue }

    /// Nome localizado do modelo, para a UI.
    var label: String {
        switch self {
        case .essenciais: return String(localized: "Essenciais")
        case .praia: return String(localized: "Praia")
        case .frio: return String(localized: "Frio")
        case .internacional: return String(localized: "Internacional")
        }
    }

    var icon: String {
        switch self {
        case .essenciais: return "checklist"
        case .praia: return "sun.max.fill"
        case .frio: return "snowflake"
        case .internacional: return "airplane"
        }
    }

    var items: [String] {
        switch self {
        case .essenciais:
            return [
                String(localized: "Documento de identidade"),
                String(localized: "Carregador do celular"),
                String(localized: "Roupas para os dias de viagem"),
                String(localized: "Escova e pasta de dentes"),
                String(localized: "Desodorante"),
                String(localized: "Remédios de uso pessoal"),
                String(localized: "Fones de ouvido"),
            ]
        case .praia:
            return [
                String(localized: "Protetor solar"),
                String(localized: "Roupa de banho"),
                String(localized: "Chinelo"),
                String(localized: "Óculos de sol"),
                String(localized: "Chapéu ou boné"),
                String(localized: "Toalha de praia"),
            ]
        case .frio:
            return [
                String(localized: "Casaco pesado"),
                String(localized: "Luvas e gorro"),
                String(localized: "Cachecol"),
                String(localized: "Meias quentes"),
                String(localized: "Hidratante e protetor labial"),
            ]
        case .internacional:
            return [
                String(localized: "Passaporte"),
                String(localized: "Seguro viagem"),
                String(localized: "Adaptador de tomada"),
                String(localized: "Moeda estrangeira / cartão internacional"),
                String(localized: "Chip internacional ou eSIM"),
                String(localized: "Cópia dos documentos"),
            ]
        }
    }

    /// Acrescenta os itens do modelo à lista, ignorando títulos que já existem.
    static func merge(_ items: [ChecklistItem], adding template: ChecklistTemplate) -> [ChecklistItem] {
        let existing = Set(items.map { $0.title.lowercased() })
        let novos = template.items
            .filter { !existing.contains($0.lowercased()) }
            .map { ChecklistItem(title: $0) }
        return items + novos
    }
}
