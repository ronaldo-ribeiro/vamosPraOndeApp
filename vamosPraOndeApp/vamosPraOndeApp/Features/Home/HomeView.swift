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

    private var upcoming: [Destination] {
        repo.destinations.filter { !Countdown(to: $0.date).isPast }
    }

    private var hero: Destination? {
        upcoming.first ?? repo.destinations.first
    }

    private var rest: [Destination] {
        repo.destinations.filter { $0.id != hero?.id }
    }

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
                        } else {
                            if let hero {
                                NavigationLink(value: hero) {
                                    DestinationHeroCard(destination: hero)
                                }
                                .buttonStyle(.plain)
                            }
                            if !rest.isEmpty {
                                Text("na sequência")
                                    .font(AppFont.overline())
                                    .kerning(1.5)
                                    .textCase(.uppercase)
                                    .foregroundStyle(Color.vpoInkSoft)
                                VStack(spacing: Spacing.sm) {
                                    ForEach(rest) { destination in
                                        NavigationLink(value: destination) {
                                            DestinationRow(destination: destination)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(Spacing.lg)
                    .padding(.bottom, 90)
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
        .sheet(isPresented: $showingNew) {
            NewDestinationView(repository: repo)
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
            Menu {
                Text(auth.displayEmail)
                Button(role: .destructive) { try? auth.signOut() } label: {
                    Label("Sair", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.vpoTeal)
            }
        }
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
