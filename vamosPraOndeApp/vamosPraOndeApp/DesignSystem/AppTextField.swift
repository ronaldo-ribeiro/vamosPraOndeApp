//
//  AppTextField.swift
//  vamosPraOndeApp
//
//  Campo de texto do Design System (tema Wanderlust).
//

import SwiftUI

struct AppTextField: View {
    // LocalizedStringKey: os placeholders literais entram no catálogo.
    let placeholder: LocalizedStringKey
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.vpoInkSoft)
                    .frame(width: 22)
            }

            Group {
                if isSecure {
                    SecureField("", text: $text, prompt: prompt)
                } else {
                    TextField("", text: $text, prompt: prompt)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .font(AppFont.medium(16))
            .foregroundStyle(Color.vpoInk)
            .textContentType(textContentType)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 15)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .stroke(Color.vpoInk.opacity(0.08), lineWidth: 1)
        )
    }

    private var prompt: Text {
        Text(placeholder)
            .font(AppFont.medium(16))
            .foregroundColor(Color.vpoInkSoft)
    }
}
