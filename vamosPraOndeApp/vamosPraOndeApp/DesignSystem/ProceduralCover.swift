//
//  ProceduralCover.swift
//  vamosPraOndeApp
//
//  Capa "arte gráfica" gerada por código, sempre na paleta do app.
//  Cada destino recebe uma cena determinística a partir de uma seed
//  (id/nome), então a mesma viagem sempre mostra a mesma arte, mas
//  cada destino fica visualmente único. Substitui as fotos de banco
//  (Unsplash/Wikipedia) como capa padrão.
//
//  Também é a base do "banco de imagens": `ProceduralCover(style:)`
//  permite escolher uma paleta/cena específica na personalização.
//

import SwiftUI

// MARK: - Gerador pseudoaleatório determinístico (SplitMix64)

/// PRNG estável: mesma seed → mesma sequência. Assim a capa de um destino
/// nunca "muda sozinha" entre aberturas de tela ou reinícios do app.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: String) {
        // Hash FNV-1a da string para uma seed de 64 bits.
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in seed.utf8 {
            hash = (hash ^ UInt64(byte)) &* 0x100000001b3
        }
        state = hash == 0 ? 0x9E3779B97F4A7C15 : hash
    }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

// MARK: - Paleta da capa

/// Conjunto de cores de uma capa: céu (gradiente), astro (sol/lua),
/// névoa do horizonte e as camadas de silhueta (do fundo para a frente).
struct CoverPalette {
    let sky: [UInt]        // paradas do gradiente, de cima para baixo
    let celestial: UInt    // sol ou lua
    let haze: UInt         // névoa quente/fria junto ao horizonte
    let ridges: [UInt]     // silhuetas, do fundo (mais clara) à frente (mais escura)

    static let all: [CoverPalette] = [
        // Pôr do sol — a assinatura do app.
        CoverPalette(sky: [0xF7CE9E, 0xEC9E66, 0xC0552F, 0x7E3626],
                     celestial: 0xFBE9C6, haze: 0xF2B98A,
                     ridges: [0x8A3A28, 0x5A2A20, 0x3E1C16]),
        // Alvorada — mais clara e rosada.
        CoverPalette(sky: [0xFDEBCF, 0xF7CE9E, 0xE8A488, 0xC86A4A],
                     celestial: 0xFFF3DC, haze: 0xF5CBA8,
                     ridges: [0x9A4A34, 0x6E3324, 0x47201A]),
        // Crepúsculo teal — céu do horizonte esverdeado caindo no quente.
        CoverPalette(sky: [0x2E7E72, 0x5E9384, 0xC99A6A, 0xB0532F],
                     celestial: 0xF3D9A8, haze: 0xE0A15C,
                     ridges: [0x1C4A44, 0x143A36, 0x0E2A28]),
        // Noite — teal profundo com lua pálida.
        CoverPalette(sky: [0x12333A, 0x1D4A4A, 0x3A5A4E, 0x5A4638],
                     celestial: 0xE8D6A0, haze: 0x2E4E48,
                     ridges: [0x17332E, 0x102420, 0x0A1815]),
        // Tropical — céu quente mergulhando no mar teal.
        CoverPalette(sky: [0xF7D89E, 0xF0B36A, 0x5AA595, 0x1F6C60],
                     celestial: 0xFFF0CC, haze: 0x6FB3A2,
                     ridges: [0x15564C, 0x0F433B, 0x09302A]),
    ]
}

/// Arquétipos de cena (a "arte gráfica" propriamente dita).
enum CoverScene: CaseIterable {
    case mountains  // picos angulares
    case dunes      // colinas suaves
    case sea        // ondas do mar
    case skyline    // silhueta de cidade
}

/// Estilo escolhível no banco de imagens: paleta + cena.
struct CoverStyle: Hashable {
    var palette: Int
    var scene: CoverScene

    /// Todas as combinações (paleta × cena) para a grade do banco de imagens.
    static var bank: [CoverStyle] {
        CoverPalette.all.indices.flatMap { p in
            CoverScene.allCases.map { CoverStyle(palette: p, scene: $0) }
        }
    }
}

// MARK: - Receita determinística a partir da seed

private struct CoverRecipe {
    let palette: CoverPalette
    let scene: CoverScene
    let celestialX: CGFloat   // 0…1 na largura
    let celestialY: CGFloat   // 0…1 na altura (terço superior)
    let celestialR: CGFloat   // raio relativo a min(w,h)
    let layers: [[CGFloat]]   // parâmetros por camada de silhueta

    init(seed: String, forcedStyle: CoverStyle?) {
        var rng = SeededGenerator(seed: seed)
        let paletteIndex = forcedStyle?.palette ?? Int.random(in: CoverPalette.all.indices, using: &rng)
        palette = CoverPalette.all[paletteIndex]
        scene = forcedStyle?.scene ?? CoverScene.allCases.randomElement(using: &rng)!

        celestialX = CGFloat.random(in: 0.15...0.85, using: &rng)
        celestialY = CGFloat.random(in: 0.20...0.42, using: &rng)
        celestialR = CGFloat.random(in: 0.10...0.17, using: &rng)

        let layerCount = 3
        var built: [[CGFloat]] = []
        for i in 0..<layerCount {
            switch scene {
            case .mountains:
                // Uma lista de alturas de pico por camada.
                let count = Int.random(in: 5...8, using: &rng)
                let base: CGFloat = 0.30 + CGFloat(i) * 0.16
                built.append((0..<count).map { _ in
                    min(0.95, base + CGFloat.random(in: -0.12...0.14, using: &rng))
                })
            case .dunes, .sea:
                // [baseline, amplitude, frequência, fase]
                let baseline: CGFloat = (scene == .sea ? 0.52 : 0.44) + CGFloat(i) * 0.15
                let amp: CGFloat = (scene == .sea ? 0.05 : 0.07) + CGFloat.random(in: 0...0.04, using: &rng)
                let freq: CGFloat = (scene == .sea ? 2.4 : 1.1) + CGFloat.random(in: 0...1.2, using: &rng)
                let phase = CGFloat.random(in: 0...1, using: &rng)
                built.append([baseline, amp, freq, phase])
            case .skyline:
                // [baseline] + alturas dos prédios.
                let baseline: CGFloat = 0.55 + CGFloat(i) * 0.14
                let count = Int.random(in: 7...12, using: &rng)
                var heights = [baseline]
                heights += (0..<count).map { _ in CGFloat.random(in: 0.10...0.42, using: &rng) }
                built.append(heights)
            }
        }
        layers = built
    }
}

// MARK: - Formas

/// Silhueta de picos angulares. Cada valor é a altura relativa (0 = topo).
struct MountainSilhouette: Shape {
    var peaks: [CGFloat]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard peaks.count > 1 else { return path }
        let step = rect.width / CGFloat(peaks.count - 1)
        path.move(to: CGPoint(x: 0, y: rect.height))
        for (index, peak) in peaks.enumerated() {
            path.addLine(to: CGPoint(x: step * CGFloat(index), y: rect.height * peak))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

/// Colinas/ondas suaves via senoide. Serve para dunas (baixa frequência) e
/// mar (alta frequência).
struct HillsShape: Shape {
    var baseline: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let samples = 48
        path.move(to: CGPoint(x: 0, y: rect.height))
        for i in 0...samples {
            let t = CGFloat(i) / CGFloat(samples)
            let x = t * rect.width
            let wave = sin((t * frequency + phase) * 2 * .pi) * amplitude
            let y = rect.height * baseline - wave * rect.height
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

/// Silhueta de cidade: prédios de alturas variadas sobre uma linha de rua.
struct SkylineShape: Shape {
    /// Primeiro valor é o baseline (rua); os demais são alturas de prédio.
    var params: [CGFloat]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard params.count > 1 else { return path }
        let baseline = rect.height * params[0]
        let heights = Array(params.dropFirst())
        let bw = rect.width / CGFloat(heights.count)

        path.move(to: CGPoint(x: 0, y: rect.height))
        for (i, h) in heights.enumerated() {
            let xL = CGFloat(i) * bw
            let xR = xL + bw
            let topY = baseline - h * rect.height
            path.addLine(to: CGPoint(x: xL, y: topY))
            path.addLine(to: CGPoint(x: xR, y: topY))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Capa procedural

struct ProceduralCover: View {
    /// Seed determinística (ex.: id do destino, ou o nome como fallback).
    var seed: String = "vamos-pra-onde"
    /// Estilo fixo (do banco de imagens). Quando `nil`, deriva tudo da seed.
    var style: CoverStyle? = nil

    var body: some View {
        let recipe = CoverRecipe(seed: seed, forcedStyle: style)
        let sky = recipe.palette.sky.map { Color(hex: $0) }

        GeometryReader { geo in
            let size = geo.size
            let unit = min(size.width, size.height)

            ZStack {
                // Céu
                LinearGradient(colors: sky, startPoint: .top, endPoint: .bottom)

                // Brilho do astro
                let cx = recipe.celestialX * size.width
                let cy = recipe.celestialY * size.height
                let r = recipe.celestialR * unit
                RadialGradient(
                    colors: [Color(hex: recipe.palette.celestial).opacity(0.55), .clear],
                    center: UnitPoint(x: recipe.celestialX, y: recipe.celestialY),
                    startRadius: 0,
                    endRadius: r * 3.2
                )

                // Sol/lua
                Circle()
                    .fill(Color(hex: recipe.palette.celestial))
                    .frame(width: r * 2, height: r * 2)
                    .position(x: cx, y: cy)

                // Névoa do horizonte para dar profundidade
                LinearGradient(
                    colors: [.clear, Color(hex: recipe.palette.haze).opacity(0.5)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Camadas de silhueta (fundo → frente), cada uma mais escura.
                ForEach(Array(recipe.layers.enumerated()), id: \.offset) { index, params in
                    sceneShape(scene: recipe.scene, params: params)
                        .fill(Color(hex: recipe.palette.ridges[min(index, recipe.palette.ridges.count - 1)])
                            .opacity(index == 0 ? 0.55 : 1))
                }
            }
        }
        .clipped()
    }

    private func sceneShape(scene: CoverScene, params: [CGFloat]) -> AnyShape {
        switch scene {
        case .mountains:
            AnyShape(MountainSilhouette(peaks: params))
        case .dunes, .sea:
            AnyShape(HillsShape(baseline: params[0], amplitude: params[1],
                                frequency: params[2], phase: params[3]))
        case .skyline:
            AnyShape(SkylineShape(params: params))
        }
    }
}

// MARK: - Capa por destino

extension Destination {
    /// Seed estável da capa: usa o id do Firestore quando existe, senão o nome.
    var coverSeed: String { id ?? title }

    /// Capa procedural determinística deste destino.
    var cover: ProceduralCover { ProceduralCover(seed: coverSeed) }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(["Paris", "Tóquio", "Barcelona", "Rio", "Lisboa", "Cairo"], id: \.self) { city in
                ProceduralCover(seed: city)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(alignment: .bottomLeading) {
                        Text(city).font(.title.bold()).foregroundStyle(.white).padding()
                    }
            }
        }
        .padding()
    }
    .background(Color.vpoSand)
}
