//
//  AuthManager.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/23/22.
//

import Foundation

import Firebase
import FirebaseAuth

class AuthManager {
    static var currentUser: User?
    
    static func signUp(username: String, password: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        HTTPServerManager.signUpRequest(username: username, password: password, completion: completion)
    }
    
    static func signIn(username: String, password: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        HTTPServerManager.signInRequest(username: username, password: password, completion: completion)
    }
    
    static func signIn(token: String, completion: @escaping ((AuthDataResult?, Error?) -> Void)) {
        Auth.auth().signIn(withCustomToken: token, completion: completion)
    }
    
    static func setDisplayName(username: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(NetworkError.userNotLoggedIn) }
        let changeRequest = user.createProfileChangeRequest()
        
        changeRequest.displayName = username
        changeRequest.commitChanges(completion: completion)
    }
}
