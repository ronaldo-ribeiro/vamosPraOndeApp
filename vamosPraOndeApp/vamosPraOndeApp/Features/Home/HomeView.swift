//
//  HomeView.swift
//  vamosPraOndeApp
//
//  Aba "Viagens": lista os destinos do usuário com a contagem
//  regressiva de cada viagem.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var repo: DestinationsRepository
    @State private var showingNew = false
    @State private var sort: DestinationSort = .dateAsc
    @State private var filter: DestinationFilter = .all

    private var displayed: [Destination] {
        DestinationSorting.apply(repo.destinations, sort: sort, filter: filter)
    }

    /// Próximas e desejos seguem no fluxo principal (herói + lista).
    private var active: [Destination] { displayed.filter { $0.category() != .past } }
    /// Passadas viram "lembranças" — histórico no fim, da mais recente pra trás.
    private var memories: [Destination] {
        displayed.filter { $0.category() == .past }
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
    }

    private var hero: Destination? { active.first }
    private var rest: [Destination] { Array(active.dropFirst()) }

    /// "3 viagens · 2 países" do histórico.
    private var memoriesSummary: String {
        let countries = Set(memories.map(\.subtitle).filter { !$0.isEmpty })
        let viagens = memories.count == 1
            ? String(localized: "1 viagem") : String(localized: "\(memories.count) viagens")
        guard countries.count > 0 else { return viagens }
        let paises = countries.count == 1
            ? String(localized: "1 país") : String(localized: "\(countries.count) países")
        return "\(viagens) · \(paises)"
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
                        } else if displayed.isEmpty {
                            filteredEmpty
                        } else {
                            if let hero {
                                NavigationLink(value: hero) {
                                    DestinationHeroCard(destination: hero)
                                }
                                .buttonStyle(.plain)
                                // `Destination` é Equatable só por id, então uma troca de
                                // capa (mesmo id) não redesenha o card sozinha — o id força.
                                .id(hero.coverStyle)
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
                            if !memories.isEmpty {
                                HStack(alignment: .firstTextBaseline) {
                                    Text("lembranças")
                                        .font(AppFont.overline())
                                        .kerning(1.5)
                                        .textCase(.uppercase)
                                        .foregroundStyle(Color.vpoTeal)
                                    Spacer()
                                    Text(memoriesSummary)
                                        .font(AppFont.medium(12))
                                        .foregroundStyle(Color.vpoInkSoft)
                                }
                                .padding(.top, rest.isEmpty && hero == nil ? 0 : Spacing.sm)
                                .appear(delay: 0.18)
                                VStack(spacing: Spacing.sm) {
                                    ForEach(Array(memories.enumerated()), id: \.element.id) { index, destination in
                                        NavigationLink(value: destination) {
                                            MemoryRow(destination: destination)
                                        }
                                        .buttonStyle(.plain)
                                        .appear(delay: 0.2 + Double(index) * 0.06)
                                        .transition(.move(edge: .trailing).combined(with: .opacity))
                                    }
                                }
                            }
                        }
                    }
                    .padding(Spacing.lg)
                    .padding(.bottom, 90)
                    // iPad: limita a largura da coluna de conteúdo para leitura confortável.
                    .frame(maxWidth: 700)
                    .frame(maxWidth: .infinity)
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
            if !repo.destinations.isEmpty {
                sortFilterMenu
            }
        }
    }

    private var sortFilterMenu: some View {
        Menu {
            Picker("Filtrar", selection: $filter) {
                ForEach(DestinationFilter.allCases) { Text($0.label).tag($0) }
            }
            Picker("Ordenar", selection: $sort) {
                ForEach(DestinationSort.allCases) { Text($0.label).tag($0) }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle\(filter == .all ? "" : ".fill")")
                .font(.system(size: 26))
                .foregroundStyle(Color.vpoTerracotta)
        }
        .accessibilityLabel("Ordenar e filtrar")
    }

    private var filteredEmpty: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 36))
                .foregroundStyle(Color.vpoInkSoft)
            Text("Nada por aqui em “\(filter.label)”.")
                .font(AppFont.medium(16))
                .foregroundStyle(Color.vpoInkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxl)
    }

    private var addButton: some View {
        Button {
            Haptics.tap()
            showingNew = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.vpoOnColor)
                .frame(width: 60, height: 60)
                .fabBackground()
        }
        .accessibilityLabel("Adicionar destino")
        .padding(Spacing.lg)
    }
}

private extension View {
    /// Fundo do botão flutuante: vidro (Liquid Glass) tingido no iOS 26,
    /// círculo sólido nas versões anteriores.
    @ViewBuilder
    func fabBackground() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(Color.vpoTerracotta).interactive(), in: .circle)
        } else {
            self.background(Color.vpoTerracotta)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.vpoSand, lineWidth: 4))
                .shadow(color: Color.vpoInk.opacity(0.2), radius: 8, y: 4)
        }
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
