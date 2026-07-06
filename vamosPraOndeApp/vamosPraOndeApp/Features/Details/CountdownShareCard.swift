//
//  CountdownShareCard.swift
//  vamosPraOndeApp
//
//  Cartão renderizado como imagem (ImageRenderer) para compartilhar a
//  contagem regressiva — proporção 4:5, boa para redes sociais.
//

import SwiftUI

struct CountdownShareCard: View {
    let destination: Destination

    private var countdown: Countdown? { destination.date.map { Countdown(to: $0) } }

    var body: some View {
        ZStack {
            SunsetCover()

            VStack(spacing: 6) {
                Text("VAMOS PRA ONDE?")
                    .font(AppFont.overline(12))
                    .kerning(2.5)
                    .foregroundStyle(Color(hex: 0xFBE9C6))

                Spacer()

                Text(destination.cityName)
                    .font(AppFont.display(46))
                    .foregroundStyle(Color.vpoOnColor)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)

                if !destination.subtitle.isEmpty {
                    Text(destination.subtitle)
                        .font(AppFont.medium(16))
                        .foregroundStyle(Color.vpoOnColor.opacity(0.9))
                }

                if let countdown, let date = destination.date {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(countdown.value)
                            .font(AppFont.countdown(88))
                            .foregroundStyle(Color.vpoOnColor)
                        if !countdown.unit.isEmpty {
                            Text(countdown.unit)
                                .font(AppFont.semibold(26))
                                .foregroundStyle(Color.vpoOnColor.opacity(0.95))
                        }
                    }
                    .padding(.top, 10)

                    Text(DateStyle.long.string(from: date))
                        .font(AppFont.medium(15))
                        .foregroundStyle(Color.vpoOnColor.opacity(0.9))
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                        Text("quero visitar")
                            .font(AppFont.display(40))
                    }
                    .foregroundStyle(Color.vpoOnColor)
                    .padding(.top, 10)
                }

                Spacer()

                Text("conte os dias até a próxima aventura ✈️")
                    .font(AppFont.medium(13))
                    .foregroundStyle(Color.vpoOnColor.opacity(0.85))
            }
            .padding(30)
        }
        .frame(width: 360, height: 450)
    }
}
