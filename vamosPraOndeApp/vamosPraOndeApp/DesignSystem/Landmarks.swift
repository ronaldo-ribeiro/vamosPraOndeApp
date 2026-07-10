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
    case palm              // Praias (Miami, Natal, Maceió, Noronha…)
    // Brasil + América do Sul
    case congresso         // Brasília (Congresso Nacional)
    case ponteEstaiada     // São Paulo (Ponte Octávio Frias)
    case elevadorLacerda   // Salvador
    case jangada           // Fortaleza
    case frevo             // Recife/Olinda (sombrinha de frevo)
    case teatroAmazonas    // Manaus
    case pampulha          // Belo Horizonte (Igreja da Pampulha)
    case tucano            // Foz do Iguaçu (Parque das Aves; cachoeira não funciona em silhueta)
    case machuPicchu       // Cusco / Machu Picchu
    case palacioSalvo      // Montevidéu

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
            // Brasil + América do Sul
            ("brasilia", .congresso),
            ("sao paulo", .ponteEstaiada),
            ("salvador", .elevadorLacerda),
            ("fortaleza", .jangada),
            ("recife", .frevo), ("olinda", .frevo),
            ("manaus", .teatroAmazonas),
            ("belo horizonte", .pampulha),
            ("foz do iguacu", .tucano), ("puerto iguazu", .tucano),
            ("florianopolis", .suspensionBridge),
            ("cusco", .machuPicchu), ("machu picchu", .machuPicchu),
            ("montevideu", .palacioSalvo), ("montevideo", .palacioSalvo),
            // Praias
            ("miami", .palm), ("honolulu", .palm), ("cancun", .palm),
            ("natal", .palm), ("maceio", .palm), ("joao pessoa", .palm),
            ("aracaju", .palm), ("jericoacoara", .palm), ("noronha", .palm),
            ("buzios", .palm), ("porto de galinhas", .palm), ("porto seguro", .palm),
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
        case .pyramids: return 0.46
        case .operaHouse: return 0.40
        case .suspensionBridge: return 0.42
        case .burj: return 0.66
        case .palm: return 0.52
        case .congresso: return 0.36
        case .ponteEstaiada: return 0.44
        case .elevadorLacerda: return 0.54
        case .jangada: return 0.36
        case .frevo: return 0.44
        case .teatroAmazonas: return 0.42
        case .pampulha: return 0.38
        case .tucano: return 0.42
        case .machuPicchu: return 0.52
        case .palacioSalvo: return 0.58
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
        case .obelisk: return 0.34
        case .pyramids: return 2.0
        case .operaHouse: return 1.8
        case .suspensionBridge: return 2.4
        case .burj: return 0.30
        case .palm: return 0.95
        case .congresso: return 2.2
        case .ponteEstaiada: return 2.0
        case .elevadorLacerda: return 0.55
        case .jangada: return 1.3
        case .frevo: return 0.9
        case .teatroAmazonas: return 1.5
        case .pampulha: return 1.9
        case .tucano: return 0.9
        case .machuPicchu: return 1.25
        case .palacioSalvo: return 0.45
        }
    }

    /// Posição horizontal (0–1) do centro do marco na capa. Fica à direita
    /// do centro para não brigar com o texto (canto inferior esquerdo).
    var anchorX: CGFloat {
        switch self {
        case .rio, .nycSkyline, .pyramids, .colosseum, .operaHouse,
             .congresso, .ponteEstaiada, .pampulha, .tucano: return 0.62
        case .suspensionBridge: return 0.55
        case .palm, .bigBen: return 0.72
        case .jangada, .machuPicchu: return 0.66
        default: return 0.70
        }
    }

    /// Marcos com "furos" (janelas/arcos/relógio/quedas) usam even-odd.
    var usesEvenOdd: Bool {
        self == .colosseum || self == .bigBen || self == .elevadorLacerda
    }
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
            // Perfil "exponencial" real: dois terços superiores bem esguios,
            // flare dramático só perto da base, arco alto e visível.
            p.move(to: P(0.04, 1.0))
            p.addQuadCurve(to: P(0.345, 0.635), control: P(0.17, 0.78))
            p.addLine(to: P(0.395, 0.44))
            p.addLine(to: P(0.437, 0.40))
            p.addLine(to: P(0.468, 0.07))
            p.addLine(to: P(0.468, 0.055))
            p.addLine(to: P(0.532, 0.055))
            p.addLine(to: P(0.532, 0.07))
            p.addLine(to: P(0.563, 0.40))
            p.addLine(to: P(0.605, 0.44))
            p.addLine(to: P(0.655, 0.635))
            p.addQuadCurve(to: P(0.96, 1.0), control: P(0.83, 0.78))
            p.addLine(to: P(0.76, 1.0))
            p.addQuadCurve(to: P(0.50, 0.795), control: P(0.645, 0.845))
            p.addQuadCurve(to: P(0.24, 1.0), control: P(0.355, 0.845))
            p.closeSubpath()
            // Antena fina.
            rectN(0.488, 0.0, 0.024, 0.07)
            // Decks salientes (1º a ~61%, 2º a ~40%).
            rectN(0.30, 0.60, 0.40, 0.030)
            rectN(0.40, 0.385, 0.20, 0.026)

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
            rectN(0.36, 0.34, 0.28, 0.66)     // torre (esguia)
            rectN(0.24, 0.16, 0.52, 0.20)     // caixa do relógio (bem saliente)
            p.move(to: P(0.24, 0.16))         // coroa pontiaguda
            p.addLine(to: P(0.50, 0.01))
            p.addLine(to: P(0.76, 0.16))
            p.closeSubpath()
            rectN(0.487, 0.0, 0.026, 0.045)   // agulha
            // Mostrador do relógio (furo, even-odd).
            p.addEllipse(in: CGRect(x: rect.minX + 0.40 * rect.width,
                                    y: rect.minY + 0.205 * rect.height,
                                    width: 0.20 * rect.width,
                                    height: 0.11 * rect.height))

        case .tokyoTower:
            // Corpo esguio no alto, pernas abrindo no terço final, arco na base.
            p.move(to: P(0.10, 1.0))
            p.addQuadCurve(to: P(0.43, 0.56), control: P(0.27, 0.76))
            p.addLine(to: P(0.478, 0.14))
            p.addLine(to: P(0.522, 0.14))
            p.addLine(to: P(0.57, 0.56))
            p.addQuadCurve(to: P(0.90, 1.0), control: P(0.73, 0.76))
            p.addLine(to: P(0.72, 1.0))
            p.addQuadCurve(to: P(0.50, 0.76), control: P(0.60, 0.80))
            p.addQuadCurve(to: P(0.28, 1.0), control: P(0.40, 0.80))
            p.closeSubpath()
            rectN(0.482, 0.0, 0.036, 0.15)    // antena comprida
            rectN(0.235, 0.56, 0.53, 0.038)   // deck principal (bem saliente)
            rectN(0.375, 0.325, 0.25, 0.030)  // deck superior

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
            // Obelisco robusto com base escalonada (como o da 9 de Julio).
            p.move(to: P(0.30, 1.0))
            p.addLine(to: P(0.38, 0.16))
            p.addLine(to: P(0.50, 0.02))
            p.addLine(to: P(0.62, 0.16))
            p.addLine(to: P(0.70, 1.0))
            p.closeSubpath()
            rectN(0.20, 0.92, 0.60, 0.08)     // base

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
            rectN(0.0, 0.84, 1.0, 0.16)       // plataforma
            // Velas grandes com PONTAS agudas (frente convexa, costas retas).
            p.move(to: P(0.02, 0.86))
            p.addQuadCurve(to: P(0.34, 0.22), control: P(0.05, 0.30))
            p.addLine(to: P(0.38, 0.86))
            p.closeSubpath()
            p.move(to: P(0.26, 0.86))
            p.addQuadCurve(to: P(0.63, 0.06), control: P(0.30, 0.14))
            p.addLine(to: P(0.68, 0.86))
            p.closeSubpath()
            p.move(to: P(0.58, 0.86))
            p.addQuadCurve(to: P(0.89, 0.28), control: P(0.62, 0.34))
            p.addLine(to: P(0.94, 0.86))
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
                (0.16, 0.40), (0.24, 0.10), (0.52, 0.03), (0.88, 0.08), (0.96, 0.42)
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

        case .congresso:
            // Plataforma + torres gêmeas + cúpula (Senado) + tigela (Câmara).
            rectN(0.0, 0.80, 1.0, 0.10)
            rectN(0.455, 0.06, 0.036, 0.74)
            rectN(0.509, 0.06, 0.036, 0.74)
            // Cúpula convexa (esquerda).
            p.move(to: P(0.06, 0.80))
            p.addQuadCurve(to: P(0.20, 0.52), control: P(0.08, 0.56))
            p.addQuadCurve(to: P(0.34, 0.80), control: P(0.32, 0.56))
            p.closeSubpath()
            // Tigela côncava (direita) — crescente.
            p.move(to: P(0.62, 0.58))
            p.addQuadCurve(to: P(0.94, 0.58), control: P(0.78, 0.92))
            p.addQuadCurve(to: P(0.62, 0.58), control: P(0.78, 0.72))
            p.closeSubpath()

        case .ponteEstaiada:
            // Pilar em X + tabuleiro + estais em leque.
            p.move(to: P(0.28, 1.0)); p.addLine(to: P(0.34, 1.0))
            p.addLine(to: P(0.645, 0.05)); p.addLine(to: P(0.585, 0.05))
            p.closeSubpath()
            p.move(to: P(0.72, 1.0)); p.addLine(to: P(0.66, 1.0))
            p.addLine(to: P(0.355, 0.05)); p.addLine(to: P(0.415, 0.05))
            p.closeSubpath()
            rectN(0.0, 0.58, 1.0, 0.045)
            // Estais (triângulos finíssimos a partir do alto do X).
            for tip in [0.10, 0.24, 0.76, 0.90] {
                p.move(to: P(0.50, 0.10))
                p.addLine(to: P(CGFloat(tip), 0.58))
                p.addLine(to: P(CGFloat(tip) + 0.015, 0.58))
                p.addLine(to: P(0.508, 0.10))
                p.closeSubpath()
            }

        case .elevadorLacerda:
            // Torre art déco alta + passarela no alto (furos = janelas).
            rectN(0.28, 0.06, 0.30, 0.94)     // torre
            rectN(0.24, 0.015, 0.38, 0.055)   // coroa
            rectN(0.58, 0.10, 0.42, 0.05)     // passarela
            rectN(0.92, 0.15, 0.06, 0.25)     // apoio da passarela
            // Janelas verticais (furos, even-odd).
            rectN(0.345, 0.14, 0.045, 0.56)
            rectN(0.445, 0.14, 0.045, 0.56)

        case .jangada:
            // Casco curvo + mastro + vela latina.
            p.move(to: P(0.04, 0.78))
            p.addLine(to: P(0.96, 0.78))
            p.addQuadCurve(to: P(0.80, 0.94), control: P(0.92, 0.92))
            p.addLine(to: P(0.22, 0.94))
            p.addQuadCurve(to: P(0.04, 0.78), control: P(0.08, 0.92))
            p.closeSubpath()
            rectN(0.475, 0.06, 0.022, 0.72)   // mastro
            // Vela (triângulo de bordas curvas).
            p.move(to: P(0.50, 0.06))
            p.addQuadCurve(to: P(0.86, 0.72), control: P(0.70, 0.26))
            p.addLine(to: P(0.52, 0.72))
            p.closeSubpath()

        case .frevo:
            // Sombrinha de frevo: cúpula com babados + cabo.
            p.move(to: P(0.08, 0.46))
            p.addQuadCurve(to: P(0.92, 0.46), control: P(0.50, -0.14))
            // Babados (voltando por arcos pequenos).
            for i in stride(from: 0, to: 4, by: 1) {
                let x1 = 0.92 - CGFloat(i) * 0.21
                let x0 = x1 - 0.21
                p.addQuadCurve(to: P(x0, 0.46), control: P((x0 + x1) / 2, 0.56))
            }
            p.closeSubpath()
            rectN(0.489, 0.0, 0.022, 0.08)    // ponteira
            rectN(0.492, 0.46, 0.016, 0.42)   // cabo
            p.move(to: P(0.508, 0.88))        // gancho
            p.addQuadCurve(to: P(0.44, 0.94), control: P(0.50, 0.98))
            p.addLine(to: P(0.44, 0.91))
            p.addQuadCurve(to: P(0.492, 0.88), control: P(0.48, 0.93))
            p.closeSubpath()

        case .teatroAmazonas:
            // Corpo clássico + frontão + tambor e cúpula.
            rectN(0.04, 0.62, 0.92, 0.38)
            p.move(to: P(0.22, 0.62))         // frontão
            p.addLine(to: P(0.50, 0.46))
            p.addLine(to: P(0.78, 0.62))
            p.closeSubpath()
            rectN(0.30, 0.44, 0.40, 0.08)     // tambor
            p.move(to: P(0.27, 0.46))         // cúpula (protagonista)
            p.addQuadCurve(to: P(0.73, 0.46), control: P(0.50, 0.0))
            p.closeSubpath()
            rectN(0.485, 0.13, 0.03, 0.11)    // lanternim

        case .pampulha:
            // Igreja da Pampulha: parábolas de Niemeyer + campanário.
            // Campanário (poste + travessa do sino).
            rectN(0.028, 0.24, 0.024, 0.76)
            rectN(0.0, 0.24, 0.08, 0.028)
            // Parábolas: control em y negativo pois o ápice de uma quadrática
            // fica na metade do caminho até o control (ápice = 2c - m).
            p.move(to: P(0.10, 1.0))          // parábola principal (ápice ~0.08)
            p.addQuadCurve(to: P(0.46, 1.0), control: P(0.28, -0.84))
            p.closeSubpath()
            p.move(to: P(0.43, 1.0))          // ápice ~0.30
            p.addQuadCurve(to: P(0.70, 1.0), control: P(0.565, -0.40))
            p.closeSubpath()
            p.move(to: P(0.67, 1.0))          // ápice ~0.48
            p.addQuadCurve(to: P(0.87, 1.0), control: P(0.77, -0.04))
            p.closeSubpath()
            p.move(to: P(0.84, 1.0))          // ápice ~0.62
            p.addQuadCurve(to: P(0.98, 1.0), control: P(0.91, 0.24))
            p.closeSubpath()

        case .tucano:
            // Tucano de perfil (bico para a esquerda), pousado num galho.
            p.move(to: P(0.56, 0.10))                                   // alto da cabeça
            p.addQuadCurve(to: P(0.46, 0.15), control: P(0.49, 0.09))   // testa
            p.addQuadCurve(to: P(0.03, 0.42), control: P(0.14, 0.12))   // dorso do bico (caindo)
            p.addLine(to: P(0.07, 0.49))                                // ponta
            p.addQuadCurve(to: P(0.46, 0.29), control: P(0.24, 0.38))   // base do bico (fina)
            p.addQuadCurve(to: P(0.48, 0.62), control: P(0.40, 0.46))   // peito
            p.addQuadCurve(to: P(0.60, 0.76), control: P(0.50, 0.74))   // barriga
            p.addLine(to: P(0.62, 0.97))                                // cauda
            p.addLine(to: P(0.72, 0.95))
            p.addLine(to: P(0.70, 0.72))
            p.addQuadCurve(to: P(0.74, 0.28), control: P(0.78, 0.52))   // costas
            p.addQuadCurve(to: P(0.56, 0.10), control: P(0.76, 0.04))   // nuca
            p.closeSubpath()
            rectN(0.54, 0.74, 0.035, 0.09)                              // pata
            rectN(0.26, 0.82, 0.74, 0.04)                               // galho

        case .machuPicchu:
            // Huayna Picchu (pico icônico) + pico menor + terraços.
            p.move(to: P(0.12, 1.0))
            p.addQuadCurve(to: P(0.52, 0.05), control: P(0.30, 0.42))
            p.addQuadCurve(to: P(0.82, 1.0), control: P(0.68, 0.42))
            p.closeSubpath()
            p.move(to: P(0.70, 1.0))          // pico menor
            p.addQuadCurve(to: P(0.90, 0.52), control: P(0.80, 0.62))
            p.addQuadCurve(to: P(1.0, 1.0), control: P(0.98, 0.66))
            p.closeSubpath()
            // Terraços escalonados à esquerda.
            rectN(0.0, 0.90, 0.26, 0.10)
            rectN(0.03, 0.82, 0.20, 0.08)
            rectN(0.06, 0.75, 0.15, 0.07)

        case .palacioSalvo:
            // Corpo com ombros + torre + coroa bulbosa.
            rectN(0.28, 0.36, 0.44, 0.64)     // corpo
            rectN(0.16, 0.56, 0.14, 0.44)     // ombro esquerdo
            rectN(0.70, 0.56, 0.14, 0.44)     // ombro direito
            rectN(0.36, 0.20, 0.28, 0.18)     // torre
            rectN(0.32, 0.30, 0.06, 0.10)     // torrinha esq.
            rectN(0.62, 0.30, 0.06, 0.10)     // torrinha dir.
            p.move(to: P(0.38, 0.20))         // coroa bulbosa
            p.addQuadCurve(to: P(0.62, 0.20), control: P(0.50, 0.02))
            p.closeSubpath()
            rectN(0.488, 0.0, 0.024, 0.14)    // agulha (encosta na coroa)
        }
        return p
    }
}
