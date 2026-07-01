//
//  AuthHeader.swift
//  vamosPraOndeApp
//
//  Cabeçalho editorial reutilizado nas telas de autenticação.
//

import SwiftUI

struct AuthHeader: View {
    let overline: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(overline)
                .font(AppFont.overline())
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.vpoTerracotta)
            Text(title)
                .font(AppFont.display(40))
                .foregroundStyle(Color.vpoInk)
            Text(subtitle)
                .font(AppFont.body(15))
                .foregroundStyle(Color.vpoInkSoft)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
