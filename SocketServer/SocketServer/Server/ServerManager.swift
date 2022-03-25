//
//  ServerManager.swift
//  SocketServer
//
//  Created by GongsiWang on 2022/3/23.
//

import Cocoa

protocol ServerManagerLogDelegate: AnyObject {
    func serverLog(_ msg: String)
}

class ServerManager: NSObject {
    fileprivate lazy var serverSocket : TCPServer = TCPServer(address: "192.168.31.124", port: 7878)
    // 服务器是否运行
    fileprivate lazy var isServerRunning: Bool = false
    // 保存客户端
    fileprivate lazy var clientManagers: Set<ClientManager> = []
    weak var logDelegate: ServerManagerLogDelegate?
}

extension ServerManager {
    func startRunning() {
        // 1.开启监听
        isServerRunning = true
        let result = serverSocket.listen()
        if result.isSuccess {
            logDelegate?.serverLog("服务器开始监听")
        }else{
            logDelegate?.serverLog("服务器开始监听失败")
        }
        // 2.开始接受客户端
        DispatchQueue.global().async {
            while self.isServerRunning {
                if let client = self.serverSocket.accept() {
                    // 新开线程。进行接受消息的无限循环。否则的话会卡住线程 无法接受多个客户端连接
                    DispatchQueue.main.sync {
                        self.logDelegate?.serverLog("接收到了客户端的链接。。。")
                    }
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
        clientManagers.insert(manager)
        // begin accpet
        manager.startReadMessage()
    }
}

extension ServerManager: ClientManagerDelegate {
    func remove(client: ClientManager) {
        // 从存储中移除当前client
        clientManagers.remove(client)
    }
    
    func clientLog(_ msg: String) {
        logDelegate?.serverLog(msg)
    }
    
    func sendMessageToClient(_ msg: Data) {
        
        // 如果这条消息是离开房间的消息则应该先把当前客户端从存档中移除再进行消息转发
        
        for clientM in clientManagers {
            clientM.client.send(data: msg)
        }
    }
    
}
