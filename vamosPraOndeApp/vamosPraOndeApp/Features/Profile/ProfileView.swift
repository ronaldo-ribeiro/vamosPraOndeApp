//
//  ProfileView.swift
//  vamosPraOndeApp
//
//  Aba "Perfil": conta do usuário, sair e excluir conta.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var repo: DestinationsRepository
    @EnvironmentObject private var auth: AuthService

    @State private var showingDeleteAccount = false
    @State private var accountError: String?
    @State private var showingAccountError = false

    private var initials: String {
        let email = auth.displayEmail
        return String(email.prefix(1)).uppercased()
    }

    private var tripCount: Int { repo.destinations.count }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.vpoSand.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        avatarHeader
                        statsRow
                        optionsCard
                        deleteButton
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
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

    private var avatarHeader: some View {
        VStack(spacing: Spacing.md) {
            Text(initials)
                .font(AppFont.display(40))
                .foregroundStyle(Color.vpoOnColor)
                .frame(width: 96, height: 96)
                .background(LinearGradient.vpoSunset)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.vpoCream, lineWidth: 3))
                .shadow(color: Color.vpoInk.opacity(0.15), radius: 8, y: 4)

            Text(auth.displayEmail)
                .font(AppFont.title(17))
                .foregroundStyle(Color.vpoInk)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.top, Spacing.md)
    }

    private var statsRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "suitcase.rolling.fill")
                .font(.system(size: 15))
                .foregroundStyle(Color.vpoTerracotta)
            Text(tripCount == 1 ? "1 destino guardado" : "\(tripCount) destinos guardados")
                .font(AppFont.semibold(14))
                .foregroundStyle(Color.vpoInkSoft)
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .background(Color.vpoCream)
        .clipShape(Capsule())
    }

    private var optionsCard: some View {
        VStack(spacing: 0) {
            Button { try? auth.signOut() } label: {
                optionRow(icon: "rectangle.portrait.and.arrow.right", title: "Sair", tint: .vpoInk)
            }
            .buttonStyle(.plain)
        }
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }

    private func optionRow(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(tint)
                .frame(width: 26)
            Text(title)
                .font(AppFont.medium(16))
                .foregroundStyle(tint)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.vpoInkSoft)
        }
        .padding(Spacing.md)
        .contentShape(Rectangle())
    }

    private var deleteButton: some View {
        Button(role: .destructive) { showingDeleteAccount = true } label: {
            Label("Excluir conta", systemImage: "trash")
                .font(AppFont.medium(15))
                .foregroundStyle(Color.vpoTerracotta)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
        }
        .padding(.top, Spacing.sm)
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
}
