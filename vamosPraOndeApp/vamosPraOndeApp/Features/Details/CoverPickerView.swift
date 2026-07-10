//
//  CoverPickerView.swift
//  vamosPraOndeApp
//
//  Seletor de capa: o usuário escolhe uma arte do nosso banco de imagens
//  (paleta × cena) ou volta para a capa padrão do destino. A escolha é
//  salva no Firestore (Destination.coverStyle) e reflete na hora.
//  (A opção de foto da galeria entra numa etapa seguinte.)
//

import SwiftUI

struct CoverPickerView: View {
    let destination: Destination
    @ObservedObject var repository: DestinationsRepository

    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    /// Estilo salvo atualmente (nil = padrão).
    private var currentStyle: CoverStyle? {
        (repository.destinations.first { $0.id == destination.id } ?? destination).coverStyle
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Spacing.md) {
                    // Capa padrão (derivada da seed) — remove a escolha manual.
                    thumbnail(style: nil, label: "Padrão", isSelected: currentStyle == nil)

                    ForEach(Array(CoverStyle.bank.enumerated()), id: \.offset) { _, style in
                        thumbnail(style: style, label: nil, isSelected: currentStyle == style)
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Color.vpoSand.ignoresSafeArea())
            .navigationTitle("Trocar capa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluir") { dismiss() }
                        .foregroundStyle(Color.vpoTerracotta)
                        .bold()
                }
            }
        }
        .tint(.vpoTerracotta)
    }

    private func thumbnail(style: CoverStyle?, label: String?, isSelected: Bool) -> some View {
        Button {
            apply(style)
        } label: {
            ProceduralCover(seed: destination.coverSeed, style: style, city: destination.cityName)
                .frame(height: 96)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                .overlay(alignment: .bottomLeading) {
                    if let label {
                        Text(label)
                            .font(AppFont.semibold(12))
                            .foregroundStyle(Color.vpoOnColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.3), in: Capsule())
                            .padding(8)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .strokeBorder(isSelected ? Color.vpoTerracotta : .clear, lineWidth: 3)
                }
                .overlay(alignment: .topTrailing) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.vpoTerracotta, Color.vpoOnColor)
                            .padding(8)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label ?? "Estilo de capa")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private func apply(_ style: CoverStyle?) {
        Haptics.tap()
        guard var updated = repository.destinations.first(where: { $0.id == destination.id }) else { return }
        updated.coverStyle = style
        Task { try? await repository.update(updated) }
    }
}
