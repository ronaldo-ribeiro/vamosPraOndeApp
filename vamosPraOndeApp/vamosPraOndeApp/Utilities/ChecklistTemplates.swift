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
                "Documento de identidade",
                "Carregador do celular",
                "Roupas para os dias de viagem",
                "Escova e pasta de dentes",
                "Desodorante",
                "Remédios de uso pessoal",
                "Fones de ouvido",
            ]
        case .praia:
            return [
                "Protetor solar",
                "Roupa de banho",
                "Chinelo",
                "Óculos de sol",
                "Chapéu ou boné",
                "Toalha de praia",
            ]
        case .frio:
            return [
                "Casaco pesado",
                "Luvas e gorro",
                "Cachecol",
                "Meias quentes",
                "Hidratante e protetor labial",
            ]
        case .internacional:
            return [
                "Passaporte",
                "Seguro viagem",
                "Adaptador de tomada",
                "Moeda estrangeira / cartão internacional",
                "Chip internacional ou eSIM",
                "Cópia dos documentos",
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
