//
//  DestinationDetailView.swift
//  vamosPraOndeApp
//
//  Detalhes de um destino: capa, contagem regressiva, mapa e excluir.
//

import SwiftUI
import MapKit

struct DestinationDetailView: View {
    let destination: Destination
    @ObservedObject var repository: DestinationsRepository

    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirm = false
    @State private var isDeleting = false

    private var countdown: Countdown { Countdown(to: destination.date) }

    var body: some View {
        ZStack {
            Color.vpoSand.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    cover
                    countdownBlock
                    mapCard
                    weatherPlaceholder
                    deleteButton
                }
                .padding(.bottom, Spacing.xl)
            }
            .ignoresSafeArea(edges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(
            "Excluir este destino?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Excluir", role: .destructive, action: delete)
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Você deixará de contar os dias para \(destination.cityName).")
        }
    }

    private var cover: some View {
        SunsetCover()
            .frame(height: 300)
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("o seu destino")
                        .font(AppFont.overline(11))
                        .kerning(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(Color(hex: 0xFBE9C6))
                    Text(destination.cityName)
                        .font(AppFont.display(44))
                        .foregroundStyle(Color.vpoCream)
                    if !destination.subtitle.isEmpty {
                        Text(destination.subtitle)
                            .font(AppFont.medium(14))
                            .foregroundStyle(Color.vpoCream.opacity(0.9))
                    }
                }
                .padding(Spacing.lg)
            }
            .overlay(alignment: .topLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.vpoCream)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(.leading, Spacing.lg)
                .padding(.top, 56)
            }
    }

    private var countdownBlock: some View {
        VStack(spacing: 2) {
            Text(countdown.isPast ? "essa viagem já rolou" : "faltam")
                .font(AppFont.overline())
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.vpoInkSoft)
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(countdown.value)
                    .font(AppFont.countdown(60))
                    .foregroundStyle(Color.vpoTerracotta)
                if !countdown.unit.isEmpty {
                    Text(countdown.unit)
                        .font(AppFont.semibold(20))
                        .foregroundStyle(Color.vpoInk)
                }
            }
            Text(DateStyle.long.string(from: destination.date))
                .font(AppFont.medium(14))
                .foregroundStyle(Color.vpoInkSoft)
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var mapCard: some View {
        Map(initialPosition: .region(
            MKCoordinateRegion(
                center: destination.coordinate,
                latitudinalMeters: 4000,
                longitudinalMeters: 4000
            )
        )) {
            Marker(destination.cityName, coordinate: destination.coordinate)
                .tint(Color.vpoTerracotta)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .allowsHitTesting(false)
        .padding(.horizontal, Spacing.lg)
    }

    private var weatherPlaceholder: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 26))
                .foregroundStyle(Color.vpoCream)
                .frame(width: 52, height: 52)
                .background(Color.vpoTeal)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text("Clima do destino")
                    .font(AppFont.title(16))
                    .foregroundStyle(Color.vpoInk)
                Text("em breve por aqui")
                    .font(AppFont.medium(13))
                    .foregroundStyle(Color.vpoInkSoft)
            }
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .padding(.horizontal, Spacing.lg)
    }

    private var deleteButton: some View {
        Button {
            showingDeleteConfirm = true
        } label: {
            if isDeleting {
                ProgressView().tint(.vpoTerracotta)
            } else {
                Label("Excluir destino", systemImage: "trash")
            }
        }
        .buttonStyle(OutlineButtonStyle())
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
    }

    private func delete() {
        isDeleting = true
        Task {
            try? await repository.delete(destination)
            dismiss()
        }
    }
}
