//
//  DestinationsRepository.swift
//  vamosPraOndeApp
//
//  Acesso aos destinos do usuário no Firestore, em /users/{uid}/destinations.
//

import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class DestinationsRepository: ObservableObject {
    @Published private(set) var destinations: [Destination] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var collection: CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid).collection("destinations")
    }

    /// Começa a ouvir os destinos do usuário em tempo real.
    /// Não ordenamos no servidor porque destinos "quero visitar" não têm data
    /// (o Firestore excluiria documentos sem o campo). A ordenação é no cliente.
    func start() {
        stop()
        guard let collection else { return }
        isLoading = true
        listener = collection
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self else { return }
                    self.isLoading = false
                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.destinations = snapshot?.documents.compactMap {
                        try? $0.data(as: Destination.self)
                    } ?? []
                    // Sincroniza o relógio AQUI (não num onChange da UI):
                    // Destination é Equatable só por id, então mudanças de
                    // conteúdo (checklist, datas) não disparam onChange.
                    WatchSyncService.shared.sync(self.destinations)
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

    @discardableResult
    func add(title: String, coordinate: CLLocationCoordinate2D, date: Date?, endDate: Date? = nil, notes: String?) async throws -> Destination {
        guard let collection else {
            throw NSError(domain: "vpo", code: 0)
        }
        var destination = Destination(
            id: nil,
            title: title,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            date: date,
            endDate: endDate,
            createdAt: Date(),
            notes: notes
        )
        let ref = try collection.addDocument(from: destination)
        destination.id = ref.documentID
        return destination
    }

    func update(_ destination: Destination) async throws {
        guard let collection, let id = destination.id else { return }
        try collection.document(id).setData(from: destination, merge: true)
        // Campos opcionais simples são OMITIDOS quando nil no merge; para
        // realmente limpá-los (voltar capa ao Padrão / desfazer multi-trecho),
        // removemos explicitamente.
        var clears: [String: Any] = [:]
        if destination.coverStyle == nil { clears["coverStyle"] = FieldValue.delete() }
        if destination.stops == nil { clears["stops"] = FieldValue.delete() }
        if destination.endDate == nil { clears["endDate"] = FieldValue.delete() }
        if destination.visitedPlaces == nil { clears["visitedPlaces"] = FieldValue.delete() }
        if !clears.isEmpty {
            try await collection.document(id).updateData(clears)
        }
    }

    func delete(_ destination: Destination) async throws {
        guard let collection, let id = destination.id else { return }
        try await collection.document(id).delete()
    }

    /// Apaga todos os destinos do usuário (usado ao excluir a conta).
    func deleteAll() async throws {
        guard let collection else { return }
        let snapshot = try await collection.getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}
