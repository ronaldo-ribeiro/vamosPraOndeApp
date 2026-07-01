//
//  SunsetCover.swift
//  vamosPraOndeApp
//
//  Capa "pôr do sol" reutilizável (boas-vindas, hero da Home, Detalhes).
//  Serve de fallback elegante enquanto a foto real do destino não carrega.
//

import SwiftUI

struct SunsetCover: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient.vpoSunset

            Circle()
                .fill(Color(hex: 0xFBE9C6))
                .frame(width: 64, height: 64)
                .offset(x: 90, y: -90)

            MountainSilhouette(peaks: [0.65, 0.45, 0.6, 0.33, 0.58, 0.37, 0.57])
                .fill(Color(hex: 0x5A2A20).opacity(0.5))
                .frame(height: 120)

            MountainSilhouette(peaks: [0.8, 0.62, 0.77, 0.58, 0.77, 0.63, 0.75])
                .fill(Color(hex: 0x3E1C16).opacity(0.85))
                .frame(height: 90)
        }
        .clipped()
    }
}

/// Silhueta de montanhas paramétrica. Cada valor em `peaks` é a altura
/// relativa (0 = topo, 1 = base) de um vértice ao longo da largura.
struct MountainSilhouette: Shape {
    var peaks: [CGFloat]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard peaks.count > 1 else { return path }
        let step = rect.width / CGFloat(peaks.count - 1)

        path.move(to: CGPoint(x: 0, y: rect.height))
        for (index, peak) in peaks.enumerated() {
            let x = step * CGFloat(index)
            let y = rect.height * peak
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}
