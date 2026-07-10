//
//  Landmarks.swift
//  vamosPraOndeApp
//
//  Silhuetas de marcos icônicos desenhadas em código, para as capas das
//  principais cidades do mundo (Torre Eiffel em Paris, Cristo + Pão de
//  Açúcar no Rio…). O marco entra como a camada da frente da paisagem,
//  na mesma cor da silhueta — cidades sem marco seguem com a cena genérica.
//

import SwiftUI

enum CityLandmark {
    case eiffel            // Paris
    case rio               // Rio de Janeiro (Corcovado + Pão de Açúcar)
    case colosseum         // Roma
    case bigBen            // Londres
    case tokyoTower        // Tóquio
    case sagradaFamilia    // Barcelona
    case nycSkyline        // Nova York (Empire State + skyline)
    case obelisk           // Buenos Aires
    case pyramids          // Cairo/Gizé
    case operaHouse        // Sydney
    case suspensionBridge  // Lisboa (25 de Abril) / San Francisco (Golden Gate)
    case burj              // Dubai
    case palm              // Miami/Honolulu/Cancún (praia com palmeira)

    /// Reconhece o marco pelo nome da cidade (sem acentos, minúsculas).
    static func match(_ city: String) -> CityLandmark? {
        let name = city
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
        let table: [(String, CityLandmark)] = [
            ("paris", .eiffel),
            ("rio de janeiro", .rio),
            ("roma", .colosseum), ("rome", .colosseum),
            ("londres", .bigBen), ("london", .bigBen),
            ("toquio", .tokyoTower), ("tokyo", .tokyoTower), ("tokio", .tokyoTower),
            ("barcelona", .sagradaFamilia),
            ("nova york", .nycSkyline), ("new york", .nycSkyline), ("nova iorque", .nycSkyline),
            ("buenos aires", .obelisk),
            ("cairo", .pyramids), ("gize", .pyramids), ("giza", .pyramids),
            ("sydney", .operaHouse), ("sidney", .operaHouse),
            ("lisboa", .suspensionBridge), ("lisbon", .suspensionBridge),
            ("san francisco", .suspensionBridge), ("sao francisco", .suspensionBridge),
            ("dubai", .burj),
            ("miami", .palm), ("honolulu", .palm), ("cancun", .palm),
        ]
        return table.first { name.contains($0.0) }?.1
    }

    /// Altura do marco em relação à altura da capa.
    var heightFactor: CGFloat {
        switch self {
        case .eiffel: return 0.62
        case .rio: return 0.50
        case .colosseum: return 0.34
        case .bigBen: return 0.58
        case .tokyoTower: return 0.60
        case .sagradaFamilia: return 0.55
        case .nycSkyline: return 0.52
        case .obelisk: return 0.52
        case .pyramids: return 0.38
        case .operaHouse: return 0.32
        case .suspensionBridge: return 0.42
        case .burj: return 0.66
        case .palm: return 0.52
        }
    }

    /// Proporção largura/altura do desenho.
    var aspect: CGFloat {
        switch self {
        case .eiffel: return 0.62
        case .rio: return 1.8
        case .colosseum: return 2.0
        case .bigBen: return 0.34
        case .tokyoTower: return 0.60
        case .sagradaFamilia: return 0.95
        case .nycSkyline: return 1.9
        case .obelisk: return 0.26
        case .pyramids: return 2.0
        case .operaHouse: return 1.8
        case .suspensionBridge: return 2.4
        case .burj: return 0.30
        case .palm: return 0.95
        }
    }

    /// Posição horizontal (0–1) do centro do marco na capa. Fica à direita
    /// do centro para não brigar com o texto (canto inferior esquerdo).
    var anchorX: CGFloat {
        switch self {
        case .rio, .nycSkyline, .pyramids, .colosseum, .operaHouse: return 0.62
        case .suspensionBridge: return 0.55
        case .palm, .bigBen: return 0.72
        default: return 0.70
        }
    }

    /// Marcos com "furos" (janelas/arcos) usam even-odd para recortar.
    var usesEvenOdd: Bool { self == .colosseum }
}

/// Desenha a silhueta do marco num retângulo (0,0 = topo; base = chão).
struct LandmarkShape: Shape {
    let landmark: CityLandmark

    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Converte coordenadas normalizadas (0–1) para o rect.
        func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        func rectN(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
            p.addRect(CGRect(x: rect.minX + x * rect.width,
                             y: rect.minY + y * rect.height,
                             width: w * rect.width,
                             height: h * rect.height))
        }

        switch landmark {
        case .eiffel:
            // Corpo com pernas curvas e arco central.
            p.move(to: P(0.02, 1.0))
            p.addQuadCurve(to: P(0.33, 0.52), control: P(0.16, 0.80))
            p.addLine(to: P(0.37, 0.34))
            p.addQuadCurve(to: P(0.46, 0.06), control: P(0.41, 0.15))
            p.addLine(to: P(0.46, 0.0))
            p.addLine(to: P(0.54, 0.0))
            p.addLine(to: P(0.54, 0.06))
            p.addQuadCurve(to: P(0.63, 0.34), control: P(0.59, 0.15))
            p.addLine(to: P(0.67, 0.52))
            p.addQuadCurve(to: P(0.98, 1.0), control: P(0.84, 0.80))
            p.addLine(to: P(0.78, 1.0))
            p.addQuadCurve(to: P(0.50, 0.70), control: P(0.64, 0.76))
            p.addQuadCurve(to: P(0.22, 1.0), control: P(0.36, 0.76))
            p.closeSubpath()
            // Plataformas.
            rectN(0.24, 0.50, 0.52, 0.035)
            rectN(0.34, 0.315, 0.32, 0.030)

        case .rio:
            // Corcovado (morro) com o Cristo no topo.
            p.move(to: P(0.02, 1.0))
            p.addQuadCurve(to: P(0.30, 0.36), control: P(0.10, 0.56))
            p.addQuadCurve(to: P(0.56, 1.0), control: P(0.46, 0.60))
            p.closeSubpath()
            rectN(0.283, 0.27, 0.034, 0.10)   // pedestal
            rectN(0.291, 0.13, 0.018, 0.15)   // corpo
            rectN(0.215, 0.155, 0.17, 0.028)  // braços
            rectN(0.292, 0.085, 0.016, 0.045) // cabeça
            // Pão de Açúcar.
            p.move(to: P(0.58, 1.0))
            p.addQuadCurve(to: P(0.79, 0.44), control: P(0.63, 0.56))
            p.addQuadCurve(to: P(0.99, 1.0), control: P(0.95, 0.56))
            p.closeSubpath()

        case .colosseum:
            // Parede rompida (lado alto + lado baixo), arcos recortados.
            p.move(to: P(0.03, 1.0))
            p.addLine(to: P(0.05, 0.44))
            p.addQuadCurve(to: P(0.35, 0.36), control: P(0.15, 0.37))
            p.addLine(to: P(0.58, 0.36))
            p.addLine(to: P(0.62, 0.55))
            p.addLine(to: P(0.93, 0.55))
            p.addLine(to: P(0.97, 1.0))
            p.closeSubpath()
            // Arcos (furos, even-odd): fileira superior + inferior.
            for i in 0..<5 {
                let x = 0.11 + CGFloat(i) * 0.095
                p.addRoundedRect(
                    in: CGRect(x: rect.minX + x * rect.width,
                               y: rect.minY + 0.46 * rect.height,
                               width: 0.05 * rect.width, height: 0.11 * rect.height),
                    cornerSize: CGSize(width: 0.025 * rect.width, height: 0.05 * rect.height))
            }
            for i in 0..<8 {
                let x = 0.09 + CGFloat(i) * 0.105
                p.addRoundedRect(
                    in: CGRect(x: rect.minX + x * rect.width,
                               y: rect.minY + 0.66 * rect.height,
                               width: 0.055 * rect.width, height: 0.16 * rect.height),
                    cornerSize: CGSize(width: 0.027 * rect.width, height: 0.07 * rect.height))
            }

        case .bigBen:
            rectN(0.34, 0.30, 0.32, 0.70)     // torre
            rectN(0.28, 0.16, 0.44, 0.17)     // caixa do relógio
            p.move(to: P(0.28, 0.16))         // coroa pontiaguda
            p.addLine(to: P(0.50, 0.02))
            p.addLine(to: P(0.72, 0.16))
            p.closeSubpath()
            rectN(0.485, 0.0, 0.03, 0.05)     // agulha

        case .tokyoTower:
            p.move(to: P(0.08, 1.0))          // corpo triangular
            p.addLine(to: P(0.455, 0.12))
            p.addLine(to: P(0.545, 0.12))
            p.addLine(to: P(0.92, 1.0))
            p.addLine(to: P(0.74, 1.0))
            p.addQuadCurve(to: P(0.50, 0.74), control: P(0.62, 0.78))
            p.addQuadCurve(to: P(0.26, 1.0), control: P(0.38, 0.78))
            p.closeSubpath()
            rectN(0.47, 0.0, 0.06, 0.13)      // antena
            rectN(0.20, 0.54, 0.60, 0.045)    // deck principal (bem saliente)
            rectN(0.33, 0.29, 0.34, 0.035)    // deck superior

        case .sagradaFamilia:
            // Quatro torres afuniladas (as internas mais altas).
            let spires: [(c: CGFloat, top: CGFloat)] = [
                (0.17, 0.30), (0.39, 0.10), (0.61, 0.10), (0.83, 0.30)
            ]
            for s in spires {
                p.move(to: P(s.c - 0.115, 1.0))
                p.addQuadCurve(to: P(s.c, s.top), control: P(s.c - 0.095, s.top + 0.28))
                p.addQuadCurve(to: P(s.c + 0.115, 1.0), control: P(s.c + 0.095, s.top + 0.28))
                p.closeSubpath()
                rectN(s.c - 0.012, s.top - 0.06, 0.024, 0.07) // pináculo
            }

        case .nycSkyline:
            rectN(0.00, 0.55, 0.11, 0.45)
            rectN(0.115, 0.42, 0.10, 0.58)
            rectN(0.225, 0.60, 0.10, 0.40)
            // Empire State (escalonado + agulha).
            rectN(0.355, 0.45, 0.29, 0.55)
            rectN(0.40, 0.30, 0.20, 0.16)
            rectN(0.45, 0.17, 0.10, 0.14)
            rectN(0.487, 0.04, 0.026, 0.14)
            rectN(0.655, 0.38, 0.10, 0.62)
            rectN(0.765, 0.52, 0.115, 0.48)
            rectN(0.89, 0.64, 0.10, 0.36)

        case .obelisk:
            p.move(to: P(0.34, 1.0))
            p.addLine(to: P(0.42, 0.14))
            p.addLine(to: P(0.50, 0.03))
            p.addLine(to: P(0.58, 0.14))
            p.addLine(to: P(0.66, 1.0))
            p.closeSubpath()

        case .pyramids:
            p.move(to: P(0.03, 1.0))          // grande
            p.addLine(to: P(0.40, 0.16))
            p.addLine(to: P(0.77, 1.0))
            p.closeSubpath()
            p.move(to: P(0.55, 1.0))          // menor
            p.addLine(to: P(0.79, 0.46))
            p.addLine(to: P(0.99, 1.0))
            p.closeSubpath()

        case .operaHouse:
            rectN(0.0, 0.86, 1.0, 0.14)       // base
            // Velas.
            p.move(to: P(0.05, 0.88))
            p.addQuadCurve(to: P(0.36, 0.28), control: P(0.13, 0.34))
            p.addQuadCurve(to: P(0.40, 0.88), control: P(0.40, 0.55))
            p.closeSubpath()
            p.move(to: P(0.30, 0.88))
            p.addQuadCurve(to: P(0.64, 0.16), control: P(0.40, 0.22))
            p.addQuadCurve(to: P(0.68, 0.88), control: P(0.68, 0.48))
            p.closeSubpath()
            p.move(to: P(0.62, 0.88))
            p.addQuadCurve(to: P(0.90, 0.34), control: P(0.72, 0.38))
            p.addQuadCurve(to: P(0.94, 0.88), control: P(0.94, 0.60))
            p.closeSubpath()

        case .suspensionBridge:
            rectN(0.0, 0.70, 1.0, 0.05)       // tabuleiro
            rectN(0.26, 0.24, 0.05, 0.76)     // torre esquerda
            rectN(0.69, 0.24, 0.05, 0.76)     // torre direita
            rectN(0.255, 0.38, 0.06, 0.03)    // travessas
            rectN(0.685, 0.38, 0.06, 0.03)
            // Cabo central (faixa curva entre as torres).
            p.move(to: P(0.285, 0.26))
            p.addQuadCurve(to: P(0.715, 0.26), control: P(0.50, 0.66))
            p.addLine(to: P(0.715, 0.30))
            p.addQuadCurve(to: P(0.285, 0.30), control: P(0.50, 0.70))
            p.closeSubpath()
            // Cabos laterais.
            p.move(to: P(0.0, 0.62))
            p.addQuadCurve(to: P(0.285, 0.26), control: P(0.13, 0.38))
            p.addLine(to: P(0.285, 0.30))
            p.addQuadCurve(to: P(0.0, 0.66), control: P(0.14, 0.42))
            p.closeSubpath()
            p.move(to: P(1.0, 0.62))
            p.addQuadCurve(to: P(0.715, 0.26), control: P(0.87, 0.38))
            p.addLine(to: P(0.715, 0.30))
            p.addQuadCurve(to: P(1.0, 0.66), control: P(0.86, 0.42))
            p.closeSubpath()

        case .burj:
            // Agulha em camadas escalonadas.
            rectN(0.30, 0.62, 0.40, 0.38)
            rectN(0.36, 0.40, 0.28, 0.24)
            rectN(0.42, 0.22, 0.16, 0.20)
            rectN(0.465, 0.10, 0.07, 0.14)
            rectN(0.492, 0.0, 0.016, 0.12)

        case .palm:
            // Tronco curvado.
            p.move(to: P(0.40, 1.0))
            p.addQuadCurve(to: P(0.55, 0.30), control: P(0.38, 0.60))
            p.addLine(to: P(0.62, 0.33))
            p.addQuadCurve(to: P(0.52, 1.0), control: P(0.47, 0.62))
            p.closeSubpath()
            // Folhas (a partir da copa).
            let crown = (x: CGFloat(0.585), y: CGFloat(0.30))
            let tips: [(CGFloat, CGFloat)] = [
                (0.16, 0.40), (0.24, 0.10), (0.62, 0.02), (0.92, 0.12), (0.96, 0.42)
            ]
            for tip in tips {
                let midX = (crown.x + tip.0) / 2
                let midY = min(crown.y, tip.1) - 0.10
                p.move(to: P(crown.x, crown.y))
                p.addQuadCurve(to: P(tip.0, tip.1), control: P(midX, midY))
                p.addQuadCurve(to: P(crown.x, crown.y + 0.05),
                               control: P(midX, midY + 0.10))
                p.closeSubpath()
            }
        }
        return p
    }
}
