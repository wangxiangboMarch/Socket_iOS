//
//  ClientManager.swift
//  SocketClient
//
//  Created by GongsiWang on 2022/3/24.
//

import Cocoa
import WelfareLibrary

protocol ClientManagerDelegate: AnyObject {
    func sendMessageToClient(_ msg: Data)
    func clientLog(_ msg: String)
    func remove(client: TCPClient)
}

class ClientManager {
    
    var client: TCPClient
    
    weak var delegate: ClientManagerDelegate?
    
    fileprivate var isClientConnect = false
    
    init(client: TCPClient) {
        self.client = client
    }
}

extension ClientManager {
    
    func startReadMessage() {
        isClientConnect = true
        while isClientConnect {
            // [UInt8] 相当于[char]
            if let msg = client.read(4) {
                // 获取到头部信息
                let headData = Data(bytes: msg, count: 4)
                var msgLength: Int = 0
                (headData as NSData).getBytes(&msgLength, length: 4)
                
                /// 获取类型
                guard let t = client.read(2)  else {
                    return
                }
                let typeData = Data(bytes: t, count: 2)
                
                // 获取真实的消息
                guard let m = client.read(msgLength)  else {
                    return
                }
                let msgData = Data(bytes: m, count: msgLength)
                // 组装信息
                let totalData = headData + typeData + msgData
                delegate?.sendMessageToClient(totalData)
            }else{
                // 一般是系统的消息 空字符 断开连接
                isClientConnect = false
                DispatchQueue.main.sync {
                    self.delegate?.clientLog("客户端断开了连接")
                    self.delegate?.remove(client: self.client)
                }
                client.close()
            }
        }
    }
}
