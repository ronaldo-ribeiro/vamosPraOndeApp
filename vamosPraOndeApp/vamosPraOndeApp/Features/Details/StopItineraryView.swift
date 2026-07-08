//
//  StopItineraryView.swift
//  vamosPraOndeApp
//
//  Roteiro leve de um trecho: uma lista simples de passeios (adicionar,
//  marcar como feito, remover). Salvo em TripStop.activities.
//

import SwiftUI

struct StopItineraryView: View {
    let destinationID: String
    let stopID: String
    @ObservedObject var repository: DestinationsRepository

    @Environment(\.dismiss) private var dismiss
    @State private var newTitle = ""
    @State private var showingEdit = false

    private var destination: Destination? {
        repository.destinations.first { $0.id == destinationID }
    }
    private var stop: TripStop? {
        destination?.resolvedStops.first { $0.id == stopID }
    }
    private var activities: [TripActivity] { stop?.activities ?? [] }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(activities) { activity in
                        Button {
                            toggle(activity)
                        } label: {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: activity.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(activity.isDone ? Color.vpoTeal : Color.vpoInkSoft)
                                Text(activity.title)
                                    .font(AppFont.medium(16))
                                    .strikethrough(activity.isDone)
                                    .foregroundStyle(activity.isDone ? Color.vpoInkSoft : Color.vpoInk)
                            }
                        }
                        .listRowBackground(Color.vpoCream)
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { activities[$0].id }
                        mutate { $0.removeAll { ids.contains($0.id) } }
                    }

                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.vpoTerracotta)
                        TextField(
                            "",
                            text: $newTitle,
                            prompt: Text("Adicionar passeio…").foregroundColor(.vpoInkSoft)
                        )
                        .font(AppFont.medium(16))
                        .foregroundStyle(Color.vpoInk)
                        .onSubmit(add)
                        .submitLabel(.done)
                    }
                    .listRowBackground(Color.vpoCream)
                } footer: {
                    if activities.isEmpty {
                        Text("O que fazer neste trecho? Anote os passeios que você não quer perder.")
                            .font(AppFont.body(13))
                            .foregroundStyle(Color.vpoInkSoft)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.vpoSand.ignoresSafeArea())
            .navigationTitle(stop.map { "Passeios · \($0.cityName)" } ?? "Passeios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingEdit = true
                    } label: {
                        Label("Editar trecho", systemImage: "pencil")
                            .foregroundStyle(Color.vpoTerracotta)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                        .foregroundStyle(Color.vpoTerracotta)
                        .bold()
                }
            }
            .sheet(isPresented: $showingEdit) {
                if let stop {
                    AddStopView(editing: stop) { updated in replaceStop(updated) }
                }
            }
        }
        .tint(.vpoTerracotta)
    }

    /// Substitui o trecho (cidade/data editadas), preservando ordem e passeios.
    private func replaceStop(_ updated: TripStop) {
        guard let destination, var stops = destination.stops,
              let idx = stops.firstIndex(where: { $0.id == updated.id }) else { return }
        stops[idx] = updated
        Task { try? await repository.update(destination.settingStops(stops)) }
    }

    private func add() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        mutate { $0.append(TripActivity(title: title)) }
        newTitle = ""
    }

    private func toggle(_ activity: TripActivity) {
        mutate {
            if let i = $0.firstIndex(where: { $0.id == activity.id }) { $0[i].isDone.toggle() }
        }
    }

    /// Aplica uma mudança à lista de passeios do trecho e salva no Firestore.
    private func mutate(_ transform: (inout [TripActivity]) -> Void) {
        guard let destination, var stops = destination.stops,
              let idx = stops.firstIndex(where: { $0.id == stopID }) else { return }
        var acts = stops[idx].activities ?? []
        transform(&acts)
        stops[idx].activities = acts.isEmpty ? nil : acts
        Haptics.tap()
        let updated = destination.settingStops(stops)
        Task { try? await repository.update(updated) }
    }
}
