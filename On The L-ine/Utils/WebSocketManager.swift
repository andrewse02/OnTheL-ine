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
            .reconnectAttempts(0)
        ])
        self.manager = manager
        
        let socket = manager.defaultSocket
        self.socket = socket
                
        socket.on(clientEvent: .connect, callback: completion)
        socket.on("error", callback: onError)
        socket.on("match", callback: onMatchFound)
        socket.on("player-join-room", callback: onPlayerJoinRoom)
        socket.on("start", callback: onStart)
        socket.on("move", callback: onMove)
        
        AuthManager.currentUser?.getIDTokenForcingRefresh(true, completion: { [weak self] token, error in
            guard let self = self else { return }
            
            if let error = error { return print("\n~~~~~Error in \(#filePath) within function \(#function) at line \(#line)~~~~~\n", "\n\(error)\n\n\(error.localizedDescription)") }
            
            socket.connect(withPayload: ["token": token ?? ""], timeoutAfter: 10, withHandler: self.onConnectTimeout)
        })
    }
    
    func onConnectTimeout() {
        let toast = Toast.default(image: UIImage(systemName: "x.circle.fill") ?? UIImage(), title: "Error: Could not connect to server!", backgroundColor: Colors.highlight ?? UIColor(), textColor: Colors.light ?? UIColor())
        toast.show(haptic: .error)
    }
    
    func onError(data: [Any], ack: SocketAckEmitter) {
        print("\n~~~~~Error in \(#file) within function \(#function) at line \(#line)~~~~~\n", "\n\(data)\n")
    }
    
    func onMatchFound(data: [Any], ack: SocketAckEmitter) {
        guard let opponent = (data.first as? NSDictionary)?["opponent"] as? String else { return }
        
        NotificationManager.postMatchFound(opponent: opponent)
    }
    
    func onPlayerJoinRoom(data: [Any], ack: SocketAckEmitter) {
        guard let opponent = (data.first as? NSDictionary)?["opponent"] as? String else { return }
        
        NotificationManager.postPlayerJoinRoom(opponent: opponent)
    }
    
    func onStart(data: [Any], ack: SocketAckEmitter) {
        guard let board = data.first as? [[String]],
              let turn = data[1] as? NSString else { return }
        
        let result = (board: board, turn: turn)
        
        NotificationManager.postMatchStart(result: result)
    }
    
    func onMove(data: [Any], ack: SocketAckEmitter) {
        guard let board = data.first as? [[String]],
              let turn = data[1] as? NSString else { return }
        
        let result = (board: board, turn: turn)
        
        NotificationManager.postMoveMade(result: result)
    }
    
    func joinQueue(completion: @escaping AckCallback) {
        guard let socket = socket else { return }
        
        socket.emitWithAck("queue").timingOut(after: 0, callback: completion)
    }
    
    func createRoom(completion: @escaping AckCallback) {
        guard let socket = socket else { return }
        
        socket.emitWithAck("create-room").timingOut(after: 0, callback: completion)
    }
    
    func startGame() {
        guard let socket = socket else { return }
        
        socket.emit("start")
    }
    
    func joinRoom(roomCode: String, completion: @escaping AckCallback) {
        guard let socket = socket else { return }
        
        socket.emitWithAck("join-room", roomCode).timingOut(after: 0, callback: completion)
    }
    
    func sendMove(lIndexes: [CellIndex], neutralMove: NeutralMove?, completion: @escaping AckCallback) {
        guard let socket = socket else { return }
        
        let indexes = lIndexes.map({ return [$0.row, $0.column] })
        
        var neutralIndexes: [[Int]]? = nil
        if let neutralMove = neutralMove {
            neutralIndexes = [
                [neutralMove.origin.row, neutralMove.origin.column],
                [neutralMove.destination.row, neutralMove.destination.column]
            ]
        }
        
        socket.emitWithAck("move", indexes, neutralIndexes ?? []).timingOut(after: 0, callback: completion)
    }
}
