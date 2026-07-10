//
//  DestinationCover.swift
//  vamosPraOndeApp
//
//  Capa procedural por destino. Vive num arquivo próprio (e não no
//  ProceduralCover.swift) porque Destination depende do Firebase e o
//  ProceduralCover também compila no Apple Watch, que não o tem.
//

import SwiftUI

extension Destination {
    /// Seed estável da capa: usa o id do Firestore quando existe, senão o nome.
    var coverSeed: String { id ?? title }

    /// Capa procedural do destino: usa o estilo escolhido pelo usuário
    /// (banco de imagens) ou, quando `nil`, deriva um estilo da seed. A
    /// cidade entra para desenhar o marco icônico quando reconhecida.
    var cover: ProceduralCover {
        ProceduralCover(seed: coverSeed, style: coverStyle, city: cityName)
    }
}
