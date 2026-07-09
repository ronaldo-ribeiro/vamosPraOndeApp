//
//  NewDestinationView.swift
//  vamosPraOndeApp
//
//  Cadastro ou edição de um destino: cidade, data e anotações.
//

import SwiftUI

struct NewDestinationView: View {
    @ObservedObject var repository: DestinationsRepository
    let editing: Destination?

    @Environment(\.dismiss) private var dismiss

    @State private var query: String
    @State private var suggestions: [CitySuggestion] = []
    @State private var selected: CitySuggestion?
    @State private var date: Date
    @State private var noDate: Bool
    @State private var hasReturn: Bool
    @State private var returnDate: Date
    @State private var notes: String
    @State private var isSearching = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(repository: DestinationsRepository, editing: Destination? = nil) {
        _repository = ObservedObject(wrappedValue: repository)
        self.editing = editing
        _query = State(initialValue: editing?.title ?? "")
        _selected = State(initialValue: editing.map {
            CitySuggestion(title: $0.title, latitude: $0.latitude, longitude: $0.longitude)
        })
        let start = editing?.date
            ?? Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        _date = State(initialValue: start)
        _noDate = State(initialValue: editing != nil && editing?.date == nil)
        _hasReturn = State(initialValue: editing?.endDate != nil)
        _returnDate = State(initialValue: editing?.endDate
            ?? Calendar.current.date(byAdding: .day, value: 7, to: start) ?? start)
        _notes = State(initialValue: editing?.notes ?? "")
    }

    private var isEditing: Bool { editing != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.vpoSand.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        citySection
                        if selected != nil {
                            dateSection
                            notesSection
                        }
                        if let errorMessage {
                            ErrorBanner(message: errorMessage)
                        }
                    }
                    .padding(Spacing.lg)
                }
            }
            // A volta padrão acompanha a ida (ida + 7 dias) enquanto o usuário
            // não ligou o toggle; se a ida passar da volta, corrige também.
            .onChange(of: date) { _, newDate in
                if !hasReturn || returnDate < newDate {
                    returnDate = Calendar.current.date(byAdding: .day, value: 7, to: newDate) ?? newDate
                }
            }
            .navigationTitle(isEditing ? "Editar destino" : "Novo destino")
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
            // Sugestões enquanto digita: espera uma pausa curta e busca sozinho.
            .task(id: query) {
                let text = query.trimmingCharacters(in: .whitespaces)
                guard text.count >= 3, text != selected?.title else { return }
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }
                isSearching = true
                suggestions = await LocationService.search(text)
                isSearching = false
            }

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
            .accessibilityLabel("Trocar cidade")
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

            Toggle(isOn: $noDate.animation(.easeInOut(duration: 0.2))) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ainda não sei a data")
                        .font(AppFont.medium(15))
                        .foregroundStyle(Color.vpoInk)
                    Text("guardar como “quero visitar”")
                        .font(AppFont.medium(12))
                        .foregroundStyle(Color.vpoInkSoft)
                }
            }
            .tint(.vpoTerracotta)
            .padding(Spacing.md)
            .background(Color.vpoCream)
            .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))

            if !noDate {
                DatePicker(
                    "Data da viagem",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.vpoTerracotta)
                .padding(Spacing.sm)
                .background(Color.vpoCream)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))

                Toggle(isOn: $hasReturn.animation(.easeInOut(duration: 0.2))) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Marcar a volta")
                            .font(AppFont.medium(15))
                            .foregroundStyle(Color.vpoInk)
                        Text("quando você volta pra casa ou segue viagem")
                            .font(AppFont.medium(12))
                            .foregroundStyle(Color.vpoInkSoft)
                    }
                }
                .tint(.vpoTerracotta)
                .padding(Spacing.md)
                .background(Color.vpoCream)
                .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))

                if hasReturn {
                    DatePicker(
                        "Data da volta",
                        selection: $returnDate,
                        in: date...,
                        displayedComponents: .date
                    )
                    .font(AppFont.medium(15))
                    .foregroundStyle(Color.vpoInk)
                    .tint(.vpoTerracotta)
                    .padding(Spacing.md)
                    .background(Color.vpoCream)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("anotações")
                .font(AppFont.overline())
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.vpoInkSoft)

            TextField(
                "",
                text: $notes,
                prompt: Text("O que levar, planos, ideias…").foregroundColor(.vpoInkSoft),
                axis: .vertical
            )
            .font(AppFont.medium(16))
            .foregroundStyle(Color.vpoInk)
            .lineLimit(3...8)
            .padding(Spacing.md)
            .background(Color.vpoCream)
            .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
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

    private var trimmedNotes: String? {
        let text = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private func save() {
        guard let selected else { return }
        isSaving = true
        errorMessage = nil
        let finalDate: Date? = noDate ? nil : date
        let finalEnd: Date? = (noDate || !hasReturn) ? nil : max(returnDate, date)
        Task {
            do {
                if finalDate != nil {
                    await NotificationService.requestAuthorization()
                }
                if var existing = editing {
                    existing.title = selected.title
                    existing.latitude = selected.coordinate.latitude
                    existing.longitude = selected.coordinate.longitude
                    existing.date = finalDate
                    existing.endDate = finalEnd
                    existing.notes = trimmedNotes
                    try await repository.update(existing)
                    await NotificationService.reschedule(for: existing)
                } else {
                    let saved = try await repository.add(
                        title: selected.title,
                        coordinate: selected.coordinate,
                        date: finalDate,
                        endDate: finalEnd,
                        notes: trimmedNotes
                    )
                    await NotificationService.reschedule(for: saved)
                }
                Track.destinationSaved(isWishlist: finalDate == nil, isEditing: isEditing)
                Haptics.success()
                dismiss()
            } catch {
                errorMessage = "Não foi possível salvar. Tente novamente."
                isSaving = false
            }
        }
    }
}
