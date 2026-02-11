// FirebaseManager.swift

import Foundation
import FirebaseFirestore

actor FirebaseManager: DailyMessagesRepository {

    static let shared = FirebaseManager()

    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    private var collectionRef: CollectionReference {
        db.collection("DailyMessages")
    }

    private func docRef(for index: Int) -> DocumentReference {
        collectionRef.document(String(index))
    }

    // Fetch a message by index; if missing, upsert from local and return it.
    func fetchDailyMessage(for index: Int) async throws -> DailyMessage {
        let ref = docRef(for: index)
        do {
            let snapshot = try await getDocument(ref)
            if snapshot.exists,
               let data = snapshot.data(),
               let text = data["text"] as? String {
                return DailyMessage(id: snapshot.documentID, text: text)
            } else {
                // Missing or malformed -> seed from local for this index
                let localText = MessageStore.messageForIndex(index)
                try await upsertDailyMessage(for: index, text: localText)
                return DailyMessage(id: String(index), text: localText)
            }
        } catch {
            // On error, fall back to local without writing
            let localText = MessageStore.messageForIndex(index)
            return DailyMessage(id: String(index), text: localText)
        }
    }

    // Upsert a single message document with provided text
    func upsertDailyMessage(for index: Int, text: String) async throws {
        let ref = docRef(for: index)
        try await setData(ref, data: ["text": text], merge: true)
    }

    // Seed Firestore for all local messages
    func seedDailyMessagesFromLocal() async throws {
        for (idx, text) in MessageStore.messages.enumerated() {
            try await upsertDailyMessage(for: idx, text: text)
        }
    }

    // New: count total number of documents in DailyMessages
    func dailyMessagesCount() async throws -> Int {
        // Prefer count aggregation if available (Firestore SDK >= 10.4.0)
        // aggregationQuery().count.getAggregation(completion:) exists on iOS
        // If not available at runtime, we fall back to a lightweight fetch and count.
        if #available(iOS 13.0, *) {
            do {
                let count = try await getCollectionCount(collectionRef)
                return count
            } catch {
                // Fallback: fetch documents and count them
                let snapshots = try await getDocuments(collectionRef)
                return snapshots.count
            }
        } else {
            // Very old platforms: fallback
            let snapshots = try await getDocuments(collectionRef)
            return snapshots.count
        }
    }

    // MARK: - Async wrappers

    private func getDocument(_ ref: DocumentReference) async throws -> DocumentSnapshot {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DocumentSnapshot, Error>) in
            ref.getDocument { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let snapshot = snapshot {
                    continuation.resume(returning: snapshot)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "FirebaseManager",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "No snapshot"]
                        )
                    )
                }
            }
        }
    }

    private func setData(_ ref: DocumentReference, data: [String: Any], merge: Bool) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ref.setData(data, merge: merge) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func getDocuments(_ ref: CollectionReference) async throws -> [QueryDocumentSnapshot] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[QueryDocumentSnapshot], Error>) in
            ref.getDocuments { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let snapshot = snapshot {
                    continuation.resume(returning: snapshot.documents)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "FirebaseManager",
                            code: -2,
                            userInfo: [NSLocalizedDescriptionKey: "No query snapshot"]
                        )
                    )
                }
            }
        }
    }

    // Prefer aggregation count if SDK supports it
    private func getCollectionCount(_ ref: CollectionReference) async throws -> Int {
        // Use the count aggregation query
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int, Error>) in
            ref.count.getAggregation(source: .server) { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let snapshot = snapshot {
                    continuation.resume(returning: Int(truncatingIfNeeded: snapshot.count.intValue))
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "FirebaseManager",
                            code: -3,
                            userInfo: [NSLocalizedDescriptionKey: "No aggregation snapshot"]
                        )
                    )
                }
            }
        }
    }
}

