//
//  ServerManager.swift
//  SocketServer
//
//  Created by GongsiWang on 2022/3/23.
//

import Cocoa

class ServerManager: NSObject {
    fileprivate lazy var serverSocket : TCPServer = TCPServer(address: "0.0.0.0", port: 7878)
    // 服务器是否运行
    fileprivate lazy var isServerRunning: Bool = false
    // 保存客户端
    fileprivate lazy var clientManagers: [ClientManager] = []
}

extension ServerManager {
    func startRunning() {
        // 1.开启监听
        isServerRunning = true
        let result = serverSocket.listen()
        print(result)
        // 2.开始接受客户端
        DispatchQueue.global().async {
            while self.isServerRunning {
                if let client = self.serverSocket.accept() {
                    // 新开线程。进行接受消息的无限循环。否则的话会卡住线程 无法接受多个客户端连接
                    DispatchQueue.global().async {
                        self.handleClient(client)
                    }
                }
            }
        }
    }
    
    func stopRunning() {
        isServerRunning = false
    }
    
}

extension ServerManager {
    
    fileprivate func handleClient(_ client: TCPClient) {
        let manager = ClientManager(client: client)
        manager.delegate = self
        // save client
        clientManagers.append(manager)
        // begin accpet
        manager.startReadMessage()
    }
}

extension ServerManager: ClientManagerDelefate {
    
    func sendMessageToClient(_ msg: Data) {
        
        for clientM in clientManagers {
            clientM.client.send(data: msg)
        }
    }
    
}
