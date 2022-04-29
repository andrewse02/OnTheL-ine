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
    
    static func setDisplayName(token: String, completion: @escaping (NetworkError?) -> Void) {
        HTTPServerManager.setDisplayName(token: token, completion: completion)
    }
}
