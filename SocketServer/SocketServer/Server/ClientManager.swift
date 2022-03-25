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
    func remove(client: ClientManager)
}

class ClientManager: NSObject {
    
    var client: TCPClient
    
    weak var delegate: ClientManagerDelegate?
    
    fileprivate var isClientConnect = false
    // 是否收到心跳包
    fileprivate var isReciveHeartBeat = false
    
    init(client: TCPClient) {
        self.client = client
    }
}

extension ClientManager {
    
    func startReadMessage() {
        isClientConnect = true
        
        // 开启检查心跳
        // 这里timer 会直接开始 去检查会导致当前客户端直接被移除，所以给后推十秒在开始
        let timer = Timer(fireAt: Date(timeIntervalSinceNow: 10), interval: 10, target: self, selector: #selector(heartBeatAction), userInfo: nil, repeats: true)
        // 添加到当前线程的 RunLoop
        RunLoop.current.add(timer, forMode: .default)
        RunLoop.current.run()
        
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
                var type: Int = 0
                let typeData = Data(bytes: t, count: 2)
                (typeData as NSData).getBytes(&type, length: 2)
                
                if let option = MessageOption(rawValue: type) {
                    
                    if option == .leaveRoom {
                        // 如果消息类型是离开房间
                        delegate?.remove(client: self)
                        // 关闭客户端
                        client.close()
                    }
                    
                    if option == .heartbeat {
                        isReciveHeartBeat = true
                        // 直接开始下一次消息的接收
                        continue
                    }
                   
                }
                
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
                    self.delegate?.remove(client: self)
                }
                client.close()
            }
        }
    }
    
    @objc func heartBeatAction() {
        if !isReciveHeartBeat {
            client.close()
            delegate?.remove(client: self)
        }else{
            isReciveHeartBeat = false
        }
    }
}
