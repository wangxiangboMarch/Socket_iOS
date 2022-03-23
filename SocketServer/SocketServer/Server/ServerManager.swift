//
//  ServerManager.swift
//  SocketServer
//
//  Created by GongsiWang on 2022/3/23.
//

import Cocoa

class ServerManager: NSObject {
    // 创建ServerSocket 端口不能用1024 之前的
    fileprivate  var serverSocket = TCPServer(addr: "127.0.0.1", port: 7878)
    
}

extension ServerManager {
    
    func startRunning() {
        
        // 开启监听
        self.serverSocket.listen()
        print("开启服务器")
        // 开始接受客户端 返回客户端
        DispatchQueue.global().async {
            if let client = self.serverSocket.accept() {
                print("接收到一个客户端的请求")
            }else{
                print("接收到一个客户端的请求")
            }
        }
        
        
    }
    
    func stopRunning() {
        
    }
}
