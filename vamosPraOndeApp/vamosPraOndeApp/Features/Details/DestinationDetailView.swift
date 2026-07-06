//
//  DestinationDetailView.swift
//  vamosPraOndeApp
//
//  Detalhes de um destino: capa, contagem regressiva, mapa e excluir.
//

import SwiftUI
import MapKit

struct DestinationDetailView: View {
    private let initial: Destination
    @ObservedObject var repository: DestinationsRepository

    @EnvironmentObject private var userLocation: UserLocationProvider
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirm = false
    @State private var showingEdit = false
    @State private var showingChecklist = false
    @State private var isDeleting = false
    @State private var weather: DestinationWeather?
    @State private var tripForecast: TripDayForecast?
    @State private var weatherFailed = false
    @State private var destinationTimeZone: TimeZone?
    @State private var photo: DestinationPhoto?
    @State private var nearbyCategory: NearbyCategory = .attractions
    @State private var nearbyPlaces: [NearbyPlace] = []
    @State private var nearbyLoading = false
    @State private var shareImage: UIImage?
    @Environment(\.openURL) private var openURL

    init(destination: Destination, repository: DestinationsRepository) {
        self.initial = destination
        _repository = ObservedObject(wrappedValue: repository)
    }

    /// Destino "vivo": reflete edições feitas em tempo real (via listener).
    private var destination: Destination {
        repository.destinations.first { $0.id == initial.id } ?? initial
    }

    private var countdown: Countdown? { destination.date.map { Countdown(to: $0) } }

    var body: some View {
        ZStack {
            Color.vpoSand.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    cover
                    countdownBlock
                    checklistCard
                    if let notes = destination.notes, !notes.isEmpty {
                        notesCard(notes)
                    }
                    weatherCard
                    if destinationTimeZone != nil {
                        timeZoneCard
                    }
                    nearbyCard
                    deleteButton
                }
                .padding(.bottom, Spacing.xl)
            }
            .ignoresSafeArea(edges: .top)
        }
        .task(id: destination.id) { await loadWeather() }
        .task(id: destination.id) {
            let found = await DestinationPhotoProvider.photo(
                city: destination.cityName, subtitle: destination.subtitle
            )
            photo = found
            if let found { DestinationPhotoProvider.trackUsage(found) }
        }
        .task { userLocation.request() }
        .task(id: nearbyLoadKey) { await loadNearby() }
        .task(id: destination.id) {
            // Cartão de compartilhamento (renderizado uma vez por destino).
            let renderer = ImageRenderer(content: CountdownShareCard(destination: destination))
            renderer.scale = 3
            shareImage = renderer.uiImage
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingEdit) {
            NewDestinationView(repository: repository, editing: destination)
        }
        .sheet(isPresented: $showingChecklist) {
            ChecklistView(destination: destination, repository: repository)
        }
        .confirmationDialog(
            "Excluir este destino?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Excluir", role: .destructive, action: delete)
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Você deixará de contar os dias para \(destination.cityName).")
        }
    }

    @ViewBuilder
    private var coverBackground: some View {
        if let photo {
            AsyncImage(url: photo.url, transaction: Transaction(animation: .easeIn(duration: 0.4))) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .overlay(
                            LinearGradient(
                                colors: [.black.opacity(0.05), .black.opacity(0.55)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                case .empty:
                    SunsetCover().overlay(ProgressView().tint(.vpoOnColor))
                default:
                    SunsetCover()
                }
            }
        } else {
            SunsetCover()
        }
    }

    private var cover: some View {
        // Container de tamanho fixo: a imagem (scaledToFill) fica num overlay e
        // é recortada, sem esticar o frame da capa para a largura da foto.
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .overlay { coverBackground }
            .clipped()
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("o seu destino")
                        .font(AppFont.overline(11))
                        .kerning(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(Color(hex: 0xFBE9C6))
                    Text(destination.cityName)
                        .font(AppFont.display(44))
                        .foregroundStyle(Color.vpoOnColor)
                    if !destination.subtitle.isEmpty {
                        Text(destination.subtitle)
                            .font(AppFont.medium(14))
                            .foregroundStyle(Color.vpoOnColor.opacity(0.9))
                    }
                }
                .padding(Spacing.lg)
            }
            .overlay(alignment: .topLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.vpoOnColor)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Voltar")
                .padding(.leading, Spacing.lg)
                .padding(.top, 56)
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: Spacing.sm) {
                    if let shareImage {
                        ShareLink(
                            item: Image(uiImage: shareImage),
                            preview: SharePreview(
                                "Contagem para \(destination.cityName)",
                                image: Image(uiImage: shareImage)
                            )
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.vpoOnColor)
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
                        .accessibilityLabel("Compartilhar contagem")
                    }
                    Button { showingEdit = true } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.vpoOnColor)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .accessibilityLabel("Editar destino")
                }
                .padding(.trailing, Spacing.lg)
                .padding(.top, 56)
            }
            .overlay(alignment: .bottomTrailing) { photoCredit }
    }

    /// Crédito do autor da foto (obrigatório para o Unsplash).
    @ViewBuilder
    private var photoCredit: some View {
        if let photo {
            let label = photo.creditName.map { "\($0) · \(photo.sourceLabel)" } ?? photo.sourceLabel
            Button {
                if let url = photo.creditURL { openURL(url) }
            } label: {
                Text(label)
                    .font(AppFont.medium(10))
                    .foregroundStyle(Color.vpoOnColor.opacity(0.9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.28), in: Capsule())
            }
            .disabled(photo.creditURL == nil)
            .padding(.trailing, Spacing.sm)
            .padding(.bottom, Spacing.sm)
            .accessibilityLabel("Foto de \(label)")
        }
    }

    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("Anotações", systemImage: "note.text")
                .font(AppFont.title(16))
                .foregroundStyle(Color.vpoInk)
            Text(notes)
                .font(AppFont.body(15))
                .foregroundStyle(Color.vpoInkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.md)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .padding(.horizontal, Spacing.lg)
    }

    @ViewBuilder
    private var countdownBlock: some View {
        VStack(spacing: 2) {
            if let countdown, let date = destination.date {
                Text(countdown.isPast ? "essa viagem já rolou" : "faltam")
                    .font(AppFont.overline())
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.vpoInkSoft)
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(countdown.value)
                        .font(AppFont.countdown(60))
                        .foregroundStyle(Color.vpoTerracotta)
                    if !countdown.unit.isEmpty {
                        Text(countdown.unit)
                            .font(AppFont.semibold(20))
                            .foregroundStyle(Color.vpoInk)
                    }
                }
                Text(DateStyle.long.string(from: date))
                    .font(AppFont.medium(14))
                    .foregroundStyle(Color.vpoInkSoft)
            } else {
                Text("na sua lista")
                    .font(AppFont.overline())
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.vpoInkSoft)
                HStack(spacing: 10) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 34))
                    Text("quero visitar")
                        .font(AppFont.display(34))
                }
                .foregroundStyle(Color.vpoTerracotta)
                Text("marque uma data quando decidir embarcar")
                    .font(AppFont.medium(14))
                    .foregroundStyle(Color.vpoInkSoft)
            }

            if let meters = userLocation.distance(to: destination.coordinate) {
                Label("a \(DistanceFormat.string(meters: meters)) de você", systemImage: "location.fill")
                    .font(AppFont.semibold(13))
                    .foregroundStyle(Color.vpoTeal)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(countdownAccessibilityLabel)
    }

    private var countdownAccessibilityLabel: String {
        var label: String
        if let countdown, let date = destination.date {
            label = "\(countdown.phrase), em \(DateStyle.long.string(from: date))."
        } else {
            label = "Quero visitar \(destination.cityName)."
        }
        if let meters = userLocation.distance(to: destination.coordinate) {
            label += " A \(DistanceFormat.string(meters: meters)) de você."
        }
        return label
    }

    private var checklistCard: some View {
        Button { showingChecklist = true } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: "suitcase.rolling.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.vpoOnColor)
                    .frame(width: 52, height: 52)
                    .background(Color.vpoTerracotta)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mala e preparativos")
                        .font(AppFont.title(16))
                        .foregroundStyle(Color.vpoInk)
                    Text((destination.checklist ?? []).progressPhrase)
                        .font(AppFont.medium(13))
                        .foregroundStyle(Color.vpoInkSoft)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.vpoInkSoft)
            }
            .padding(Spacing.md)
            .background(Color.vpoCream)
            .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .padding(.horizontal, Spacing.lg)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Mala e preparativos: \((destination.checklist ?? []).progressPhrase)")
    }

    private var weatherCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.md) {
                Image(systemName: weather?.symbolName ?? "cloud.sun.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.vpoOnColor)
                    .frame(width: 52, height: 52)
                    .background(Color.vpoTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Clima agora")
                        .font(AppFont.title(16))
                        .foregroundStyle(Color.vpoInk)
                    if let weather {
                        Text(weather.description)
                            .font(AppFont.medium(13))
                            .foregroundStyle(Color.vpoInkSoft)
                    } else if weatherFailed {
                        Text("indisponível no momento")
                            .font(AppFont.medium(13))
                            .foregroundStyle(Color.vpoInkSoft)
                    } else {
                        Text("carregando…")
                            .font(AppFont.medium(13))
                            .foregroundStyle(Color.vpoInkSoft)
                    }
                }

                Spacer()

                if let weather {
                    Text(weather.temperature)
                        .font(AppFont.countdown(30))
                        .foregroundStyle(Color.vpoTeal)
                } else if !weatherFailed {
                    ProgressView().tint(.vpoTeal)
                }
            }

            if let tripForecast {
                Divider()
                    .padding(.vertical, Spacing.sm)
                HStack(spacing: Spacing.sm) {
                    Image(systemName: tripForecast.symbolName)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.vpoTeal)
                        .frame(width: 22)
                    Text("No dia da viagem")
                        .font(AppFont.semibold(14))
                        .foregroundStyle(Color.vpoInk)
                    Spacer()
                    Text("\(tripForecast.high) / \(tripForecast.low) · \(tripForecast.description.lowercased())")
                        .font(AppFont.medium(13))
                        .foregroundStyle(Color.vpoInkSoft)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .padding(.horizontal, Spacing.lg)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(weatherAccessibilityLabel)
    }

    private var timeZoneCard: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "clock.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.vpoOnColor)
                .frame(width: 52, height: 52)
                .background(Color.vpoGold)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("Hora local em \(destination.cityName)")
                    .font(AppFont.title(16))
                    .foregroundStyle(Color.vpoInk)
                if let tz = destinationTimeZone {
                    Text(TimeZoneService.differencePhrase(tz))
                        .font(AppFont.medium(13))
                        .foregroundStyle(Color.vpoInkSoft)
                }
            }

            Spacer()

            if let tz = destinationTimeZone {
                TimelineView(.everyMinute) { context in
                    Text(timeString(context.date, in: tz))
                        .font(AppFont.countdown(26))
                        .foregroundStyle(Color.vpoGold)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .padding(.horizontal, Spacing.lg)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(timeZoneAccessibilityLabel)
    }

    // MARK: - Por perto (MKLocalSearch)

    /// Recarrega quando muda o destino ou a categoria escolhida.
    private var nearbyLoadKey: String {
        "\(destination.id ?? "")-\(nearbyCategory.rawValue)"
    }

    private func loadNearby() async {
        nearbyLoading = true
        nearbyPlaces = await NearbyPlacesService.search(
            near: destination.coordinate, category: nearbyCategory
        )
        nearbyLoading = false
    }

    private var nearbyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Por perto", systemImage: "binoculars.fill")
                .font(AppFont.title(16))
                .foregroundStyle(Color.vpoInk)

            HStack(spacing: Spacing.sm) {
                ForEach(NearbyCategory.allCases) { category in
                    nearbyChip(category)
                }
            }

            if nearbyLoading {
                ProgressView()
                    .tint(.vpoTeal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
            } else if nearbyPlaces.isEmpty {
                Text("Nada encontrado por aqui.")
                    .font(AppFont.medium(14))
                    .foregroundStyle(Color.vpoInkSoft)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, Spacing.sm)
            } else {
                nearbyMap
                VStack(spacing: 0) {
                    ForEach(nearbyPlaces) { place in
                        nearbyRow(place)
                        if place.id != nearbyPlaces.last?.id {
                            Divider().padding(.leading, 40)
                        }
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.vpoCream)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .padding(.horizontal, Spacing.lg)
        .animation(.easeInOut(duration: 0.25), value: nearbyPlaces.map(\.id))
    }

    /// Mini-mapa com os lugares encontrados + o pino do destino.
    /// `.id` força recriação quando a lista muda, re-enquadrando a câmera.
    private var nearbyMap: some View {
        Map(initialPosition: .automatic) {
            Marker(destination.cityName, coordinate: destination.coordinate)
                .tint(Color.vpoTerracotta)
            ForEach(nearbyPlaces) { place in
                Marker(
                    place.name,
                    systemImage: NearbyPlacesService.symbol(for: place.category),
                    coordinate: place.coordinate
                )
                .tint(Color.vpoTeal)
            }
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        .allowsHitTesting(false)
        .id(nearbyLoadKey + "-\(nearbyPlaces.count)")
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Mapa com \(nearbyPlaces.count) lugares perto de \(destination.cityName)")
    }

    private func nearbyChip(_ category: NearbyCategory) -> some View {
        let selected = nearbyCategory == category
        return Button {
            Haptics.tap()
            nearbyCategory = category
        } label: {
            Label(category.rawValue, systemImage: category.symbol)
                .font(AppFont.semibold(13))
                .foregroundStyle(selected ? Color.vpoOnColor : Color.vpoInkSoft)
                .padding(.vertical, 7)
                .padding(.horizontal, Spacing.sm)
                .background(selected ? Color.vpoTeal : Color.vpoSand, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func nearbyRow(_ place: NearbyPlace) -> some View {
        Button {
            place.openInMaps()
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: NearbyPlacesService.symbol(for: place.category))
                    .font(.system(size: 16))
                    .foregroundStyle(Color.vpoTeal)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 1) {
                    Text(place.name)
                        .font(AppFont.medium(15))
                        .foregroundStyle(Color.vpoInk)
                        .lineLimit(1)
                    if let distance = place.distance {
                        Text("a \(DistanceFormat.short(meters: distance))")
                            .font(AppFont.medium(12))
                            .foregroundStyle(Color.vpoInkSoft)
                    }
                }
                Spacer()
                Image(systemName: "arrow.up.forward.app")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.vpoInkSoft)
            }
            .padding(.vertical, Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(place.name), a \(place.distance.map { DistanceFormat.short(meters: $0) } ?? ""). Abrir no Mapas.")
    }

    private static let localTime: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "HH:mm"
        return f
    }()

    private func timeString(_ date: Date, in timeZone: TimeZone) -> String {
        let formatter = Self.localTime
        formatter.timeZone = timeZone
        return formatter.string(from: date)
    }

    private var timeZoneAccessibilityLabel: String {
        guard let tz = destinationTimeZone else { return "" }
        return "Hora local em \(destination.cityName): \(timeString(Date(), in: tz)), \(TimeZoneService.differencePhrase(tz))."
    }

    private var weatherAccessibilityLabel: String {
        if let weather {
            return "Clima agora em \(destination.cityName): \(weather.temperature), \(weather.description)."
        }
        return weatherFailed ? "Clima indisponível no momento." : "Carregando o clima."
    }

    private func loadWeather() async {
        weather = nil
        tripForecast = nil
        weatherFailed = false
        async let timeZoneTask = TimeZoneService.timeZone(for: destination.coordinate)
        do {
            weather = try await WeatherProvider.current(for: destination.coordinate)
            // Previsão para o dia da viagem (janela de ~10 dias do WeatherKit).
            if let date = destination.date, let days = countdown?.days, days >= 0, days <= 9 {
                tripForecast = try? await WeatherProvider.forecast(
                    for: destination.coordinate, on: date
                )
            }
        } catch {
            print("⚠️ WeatherKit falhou: \(error.localizedDescription) — \(error)")
            weatherFailed = true
        }
        destinationTimeZone = await timeZoneTask
    }

    private var deleteButton: some View {
        Button {
            showingDeleteConfirm = true
        } label: {
            if isDeleting {
                ProgressView().tint(.vpoTerracotta)
            } else {
                Label("Excluir destino", systemImage: "trash")
            }
        }
        .buttonStyle(OutlineButtonStyle())
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
    }

    private func delete() {
        Haptics.warning()
        isDeleting = true
        let id = destination.id
        Task {
            try? await repository.delete(destination)
            if let id { NotificationService.cancel(for: id) }
            dismiss()
        }
    }
}
