//
//  LandmarkGalleryTests.swift
//  vamosPraOndeAppTests
//
//  Diagnóstico visual: renderiza as capas com marco em PNG para inspeção.
//  (Utilitário de desenvolvimento; as imagens vão para uma pasta temporária.)
//

import Testing
import SwiftUI
@testable import vamosPraOndeApp

@MainActor
struct LandmarkGalleryTests {
    @Test func renderGallery() throws {
        let dir = URL(fileURLWithPath: "/tmp/vpo_landmarks")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let cities = ["Paris", "Rio de Janeiro", "Roma", "Londres", "Tóquio",
                      "Barcelona", "Nova York", "Buenos Aires", "Cairo",
                      "Sydney", "Lisboa", "Dubai", "Miami"]
        for city in cities {
            let view = ProceduralCover(
                seed: city,
                style: CoverStyle(palette: 0, scene: .mountains),
                city: city
            )
            .frame(width: 600, height: 400)
            let renderer = ImageRenderer(content: view)
            renderer.scale = 1
            if let ui = renderer.uiImage, let data = ui.pngData() {
                try? data.write(to: dir.appendingPathComponent("\(city).png"))
            }
        }
        #expect(true)
    }
}
