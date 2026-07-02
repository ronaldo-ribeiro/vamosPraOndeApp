//
//  DestinationDetailView.swift
//  vamosPraOndeApp
//
//  Detalhes de um destino: capa, contagem regressiva, mapa e excluir.
//

import SwiftUI
import MapKit

struct DestinationDetailView: View {
    private let initial: Destination
    @ObservedObject var repository: DestinationsRepository

    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirm = false
    @State private var showingEdit = false
    @State private var isDeleting = false
    @State private var weather: DestinationWeather?
    @State private var weatherFailed = false

    init(destination: Destination, repository: DestinationsRepository) {
        self.initial = destination
        _repository = ObservedObject(wrappedValue: repository)
    }

    /// Destino "vivo": reflete edições feitas em tempo real (via listener).
    private var destination: Destination {
        repository.destinations.first { $0.id == initial.id } ?? initial
    }

    private var countdown: Countdown { Countdown(to: destination.date) }

    var body: some View {
        ZStack {
            Color.vpoSand.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    cover
                    countdownBlock
                    mapCard
                    if let notes = destination.notes, !notes.isEmpty {
                        notesCard(notes)
                    }
                    weatherCard
                    deleteButton
                }
                .padding(.bottom, Spacing.xl)
            }
            .ignoresSafeArea(edges: .top)
        }
        .task(id: destination.id) { await loadWeather() }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingEdit) {
            NewDestinationView(repository: repository, editing: destination)
        }
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
                        .foregroundStyle(Color.vpoOnColor)
                    if !destination.subtitle.isEmpty {
                        Text(destination.subtitle)
                            .font(AppFont.medium(14))
                            .foregroundStyle(Color.vpoOnColor.opacity(0.9))
                    }
                }
                .padding(Spacing.lg)
            }
            .overlay(alignment: .topLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.vpoOnColor)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Voltar")
                .padding(.leading, Spacing.lg)
                .padding(.top, 56)
            }
            .overlay(alignment: .topTrailing) {
                Button { showingEdit = true } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.vpoOnColor)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Editar destino")
                .padding(.trailing, Spacing.lg)
                .padding(.top, 56)
            }
    }

    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("Anotações", systemImage: "note.text")
                .font(AppFont.title(16))
                .foregroundStyle(Color.vpoInk)
            Text(notes)
                .font(AppFont.body(15))
                .foregroundStyle(Color.vpoInkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.md)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .padding(.horizontal, Spacing.lg)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(countdown.phrase), em \(DateStyle.long.string(from: destination.date)).")
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Mapa de \(destination.cityName)")
        .padding(.horizontal, Spacing.lg)
    }

    private var weatherCard: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: weather?.symbolName ?? "cloud.sun.fill")
                .font(.system(size: 26))
                .foregroundStyle(Color.vpoOnColor)
                .frame(width: 52, height: 52)
                .background(Color.vpoTeal)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("Clima agora")
                    .font(AppFont.title(16))
                    .foregroundStyle(Color.vpoInk)
                if let weather {
                    Text(weather.description)
                        .font(AppFont.medium(13))
                        .foregroundStyle(Color.vpoInkSoft)
                } else if weatherFailed {
                    Text("indisponível no momento")
                        .font(AppFont.medium(13))
                        .foregroundStyle(Color.vpoInkSoft)
                } else {
                    Text("carregando…")
                        .font(AppFont.medium(13))
                        .foregroundStyle(Color.vpoInkSoft)
                }
            }

            Spacer()

            if let weather {
                Text(weather.temperature)
                    .font(AppFont.countdown(30))
                    .foregroundStyle(Color.vpoTeal)
            } else if !weatherFailed {
                ProgressView().tint(.vpoTeal)
            }
        }
        .padding(Spacing.md)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .padding(.horizontal, Spacing.lg)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(weatherAccessibilityLabel)
    }

    private var weatherAccessibilityLabel: String {
        if let weather {
            return "Clima agora em \(destination.cityName): \(weather.temperature), \(weather.description)."
        }
        return weatherFailed ? "Clima indisponível no momento." : "Carregando o clima."
    }

    private func loadWeather() async {
        weather = nil
        weatherFailed = false
        do {
            weather = try await WeatherProvider.current(for: destination.coordinate)
        } catch {
            weatherFailed = true
        }
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
        let id = destination.id
        Task {
            try? await repository.delete(destination)
            if let id { NotificationService.cancel(for: id) }
            dismiss()
        }
    }
}
