//
//  TravelMapView.swift
//  vamosPraOndeApp
//
//  Mapa-múndi com todos os destinos do usuário (futuros e passados)
//  e a distância de você até cada um.
//

import SwiftUI
import MapKit

struct TravelMapView: View {
    let destinations: [Destination]

    @EnvironmentObject private var userLocation: UserLocationProvider
    @Environment(\.dismiss) private var dismiss
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                if let user = userLocation.coordinate {
                    ForEach(destinations) { destination in
                        MapPolyline(MKGeodesicPolyline(
                            coordinates: [user, destination.coordinate], count: 2
                        ))
                        .stroke(
                            color(for: destination).opacity(0.55),
                            style: StrokeStyle(lineWidth: 2, dash: [5, 5])
                        )
                    }
                    Annotation("Você", coordinate: user) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.vpoGold, Color.vpoCream)
                    }
                }

                ForEach(destinations) { destination in
                    Marker(destination.cityName, coordinate: destination.coordinate)
                        .tint(color(for: destination))
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Mapa das viagens")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                        .foregroundStyle(Color.vpoTerracotta)
                        .bold()
                }
            }
            .safeAreaInset(edge: .bottom) { legend }
        }
        .tint(.vpoTerracotta)
        .task { userLocation.request() }
    }

    private func color(for destination: Destination) -> Color {
        Countdown(to: destination.date).isPast ? .vpoTeal : .vpoTerracotta
    }

    private var legend: some View {
        HStack(spacing: Spacing.lg) {
            legendItem(color: .vpoTerracotta, label: "próximas")
            legendItem(color: .vpoTeal, label: "já foram")
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.lg)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.bottom, Spacing.sm)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label)
                .font(AppFont.semibold(13))
                .foregroundStyle(Color.vpoInk)
        }
    }
}
