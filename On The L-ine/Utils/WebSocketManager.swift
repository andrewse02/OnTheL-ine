//
//  WebSocketManager.swift
//  On The L-ine
//
//  Created by Andrew Elliott on 4/25/22.
//

import Foundation
import SocketIO

class WebSocketManager {
    static let shared = WebSocketManager()
    
    var manager: SocketManager?
    var socket: SocketIOClient?
    
    func connect(completion: @escaping NormalCallback) {
        let manager = SocketManager(socketURL: HTTPServerManager.baseURL!, config: [
            .forceWebsockets(true)
        ])
        self.manager = manager
        
        let socket = manager.defaultSocket
        self.socket = socket
                
        socket.on(clientEvent: .connect, callback: completion)
        socket.on("match", callback: onMatch)
        
        AuthManager.currentUser?.getIDTokenForcingRefresh(true, completion: { token, error in
            if let error = error { return print("\n~~~~~Error in \(#filePath) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)") }
            
            socket.connect(withPayload: ["token": token ?? ""])
        })
    }
    
    func onMatch(data: [Any], ack: SocketAckEmitter) {
        print("In match: \(data)")
    }
    
    func joinQueue(completion: @escaping NormalCallback) {
        guard let socket = socket else { return }
        
        socket.emitWithAck("queue").timingOut(after: 0) { data in
            print("In queue: \(data)")
        }
    }
}
