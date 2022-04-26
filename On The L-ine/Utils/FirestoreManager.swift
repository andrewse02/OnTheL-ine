//
//  FirestoreManager.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/23/22.
//

import Foundation

import Firebase
import FirebaseFirestore

class FirestoreManager {
    
    private static var db: Firestore!
    
    private static let usersPath = "users"
    private static let uidKey = "uid"
    private static let usernameKey = "username"
    
    static func configure() {
        self.db = Firestore.firestore()
    }
    
    static func createUser(username: String, uid: String, completion: @escaping (Result<DocumentReference, Error>) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection(usersPath).addDocument(data: [
            uidKey: uid,
            usernameKey: username
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else if let ref = ref {
                completion(.success(ref))
            }
        }
    }
    
    static func getUser(uid: String, completion: @escaping FIRQuerySnapshotBlock) {
        let users = db.collection(usersPath)
        let usersQuery = users.whereField(uidKey, isEqualTo: uid)
        
        usersQuery.getDocuments(completion: completion)
    }
    
    static func getUser(username: String, completion: @escaping FIRQuerySnapshotBlock) {
        let users = db.collection(usersPath)
        let usersQuery = users.whereField(usernameKey, isEqualTo: username)
        
        usersQuery.getDocuments(completion: completion)
    }
}
