//
//  ChecklistView.swift
//  vamosPraOndeApp
//
//  Checklist de mala/preparativos de uma viagem.
//

import SwiftUI

struct ChecklistView: View {
    let destination: Destination
    @ObservedObject var repository: DestinationsRepository

    @Environment(\.dismiss) private var dismiss
    @State private var items: [ChecklistItem]
    @State private var newItemTitle = ""

    init(destination: Destination, repository: DestinationsRepository) {
        self.destination = destination
        _repository = ObservedObject(wrappedValue: repository)
        _items = State(initialValue: destination.checklist ?? [])
    }

    var body: some View {
        NavigationStack {
            List {
                if !items.isEmpty {
                    Section {
                        progressHeader
                            .listRowBackground(Color.vpoCream)
                    }
                }

                Section {
                    ForEach($items) { $item in
                        Button {
                            item.isDone.toggle()
                            save()
                        } label: {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(item.isDone ? Color.vpoTeal : Color.vpoInkSoft)
                                Text(item.title)
                                    .font(AppFont.medium(16))
                                    .strikethrough(item.isDone)
                                    .foregroundStyle(item.isDone ? Color.vpoInkSoft : Color.vpoInk)
                            }
                        }
                        .listRowBackground(Color.vpoCream)
                    }
                    .onDelete { offsets in
                        items.remove(atOffsets: offsets)
                        save()
                    }

                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.vpoTerracotta)
                        TextField(
                            "",
                            text: $newItemTitle,
                            prompt: Text("Adicionar item…").foregroundColor(.vpoInkSoft)
                        )
                        .font(AppFont.medium(16))
                        .foregroundStyle(Color.vpoInk)
                        .onSubmit(addItem)
                        .submitLabel(.done)
                    }
                    .listRowBackground(Color.vpoCream)
                } footer: {
                    if items.isEmpty {
                        Text("Comece por um modelo no menu acima, ou adicione os seus próprios itens.")
                            .font(AppFont.body(13))
                            .foregroundStyle(Color.vpoInkSoft)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.vpoSand.ignoresSafeArea())
            .navigationTitle("Mala e preparativos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(ChecklistTemplate.allCases) { template in
                            Button {
                                items = ChecklistTemplate.merge(items, adding: template)
                                save()
                            } label: {
                                Label(template.label, systemImage: template.icon)
                            }
                        }
                    } label: {
                        Label("Modelos", systemImage: "text.badge.plus")
                            .foregroundStyle(Color.vpoTerracotta)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                        .foregroundStyle(Color.vpoTerracotta)
                        .bold()
                }
            }
        }
        .tint(.vpoTerracotta)
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(items.progressPhrase)
                    .font(AppFont.title(16))
                    .foregroundStyle(Color.vpoInk)
                Spacer()
                Text("\(items.doneCount)/\(items.count)")
                    .font(AppFont.countdown(20))
                    .foregroundStyle(Color.vpoTerracotta)
            }
            ProgressView(value: Double(items.doneCount), total: Double(max(items.count, 1)))
                .tint(Color.vpoTerracotta)
        }
        .padding(.vertical, 4)
    }

    private func addItem() {
        let title = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        items.append(ChecklistItem(title: title))
        newItemTitle = ""
        save()
    }

    private func save() {
        var updated = destination
        updated.checklist = items
        Task { try? await repository.update(updated) }
    }
}
