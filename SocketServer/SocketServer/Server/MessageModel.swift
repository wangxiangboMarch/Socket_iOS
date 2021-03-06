//
//  MessageModel.swift
//  SocketServer
//
//  Created by GongsiWang on 2022/3/24.
//

import Foundation

enum MessageOption: NSInteger {
    case enterRoom
    case leaveRoom
    case textMessage
    case gifmessage
    case heartbeat
    
}

struct User: Codable {
    let level: NSInteger
    let name: String
}

struct TextMessage: Codable {
    let text: String
    let user: User
}

struct GifMessage: Codable {
    let user: User
    let count: NSInteger
    let name: String
    let url: String
}

struct HeartBeat: Codable {
    let text: String
}
