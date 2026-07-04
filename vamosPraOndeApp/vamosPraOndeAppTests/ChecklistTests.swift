//
//  ChecklistTests.swift
//  vamosPraOndeAppTests
//
//  Testes da checklist: merge de templates e frase de progresso.
//

import Testing
@testable import vamosPraOndeApp

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
