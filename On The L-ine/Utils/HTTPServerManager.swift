//
//  HTTPServerManager.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/25/22.
//

import Foundation

class HTTPServerManager {
//    static let baseURL = URL(string: "http://otl.andrewelliott.me")
//    static let baseURL = URL(string: "http://10.0.0.54")
    static let baseURL = URL(string: "http://192.168.10.75")
//    static let baseURL = URL(string: "http://localhost")
    
    private static let signUpEndpoint = "signup"
    private static let signInEndpoint = "signin"
    private static let userEndpoint = "user"
    
    static func signUpRequest(username: String, password: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        
        let finalURL = baseURL.appendingPathComponent(signUpEndpoint)
        
        let jsonBody = ["username": username, "password": password]
        let body = try? JSONSerialization.data(withJSONObject: jsonBody)
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { return completion(.failure(.thrownError(error))) }
            
            guard let data = data else { return completion(.failure(.noData)) }
            guard let token = String(data: data, encoding: .utf8) else { return completion(.failure(.invalidResponse)) }
            
            completion(.success(token))
        }.resume()
    }
    
    static func signInRequest(username: String, password: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        
        let finalURL = baseURL.appendingPathComponent(signInEndpoint)
        
        let jsonBody = ["username": username, "password": password]
        let body = try? JSONSerialization.data(withJSONObject: jsonBody)
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { return completion(.failure(.thrownError(error))) }
            
            guard let data = data else { return completion(.failure(.noData)) }
            guard let token = String(data: data, encoding: .utf8) else { return completion(.failure(.invalidResponse)) }
            
            completion(.success(token))
        }.resume()
    }
    
    static func setDisplayName(token: String, completion: @escaping (NetworkError?) -> Void) {
        guard let baseURL = baseURL else { return completion(.invalidURL) }
        
        let finalURL = baseURL.appendingPathComponent(userEndpoint)
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { return completion(.thrownError(error)) }
            completion(nil)
        }.resume()
    }
}
