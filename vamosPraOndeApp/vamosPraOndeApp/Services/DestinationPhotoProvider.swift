//
//  DestinationPhotoProvider.swift
//  vamosPraOndeApp
//
//  Descobre uma foto de capa para o destino.
//  - Se houver uma chave do Unsplash em Info.plist (UnsplashAccessKey),
//    usa o Unsplash (fotos de viagem mais bonitas) com o crédito do autor.
//  - Senão, usa a Wikipedia (grátis, sem cadastro).
//  Retorna nil quando não encontra nada — a UI cai no gradiente padrão.
//

import Foundation

/// Foto de capa + dados de crédito (exigidos pelas regras do Unsplash).
struct DestinationPhoto: Equatable {
    let url: URL
    let creditName: String?     // nome do fotógrafo (Unsplash)
    let creditURL: URL?         // link do perfil do fotógrafo
    let sourceLabel: String     // "Unsplash" ou "Wikipedia"
    let downloadLocation: URL?  // endpoint para registrar o uso (Unsplash)
}

enum DestinationPhotoProvider {
    /// Cache em memória por consulta, para não repetir a rede ao reabrir a tela.
    private static var cache: [String: DestinationPhoto?] = [:]

    private static var unsplashKey: String {
        // Chave fora do Git: Secrets.plist (não versionado). Fallback: Info.plist.
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let dict = NSDictionary(contentsOf: url),
           let key = (dict["UnsplashAccessKey"] as? String)?.trimmingCharacters(in: .whitespaces),
           !key.isEmpty {
            return key
        }
        let key = Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String
        return (key ?? "").trimmingCharacters(in: .whitespaces)
    }

    static var usesUnsplash: Bool { !unsplashKey.isEmpty }

    /// - Parameters:
    ///   - city: nome da cidade (ex.: "Paris")
    ///   - subtitle: complemento para a busca no Unsplash (ex.: "França")
    static func photo(city: String, subtitle: String) async -> DestinationPhoto? {
        let cacheKey = city.lowercased()
        if let cached = cache[cacheKey] { return cached }

        var result: DestinationPhoto?
        if unsplashKey.isEmpty {
            result = await wikipediaPhoto(for: city)
        } else {
            let query = [city, subtitle].filter { !$0.isEmpty }.joined(separator: " ")
            result = await unsplashPhoto(query: query)
            if result == nil {
                result = await wikipediaPhoto(for: city)
            }
        }
        cache[cacheKey] = result
        return result
    }

    /// Regra do Unsplash: ao efetivamente usar uma foto, disparar um GET no
    /// `download_location`. Só vale para fotos do Unsplash.
    static func trackUsage(_ photo: DestinationPhoto) {
        guard let location = photo.downloadLocation, !unsplashKey.isEmpty else { return }
        var request = URLRequest(url: location)
        request.setValue("Client-ID \(unsplashKey)", forHTTPHeaderField: "Authorization")
        Task { _ = try? await URLSession.shared.data(for: request) }
    }

    // MARK: - Wikipedia (sem chave)

    private static func wikipediaPhoto(for city: String) async -> DestinationPhoto? {
        for lang in ["pt", "en"] {
            if let url = await wikipediaSummaryImage(city: city, lang: lang) {
                return DestinationPhoto(
                    url: url, creditName: nil, creditURL: nil,
                    sourceLabel: "Wikipedia", downloadLocation: nil
                )
            }
        }
        return nil
    }

    private static func wikipediaSummaryImage(city: String, lang: String) async -> URL? {
        let title = city.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? city
        guard let url = URL(string: "https://\(lang).wikipedia.org/api/rest_v1/page/summary/\(title)") else {
            return nil
        }
        do {
            var request = URLRequest(url: url)
            request.setValue("vamosPraOndeApp/1.1 (contato: app)", forHTTPHeaderField: "User-Agent")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            let summary = try JSONDecoder().decode(WikiSummary.self, from: data)
            if let original = summary.originalimage?.source, let u = URL(string: original) {
                return u
            }
            if let thumb = summary.thumbnail?.source, let u = URL(string: thumb) {
                return u
            }
        } catch {
            return nil
        }
        return nil
    }

    private struct WikiSummary: Decodable {
        struct Image: Decodable { let source: String }
        let thumbnail: Image?
        let originalimage: Image?
    }

    // MARK: - Unsplash (com chave opcional)

    private static func unsplashPhoto(query: String) async -> DestinationPhoto? {
        guard
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://api.unsplash.com/search/photos?query=\(encoded)&orientation=landscape&per_page=1&content_filter=high")
        else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(unsplashKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            let result = try JSONDecoder().decode(UnsplashSearch.self, from: data)
            guard let photo = result.results.first, let imageURL = URL(string: photo.urls.regular) else {
                return nil
            }
            // Link do perfil com os parâmetros de referral exigidos pelo Unsplash.
            let profile = photo.user.links.html + "?utm_source=vamos_pra_onde&utm_medium=referral"
            return DestinationPhoto(
                url: imageURL,
                creditName: photo.user.name,
                creditURL: URL(string: profile),
                sourceLabel: "Unsplash",
                downloadLocation: URL(string: photo.links.downloadLocation)
            )
        } catch {
            return nil
        }
    }

    private struct UnsplashSearch: Decodable {
        struct Photo: Decodable {
            struct URLs: Decodable { let regular: String }
            struct User: Decodable {
                struct Links: Decodable { let html: String }
                let name: String
                let links: Links
            }
            struct Links: Decodable {
                let downloadLocation: String
                enum CodingKeys: String, CodingKey { case downloadLocation = "download_location" }
            }
            let urls: URLs
            let user: User
            let links: Links
        }
        let results: [Photo]
    }
}
