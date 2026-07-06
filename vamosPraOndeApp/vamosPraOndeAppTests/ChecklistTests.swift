//
//  ChecklistTests.swift
//  vamosPraOndeAppTests
//
//  Testes da checklist: merge de templates e frase de progresso.
//

import Testing
import CoreLocation
import SwiftUI
@testable import vamosPraOndeApp

@MainActor
struct ShareCardTests {
    @Test func cartaoDeCompartilhamentoRenderiza() {
        let d = Destination(
            id: "x", title: "Lisboa, Lisboa, Portugal",
            latitude: 38.7, longitude: -9.1,
            date: Date().addingTimeInterval(86_400 * 30), createdAt: Date()
        )
        let renderer = ImageRenderer(content: CountdownShareCard(destination: d))
        renderer.scale = 3
        let image = renderer.uiImage
        #expect(image != nil)
        #expect(image?.size.width == 360)
        #expect(image?.size.height == 450)
    }

    @Test func cartaoDeDesejoRenderiza() {
        let d = Destination(
            id: "y", title: "Bali, Indonésia",
            latitude: -8.4, longitude: 115.1,
            date: nil, createdAt: Date()
        )
        let renderer = ImageRenderer(content: CountdownShareCard(destination: d))
        #expect(renderer.uiImage != nil)
    }
}

struct DistanceFormatTests {
    @Test func formataComSeparador() {
        #expect(DistanceFormat.string(meters: 8_320_000) == "8.320 km")
    }

    @Test func arredondaParaKm() {
        #expect(DistanceFormat.string(meters: 1_499) == "1 km")
        #expect(DistanceFormat.string(meters: 1_500) == "2 km")
    }

    @Test func distanciaCurta() {
        #expect(DistanceFormat.short(meters: 350) == "350 m")
        #expect(DistanceFormat.short(meters: 999) == "999 m")
        #expect(DistanceFormat.short(meters: 1_500) == "1,5 km")
    }
}

struct ChecklistTests {
    @Test func mergeAdicionaSemDuplicar() {
        let atual = [ChecklistItem(title: "Passaporte")]
        let result = ChecklistTemplate.merge(atual, adding: .internacional)
        // "Passaporte" já existe → não duplica
        #expect(result.filter { $0.title == "Passaporte" }.count == 1)
        // mas os demais itens do template entram
        #expect(result.count == ChecklistTemplate.internacional.items.count)
    }

    @Test func mergeIgnoraMaiusculas() {
        let atual = [ChecklistItem(title: "protetor solar")]
        let result = ChecklistTemplate.merge(atual, adding: .praia)
        #expect(result.filter { $0.title.lowercased() == "protetor solar" }.count == 1)
    }

    @Test func progresso() {
        var itens = [
            ChecklistItem(title: "A", isDone: true),
            ChecklistItem(title: "B", isDone: false),
        ]
        #expect(itens.doneCount == 1)
        #expect(itens.progressPhrase == "1 de 2 prontos")
        itens[1].isDone = true
        #expect(itens.progressPhrase == "tudo pronto! 🎉")
        #expect([ChecklistItem]().progressPhrase == "toque para montar a checklist")
    }
}
