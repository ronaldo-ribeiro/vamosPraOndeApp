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

    /// Começa a ouvir os destinos do usuário em tempo real (ordenados por data).
    func start() {
        stop()
        guard let collection else { return }
        isLoading = true
        listener = collection
            .order(by: "date")
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
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

    @discardableResult
    func add(title: String, coordinate: CLLocationCoordinate2D, date: Date, notes: String?) async throws -> Destination {
        guard let collection else {
            throw NSError(domain: "vpo", code: 0)
        }
        var destination = Destination(
            id: nil,
            title: title,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            date: date,
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
    }

    func delete(_ destination: Destination) async throws {
        guard let collection, let id = destination.id else { return }
        try await collection.document(id).delete()
    }
}
