//
//  ErrorBanner.swift
//  vamosPraOndeApp
//
//  Aviso de erro discreto no tema Wanderlust.
//

import SwiftUI

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
            Text(message)
                .font(AppFont.medium(14))
            Spacer(minLength: 0)
        }
        .foregroundStyle(Color.vpoTerracotta)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.vpoTerracotta.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
    }
}
