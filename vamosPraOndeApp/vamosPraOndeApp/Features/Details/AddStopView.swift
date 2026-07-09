//
//  AddStopView.swift
//  vamosPraOndeApp
//
//  Adiciona um trecho (parada) a uma viagem: busca de cidade + data opcional
//  (pode ficar sem data — "quero visitar"). Reaproveita a busca de cidade da
//  criação de destino.
//

import SwiftUI

struct AddStopView: View {
    /// Trecho sendo editado (nil = adicionando um novo).
    var editing: TripStop? = nil
    /// Chamado com o trecho pronto quando o usuário confirma.
    let onAdd: (TripStop) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var suggestions: [CitySuggestion] = []
    @State private var selected: CitySuggestion?
    @State private var noDate = false
    @State private var date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var hasEnd: Bool
    @State private var endDate: Date
    @State private var isSearching = false
    @State private var errorMessage: String?

    init(editing: TripStop? = nil, onAdd: @escaping (TripStop) -> Void) {
        self.editing = editing
        self.onAdd = onAdd
        _query = State(initialValue: editing?.name ?? "")
        _selected = State(initialValue: editing.map {
            CitySuggestion(title: $0.name, latitude: $0.latitude, longitude: $0.longitude)
        })
        _noDate = State(initialValue: editing != nil && editing?.startDate == nil)
        let start = editing?.startDate
            ?? Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        _date = State(initialValue: start)
        _hasEnd = State(initialValue: editing?.endDate != nil)
        _endDate = State(initialValue: editing?.endDate
            ?? Calendar.current.date(byAdding: .day, value: 5, to: start) ?? start)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.vpoSand.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        citySection
                        if selected != nil { dateSection }
                        if let errorMessage { ErrorBanner(message: errorMessage) }
                    }
                    .padding(Spacing.lg)
                }
            }
            // A partida padrão acompanha a chegada (+5 dias) enquanto o usuário
            // não ligou o toggle; se a chegada passar da partida, corrige também.
            .onChange(of: date) { _, newDate in
                if !hasEnd || endDate < newDate {
                    endDate = Calendar.current.date(byAdding: .day, value: 5, to: newDate) ?? newDate
                }
            }
            .navigationTitle(editing == nil ? "Adicionar trecho" : "Editar trecho")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.vpoInkSoft)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editing == nil ? "Adicionar" : "Salvar", action: confirm)
                        .bold()
                        .foregroundStyle(selected == nil ? Color.vpoInkSoft : Color.vpoTerracotta)
                        .disabled(selected == nil)
                }
            }
        }
        .tint(.vpoTerracotta)
    }

    private var citySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("qual o próximo destino?")
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
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.vpoTeal)
                    Text(selected.title)
                        .font(AppFont.semibold(15))
                        .foregroundStyle(Color.vpoInk)
                    Spacer()
                    Button {
                        self.selected = nil
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(Color.vpoInkSoft)
                    }
                    .accessibilityLabel("Trocar cidade")
                }
                .padding(Spacing.md)
                .background(Color.vpoTeal.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
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

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("quando?")
                .font(AppFont.overline())
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.vpoInkSoft)

            Toggle(isOn: $noDate.animation(.easeInOut(duration: 0.2))) {
                Text("Ainda não sei a data")
                    .font(AppFont.medium(15))
                    .foregroundStyle(Color.vpoInk)
            }
            .tint(.vpoTerracotta)
            .padding(Spacing.md)
            .background(Color.vpoCream)
            .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))

            if !noDate {
                DatePicker("Data", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(.vpoTerracotta)
                    .padding(Spacing.sm)
                    .background(Color.vpoCream)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))

                Toggle(isOn: $hasEnd.animation(.easeInOut(duration: 0.2))) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Marcar a partida")
                            .font(AppFont.medium(15))
                            .foregroundStyle(Color.vpoInk)
                        Text("quando você segue pro próximo destino ou volta")
                            .font(AppFont.medium(12))
                            .foregroundStyle(Color.vpoInkSoft)
                    }
                }
                .tint(.vpoTerracotta)
                .padding(Spacing.md)
                .background(Color.vpoCream)
                .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))

                if hasEnd {
                    DatePicker("Partida", selection: $endDate, in: date..., displayedComponents: .date)
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

    private func confirm() {
        guard let selected else { return }
        // Ao editar, preserva id e passeios do trecho existente.
        let stop = TripStop(
            id: editing?.id ?? UUID().uuidString,
            name: selected.title,
            latitude: selected.coordinate.latitude,
            longitude: selected.coordinate.longitude,
            startDate: noDate ? nil : date,
            endDate: (noDate || !hasEnd) ? nil : max(endDate, date),
            activities: editing?.activities
        )
        Haptics.success()
        onAdd(stop)
        dismiss()
    }
}
