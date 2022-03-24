//
//  ServerManager.swift
//  SocketServer
//
//  Created by GongsiWang on 2022/3/23.
//

import Cocoa

class ServerManager: NSObject {
    fileprivate lazy var serverSocket : TCPServer = TCPServer(address: "0.0.0.0", port: 7878)
}

extension ServerManager {
    func startRunning() {
        // 1.开启监听
        let result = serverSocket.listen()
        print(result)
        // 2.开始接受客户端
        DispatchQueue.global().async {
            while true {
                if let client = self.serverSocket.accept() {
                    print("有客户端杰瑞")
                }
            }
        }
    }
    
    func stopRunning() {
        
    }
    
}
