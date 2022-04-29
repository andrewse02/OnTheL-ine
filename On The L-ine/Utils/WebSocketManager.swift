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
        socket.on("match", callback: onMatchFound)
        
        AuthManager.currentUser?.getIDTokenForcingRefresh(true, completion: { token, error in
            if let error = error { return print("\n~~~~~Error in \(#filePath) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)") }
            
            socket.connect(withPayload: ["token": token ?? ""])
        })
    }
    
    func onMatchFound(data: [Any], ack: SocketAckEmitter) {
        print("In match: \(data)")
        
        guard let opponent = (data.first as? NSDictionary)?["opponent"] as? String else { return }
        
        NotificationManager.postMatchFound(opponent: opponent)
    }
    
    func joinQueue(completion: @escaping AckCallback) {
        guard let socket = socket else { return }
        
        socket.emitWithAck("queue").timingOut(after: 0, callback: completion)
    }
    
    func createRoom(completion: @escaping AckCallback) {
        guard let socket = socket else { return }
        
        socket.emitWithAck("create-room").timingOut(after: 0, callback: completion)
    }
}
