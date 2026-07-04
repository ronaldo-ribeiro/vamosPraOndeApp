//
//  HomeView.swift
//  vamosPraOndeApp
//
//  Lista os destinos do usuário com a contagem regressiva de cada viagem.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var auth: AuthService
    @StateObject private var repo = DestinationsRepository()
    @State private var showingNew = false
    @State private var showingMap = false
    @State private var sort: DestinationSort = .dateAsc
    @State private var filter: DestinationFilter = .all
    @State private var showingDeleteAccount = false
    @State private var accountError: String?
    @State private var showingAccountError = false

    private var displayed: [Destination] {
        DestinationSorting.apply(repo.destinations, sort: sort, filter: filter)
    }

    private var hero: Destination? { displayed.first }
    private var rest: [Destination] { Array(displayed.dropFirst()) }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.vpoSand.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        header

                        if repo.destinations.isEmpty {
                            EmptyStateView(onAdd: { showingNew = true })
                                .padding(.top, Spacing.xxl)
                        } else if displayed.isEmpty {
                            filteredEmpty
                        } else {
                            if let hero {
                                NavigationLink(value: hero) {
                                    DestinationHeroCard(destination: hero)
                                }
                                .buttonStyle(.plain)
                                .appear(delay: 0.05)
                            }
                            if !rest.isEmpty {
                                Text(sort == .dateAsc ? "na sequência" : "todos os destinos")
                                    .font(AppFont.overline())
                                    .kerning(1.5)
                                    .textCase(.uppercase)
                                    .foregroundStyle(Color.vpoInkSoft)
                                    .appear(delay: 0.1)
                                VStack(spacing: Spacing.sm) {
                                    ForEach(Array(rest.enumerated()), id: \.element.id) { index, destination in
                                        NavigationLink(value: destination) {
                                            DestinationRow(destination: destination)
                                        }
                                        .buttonStyle(.plain)
                                        .appear(delay: 0.14 + Double(index) * 0.06)
                                        .transition(.move(edge: .trailing).combined(with: .opacity))
                                    }
                                }
                            }
                        }
                    }
                    .padding(Spacing.lg)
                    .padding(.bottom, 90)
                    .animation(.spring(response: 0.5, dampingFraction: 0.85), value: displayed)
                }

                if !repo.destinations.isEmpty {
                    addButton
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Destination.self) { destination in
                DestinationDetailView(destination: destination, repository: repo)
            }
        }
        .task { repo.start() }
        .onChange(of: repo.destinations) { _, destinations in
            syncWidget(with: destinations)
        }
        .sheet(isPresented: $showingNew) {
            NewDestinationView(repository: repo)
        }
        .sheet(isPresented: $showingMap) {
            TravelMapView(destinations: repo.destinations)
        }
        .confirmationDialog(
            "Excluir a sua conta?",
            isPresented: $showingDeleteAccount,
            titleVisibility: .visible
        ) {
            Button("Excluir conta", role: .destructive) { deleteAccount() }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Isso apaga todos os seus destinos e a sua conta permanentemente. Não dá para desfazer.")
        }
        .alert("Não foi possível excluir", isPresented: $showingAccountError) {
            Button("OK") {}
        } message: {
            Text(accountError ?? "")
        }
    }

    /// Mantém o widget em dia com a próxima viagem futura.
    private func syncWidget(with destinations: [Destination]) {
        let today = Calendar.current.startOfDay(for: Date())
        let next = destinations
            .filter { Calendar.current.startOfDay(for: $0.date) >= today }
            .min { $0.date < $1.date }
        NextTripSnapshot.save(next.map {
            NextTripSnapshot(cityName: $0.cityName, subtitle: $0.subtitle, date: $0.date)
        })
    }

    private func deleteAccount() {
        Task {
            do {
                try await repo.deleteAll()
                NotificationService.cancelAll()
                try await auth.deleteAccount()
                // Sucesso: o listener de auth zera o usuário e o RootView volta ao login.
            } catch {
                accountError = AuthErrorMessage.of(error)
                showingAccountError = true
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("as suas viagens")
                    .font(AppFont.overline())
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.vpoTerracotta)
                Text("Vamos pra onde?")
                    .font(AppFont.display(32))
                    .foregroundStyle(Color.vpoInk)
            }
            Spacer()
            if !repo.destinations.isEmpty {
                Button { showingMap = true } label: {
                    Image(systemName: "map")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.vpoTerracotta)
                }
                .accessibilityLabel("Mapa das viagens")
                sortFilterMenu
            }
            profileMenu
        }
    }

    private var sortFilterMenu: some View {
        Menu {
            Picker("Filtrar", selection: $filter) {
                ForEach(DestinationFilter.allCases) { Text($0.rawValue).tag($0) }
            }
            Picker("Ordenar", selection: $sort) {
                ForEach(DestinationSort.allCases) { Text($0.rawValue).tag($0) }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle\(filter == .all ? "" : ".fill")")
                .font(.system(size: 26))
                .foregroundStyle(Color.vpoTerracotta)
        }
        .accessibilityLabel("Ordenar e filtrar")
    }

    private var profileMenu: some View {
        Menu {
            Text(auth.displayEmail)
            Button { try? auth.signOut() } label: {
                Label("Sair", systemImage: "rectangle.portrait.and.arrow.right")
            }
            Divider()
            Button(role: .destructive) { showingDeleteAccount = true } label: {
                Label("Excluir conta", systemImage: "trash")
            }
        } label: {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color.vpoTeal)
        }
        .accessibilityLabel("Conta e perfil")
    }

    private var filteredEmpty: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 36))
                .foregroundStyle(Color.vpoInkSoft)
            Text("Nenhuma viagem \(filter.rawValue.lowercased()) por aqui.")
                .font(AppFont.medium(16))
                .foregroundStyle(Color.vpoInkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxl)
    }

    private var addButton: some View {
        Button { showingNew = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.vpoOnColor)
                .frame(width: 60, height: 60)
                .background(Color.vpoTerracotta)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.vpoSand, lineWidth: 4))
                .shadow(color: Color.vpoInk.opacity(0.2), radius: 8, y: 4)
        }
        .accessibilityLabel("Adicionar destino")
        .padding(Spacing.lg)
    }
}

private struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 44))
                .foregroundStyle(Color.vpoTerracotta)
            Text("Nenhuma viagem por aqui ainda")
                .font(AppFont.title(20))
                .foregroundStyle(Color.vpoInk)
                .multilineTextAlignment(.center)
            Text("Adicione o seu primeiro destino e comece a contar os dias.")
                .font(AppFont.body(15))
                .foregroundStyle(Color.vpoInkSoft)
                .multilineTextAlignment(.center)
            Button("Adicionar destino", action: onAdd)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, Spacing.sm)
        }
        .frame(maxWidth: .infinity)
    }
}
