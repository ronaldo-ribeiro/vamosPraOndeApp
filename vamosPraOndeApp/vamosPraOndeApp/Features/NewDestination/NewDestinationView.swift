//
//  NewDestinationView.swift
//  vamosPraOndeApp
//
//  Cadastro de um novo destino: busca a cidade e escolhe a data da viagem.
//

import SwiftUI

struct NewDestinationView: View {
    @ObservedObject var repository: DestinationsRepository
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var suggestions: [CitySuggestion] = []
    @State private var selected: CitySuggestion?
    @State private var date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var isSearching = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.vpoSand.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        citySection
                        if selected != nil {
                            dateSection
                        }
                        if let errorMessage {
                            ErrorBanner(message: errorMessage)
                        }
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationTitle("Novo destino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.vpoInkSoft)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save) {
                        if isSaving { ProgressView() } else { Text("Salvar").bold() }
                    }
                    .foregroundStyle(selected == nil ? Color.vpoInkSoft : Color.vpoTerracotta)
                    .disabled(selected == nil || isSaving)
                }
            }
        }
        .tint(.vpoTerracotta)
    }

    private var citySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("para onde?")
                .font(AppFont.overline())
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.vpoInkSoft)

            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass").foregroundStyle(Color.vpoInkSoft)
                TextField("", text: $query, prompt: Text("Buscar cidade").foregroundColor(.vpoInkSoft))
                    .font(AppFont.medium(16))
                    .foregroundStyle(Color.vpoInk)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit(runSearch)
                if isSearching { ProgressView() }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 14)
            .background(Color.vpoCream)
            .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))

            if let selected {
                selectedChip(selected)
            } else {
                ForEach(suggestions) { suggestion in
                    Button { choose(suggestion) } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "mappin.circle.fill").foregroundStyle(Color.vpoTeal)
                            Text(suggestion.title)
                                .font(AppFont.medium(15))
                                .foregroundStyle(Color.vpoInk)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                    Divider()
                }
            }
        }
    }

    private func selectedChip(_ suggestion: CitySuggestion) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.vpoTeal)
            Text(suggestion.title)
                .font(AppFont.semibold(15))
                .foregroundStyle(Color.vpoInk)
            Spacer()
            Button {
                selected = nil
                query = ""
            } label: {
                Image(systemName: "xmark.circle.fill").foregroundStyle(Color.vpoInkSoft)
            }
        }
        .padding(Spacing.md)
        .background(Color.vpoTeal.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("quando?")
                .font(AppFont.overline())
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.vpoInkSoft)

            DatePicker(
                "Data da viagem",
                selection: $date,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(.vpoTerracotta)
            .padding(Spacing.sm)
            .background(Color.vpoCream)
            .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        }
    }

    private func runSearch() {
        let text = query.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        isSearching = true
        errorMessage = nil
        Task {
            let results = await LocationService.search(text)
            suggestions = results
            isSearching = false
            if results.isEmpty {
                errorMessage = "Não encontramos essa cidade. Tente outro nome."
            }
        }
    }

    private func choose(_ suggestion: CitySuggestion) {
        selected = suggestion
        suggestions = []
        query = suggestion.title
        errorMessage = nil
    }

    private func save() {
        guard let selected else { return }
        isSaving = true
        errorMessage = nil
        Task {
            do {
                try await repository.add(
                    title: selected.title,
                    coordinate: selected.coordinate,
                    date: date
                )
                dismiss()
            } catch {
                errorMessage = "Não foi possível salvar. Tente novamente."
                isSaving = false
            }
        }
    }
}
