//
//  DestinationCards.swift
//  vamosPraOndeApp
//
//  Card em destaque (próxima viagem) e linha compacta dos demais destinos.
//

import SwiftUI

struct DestinationHeroCard: View {
    let destination: Destination

    private var eyebrow: String {
        switch destination.category() {
        case .upcoming: return String(localized: "próxima viagem")
        case .past: return String(localized: "essa você já fez")
        case .wishlist: return String(localized: "quero visitar")
        }
    }

    /// Capa de arte gerada por código (determinística pelo destino), com um
    /// leve escurecimento na base para o texto continuar legível.
    private var coverBackground: some View {
        destination.cover
            .overlay(
                LinearGradient(
                    colors: [.black.opacity(0.05), .black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .overlay { coverBackground }
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(eyebrow)
                    .font(AppFont.overline(11))
                    .kerning(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(Color(hex: 0xFBE9C6))

                Text(destination.cityName)
                    .font(AppFont.display(38))
                    .foregroundStyle(Color.vpoOnColor)

                if !destination.subtitle.isEmpty {
                    Text(destination.subtitle)
                        .font(AppFont.medium(13))
                        .foregroundStyle(Color.vpoOnColor.opacity(0.9))
                }

                if let date = destination.date {
                    let countdown = Countdown(to: date)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(countdown.value)
                            .font(AppFont.countdown(52))
                            .foregroundStyle(Color.vpoOnColor)
                        Text(countdown.unit)
                            .font(AppFont.semibold(17))
                            .foregroundStyle(Color.vpoOnColor)
                        Spacer()
                        Text(DateStyle.short.string(from: date))
                            .font(AppFont.medium(13))
                            .foregroundStyle(Color.vpoOnColor.opacity(0.9))
                    }
                    .padding(.top, 8)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 22))
                        Text("um sonho na lista")
                            .font(AppFont.semibold(18))
                    }
                    .foregroundStyle(Color.vpoOnColor)
                    .padding(.top, 8)
                }
            }
            .padding(Spacing.lg)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: Radius.cover, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        if let date = destination.date {
            return "\(eyebrow): \(destination.cityName). \(Countdown(to: date).phrase), em \(DateStyle.long.string(from: date))."
        }
        return "Quero visitar: \(destination.cityName)."
    }
}

/// Linha das viagens passadas ("lembranças"): a capa aparece desbotada,
/// como uma foto antiga, com o selo de "já fui" e o mês/ano da viagem.
struct MemoryRow: View {
    let destination: Destination

    private var whenText: String {
        guard let date = destination.date else { return "" }
        return String(localized: "você esteve aqui em \(DateStyle.monthYear.string(from: date))")
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            destination.cover
                .frame(width: 52, height: 52)
                .saturation(0.35)
                .overlay(Color.vpoSand.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.vpoTeal, Color.vpoCream)
                        .offset(x: 5, y: 5)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(destination.cityName)
                    .font(AppFont.title(17))
                    .foregroundStyle(Color.vpoInk.opacity(0.85))
                Text(whenText)
                    .font(AppFont.medium(13))
                    .foregroundStyle(Color.vpoInkSoft)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.vpoInkSoft)
        }
        .padding(Spacing.md)
        .background(Color.vpoCream.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(destination.cityName). \(whenText).")
    }
}

struct DestinationRow: View {
    let destination: Destination

    private var subtitleText: String {
        if let date = destination.date { return Countdown(to: date).phrase }
        return String(localized: "quero visitar")
    }

    private var iconName: String {
        destination.isWishlist ? "heart.fill" : "mappin.and.ellipse"
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient.vpoSunset)
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.vpoOnColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(destination.cityName)
                    .font(AppFont.title(17))
                    .foregroundStyle(Color.vpoInk)
                Text(subtitleText)
                    .font(AppFont.medium(13))
                    .foregroundStyle(Color.vpoInkSoft)
            }

            Spacer()

            if let date = destination.date {
                let countdown = Countdown(to: date)
                VStack(alignment: .trailing, spacing: 0) {
                    Text(countdown.value)
                        .font(AppFont.countdown(22))
                        .foregroundStyle(Color.vpoTerracotta)
                    if !countdown.unit.isEmpty {
                        Text(countdown.unit)
                            .font(AppFont.semibold(11))
                            .textCase(.uppercase)
                            .foregroundStyle(Color.vpoInkSoft)
                    }
                }
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.vpoInkSoft)
            }
        }
        .padding(Spacing.md)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(destination.cityName). \(subtitleText).")
    }
}
