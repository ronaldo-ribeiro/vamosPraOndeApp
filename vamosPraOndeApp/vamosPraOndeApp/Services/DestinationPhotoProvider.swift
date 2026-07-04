//
//  DestinationPhotoProvider.swift
//  vamosPraOndeApp
//
//  Descobre uma foto de capa para o destino.
//  - Se houver uma chave do Unsplash em Info.plist (UnsplashAccessKey),
//    usa o Unsplash (fotos de viagem mais bonitas).
//  - Senão, usa a Wikipedia (grátis, sem cadastro).
//  Retorna nil quando não encontra nada — a UI cai no gradiente padrão.
//

import Foundation

enum DestinationPhotoProvider {
    /// Cache em memória por consulta, para não repetir a rede ao reabrir a tela.
    private static var cache: [String: URL?] = [:]

    private static var unsplashKey: String {
        let key = Bundle.main.object(forInfoDictionaryKey: "UnsplashAccessKey") as? String
        return (key ?? "").trimmingCharacters(in: .whitespaces)
    }

    /// - Parameters:
    ///   - city: nome da cidade (ex.: "Paris")
    ///   - subtitle: complemento para a busca no Unsplash (ex.: "França")
    static func imageURL(city: String, subtitle: String) async -> URL? {
        let cacheKey = city.lowercased()
        if let cached = cache[cacheKey] { return cached }

        var url: URL?
        if unsplashKey.isEmpty {
            url = await wikipediaImage(for: city)
        } else {
            let query = [city, subtitle].filter { !$0.isEmpty }.joined(separator: " ")
            url = await unsplashImage(query: query)
            if url == nil {
                url = await wikipediaImage(for: city)
            }
        }
        cache[cacheKey] = url
        return url
    }

    // MARK: - Wikipedia (sem chave)

    private static func wikipediaImage(for city: String) async -> URL? {
        // Tenta pt.wikipedia e depois en.wikipedia.
        for lang in ["pt", "en"] {
            if let url = await wikipediaSummaryImage(city: city, lang: lang) {
                return url
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

    private static func unsplashImage(query: String) async -> URL? {
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
            if let raw = result.results.first?.urls.regular {
                return URL(string: raw)
            }
        } catch {
            return nil
        }
        return nil
    }

    private struct UnsplashSearch: Decodable {
        struct Photo: Decodable {
            struct URLs: Decodable { let regular: String }
            let urls: URLs
        }
        let results: [Photo]
    }
}
