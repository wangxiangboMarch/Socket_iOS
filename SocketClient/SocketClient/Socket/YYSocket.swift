//
//  ServerManager.swift
//  SocketServer
//
//  Created by GongsiWang on 2022/3/23.
//

import Foundation
import WelfareLibrary

protocol YYSocketDelegate: AnyObject {
    func socket(_ socket : YYSocket, joinRoom user : User)
    func socket(_ socket : YYSocket, leaveRoom user : User)
    func socket(_ socket : YYSocket, chatMsg : TextMessage)
    func socket(_ socket : YYSocket, giftMsg : GifMessage)
}

class YYSocket {
    //
    fileprivate var client: TCPClient
    
    weak var delegate: YYSocketDelegate?
    
    lazy var user: User = {
        let user = User(level: 100, name: "lucy")
        return user
    }()
    
    init(addr: String, port: NSInteger) {
        client = TCPClient(addr: addr, port: port)
    }
    
}

extension YYSocket {
    /// 连接服务器
    func connectServer() -> Bool {
        return client.connect(timeout: 10).0
    }
    /// 开始接收消息
    func startReadMessage() {
        
        DispatchQueue.global().async {
            while true {
                // [UInt8] 相当于[char]
                
                guard let msg = self.client.read(4) else {
                    continue
                }
                
                // 获取到头部信息
                let headData = Data(bytes: msg, count: 4)
                var msgLength: Int = 0
                (headData as NSData).getBytes(&msgLength, length: 4)
                
                /// 获取类型
                guard let t = self.client.read(2)  else {
                    return
                }
                let typeData = Data(bytes: t, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                
                // 获取真实的消息
                guard let m = self.client.read(msgLength)  else {
                    return
                }
                
                let msgData = Data(bytes: m, count: msgLength)
                let json = String(data: msgData, encoding: .utf8)!
                // 3.处理消息
                DispatchQueue.main.async {
                    self.handleMsg(type: type, json: json)
                }
            }
        }
    }
    
    fileprivate func handleMsg(type : Int, json: String) {
        switch type {
        case 0, 1:
            let user = try! pumpkinDecoder(jsonstr: json, modelType: User.self)
            type == 0 ? delegate?.socket(self, joinRoom: user) : delegate?.socket(self, leaveRoom: user)
        case 2:
            let chatMsg = try! pumpkinDecoder(jsonstr: json, modelType: TextMessage.self)
            delegate?.socket(self, chatMsg: chatMsg)
        case 3:
            let giftMsg = try! pumpkinDecoder(jsonstr: json, modelType: GifMessage.self)
            delegate?.socket(self, giftMsg: giftMsg)
        default:
            print("未知类型")
        }
    }
}

//MARK: - 发送消息的快捷方法封装
extension YYSocket {
    /// 进入房间
    func enterRoom() {
        let data = pumpkinEncoder(model: user).data(using: .utf8)!
        sendMessage(data, type: .enterRoom)
    }
    
    /// 离开房间
    func leaveRoom() {
        let data = pumpkinEncoder(model: user).data(using: .utf8)!
        sendMessage(data, type: .leaveRoom)
    }
    
    /// 进入房间
    func sendChat(text: String) {
        
        let message = TextMessage(text: text, user: user)
        let data = pumpkinEncoder(model: message).data(using: .utf8)!
        sendMessage(data, type: .textMessage)
        
    }
    
    /// 进入房间
    func sendGif(name: String, count: Int, url: String) {
        let message = GifMessage(user: user, count: count, name: name, url: url)
        let data = pumpkinEncoder(model: message).data(using: .utf8)!
        sendMessage(data, type: .gifmessage)
    }
    
    func sendHeartBeat(text: String) {
        let message = HeartBeat(text: text)
        let data = pumpkinEncoder(model: message).data(using: .utf8)!
        sendMessage(data, type: .heartbeat)
    }

    /// 给服务器发送消息
    /// - Parameters:
    ///   - data: 内容
    ///   - type: 消息的类型
    /// - Returns: bool 值 ： 是否发送成功
    @discardableResult
    fileprivate func sendMessage(_ data: Data, type: MessageOption) -> Bool {

        // 服务器不知道消息的长度。导致无法读取
        // 方案： 在头部拼接固定长度的字节 告诉服务器消息的长度 继续拼接小心的类型

        // 获取消息的长度 默认占四个字节
        var length = data.count
        let headerData = Data(bytes: &length, count: 4)
        // 封装消息类型 默认占用两个字节
        var type = type.rawValue
        let typeData = Data(bytes: &type, count: 2)
        // 组装消息
        let totalData = headerData + typeData + data
        // 发送消息并返回 发送结果
        return client.send(data: totalData).0
    }
}
