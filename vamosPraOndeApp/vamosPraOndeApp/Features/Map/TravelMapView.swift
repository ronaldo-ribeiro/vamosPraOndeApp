//
//  TravelMapView.swift
//  vamosPraOndeApp
//
//  Mapa-múndi com os destinos do usuário (próximas, passadas e desejos)
//  e a distância de você até cada um. Dá para filtrar o que aparece.
//

import SwiftUI
import MapKit

struct TravelMapView: View {
    let destinations: [Destination]

    @EnvironmentObject private var userLocation: UserLocationProvider
    @State private var position: MapCameraPosition = .automatic
    @State private var visible: Set<TripCategory> = [.upcoming, .past, .wishlist]

    private var shown: [Destination] {
        destinations.filter { visible.contains($0.category()) }
    }

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                if let user = userLocation.coordinate {
                    ForEach(shown) { destination in
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

                ForEach(shown) { destination in
                    Marker(destination.cityName, coordinate: destination.coordinate)
                        .tint(color(for: destination))
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Mapa das viagens")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if destinations.isEmpty { emptyHint }
            }
            .safeAreaInset(edge: .bottom) {
                if !destinations.isEmpty { filterBar }
            }
        }
        .tint(.vpoTerracotta)
        .task { userLocation.request() }
    }

    private func color(for destination: Destination) -> Color {
        color(for: destination.category())
    }

    private func color(for category: TripCategory) -> Color {
        switch category {
        case .upcoming: return .vpoTerracotta
        case .past: return .vpoTeal
        case .wishlist: return .vpoGold
        }
    }

    private var emptyHint: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "map")
                .font(.system(size: 40))
                .foregroundStyle(Color.vpoTerracotta)
            Text("Seu mapa começa aqui")
                .font(AppFont.title(18))
                .foregroundStyle(Color.vpoInk)
            Text("Adicione destinos na aba Viagens e eles aparecem fixados por aqui.")
                .font(AppFont.medium(14))
                .foregroundStyle(Color.vpoInkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: 320)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .padding(Spacing.lg)
    }

    private var filterBar: some View {
        HStack(spacing: Spacing.sm) {
            filterChip(.upcoming, label: String(localized: "próximas"))
            filterChip(.past, label: String(localized: "já fui"))
            filterChip(.wishlist, label: String(localized: "quero ir"))
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.bottom, Spacing.sm)
    }

    private func filterChip(_ category: TripCategory, label: String) -> some View {
        let isOn = visible.contains(category)
        let count = destinations.filter { $0.category() == category }.count
        return Button {
            Haptics.tap()
            withAnimation(.easeInOut(duration: 0.2)) {
                if isOn { visible.remove(category) } else { visible.insert(category) }
            }
        } label: {
            HStack(spacing: 6) {
                Circle().fill(color(for: category)).frame(width: 10, height: 10)
                Text(label)
                    .font(AppFont.semibold(13))
                    .foregroundStyle(Color.vpoInk)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, Spacing.sm)
            .background(isOn ? color(for: category).opacity(0.18) : Color.clear, in: Capsule())
            .opacity(count == 0 ? 0.4 : (isOn ? 1 : 0.55))
        }
        .buttonStyle(.plain)
        .disabled(count == 0)
        .accessibilityLabel("\(label), \(count) \(count == 1 ? "destino" : "destinos"), \(isOn ? "mostrando" : "oculto")")
    }
}
