//
//  DestinationCards.swift
//  vamosPraOndeApp
//
//  Card em destaque (próxima viagem) e linha compacta dos demais destinos.
//

import SwiftUI

struct DestinationHeroCard: View {
    let destination: Destination

    private var countdown: Countdown { Countdown(to: destination.date) }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SunsetCover()

            VStack(alignment: .leading, spacing: 6) {
                Text("próxima viagem")
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

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(countdown.value)
                        .font(AppFont.countdown(52))
                        .foregroundStyle(Color.vpoOnColor)
                    Text(countdown.unit)
                        .font(AppFont.semibold(17))
                        .foregroundStyle(Color.vpoOnColor)
                    Spacer()
                    Text(DateStyle.short.string(from: destination.date))
                        .font(AppFont.medium(13))
                        .foregroundStyle(Color.vpoOnColor.opacity(0.9))
                }
                .padding(.top, 8)
            }
            .padding(Spacing.lg)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: Radius.cover, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Próxima viagem: \(destination.cityName). \(countdown.phrase), em \(DateStyle.long.string(from: destination.date)).")
    }
}

struct DestinationRow: View {
    let destination: Destination

    private var countdown: Countdown { Countdown(to: destination.date) }

    var body: some View {
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient.vpoSunset)
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.vpoOnColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(destination.cityName)
                    .font(AppFont.title(17))
                    .foregroundStyle(Color.vpoInk)
                Text(countdown.phrase)
                    .font(AppFont.medium(13))
                    .foregroundStyle(Color.vpoInkSoft)
            }

            Spacer()

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
        }
        .padding(Spacing.md)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(destination.cityName). \(countdown.phrase).")
    }
}
