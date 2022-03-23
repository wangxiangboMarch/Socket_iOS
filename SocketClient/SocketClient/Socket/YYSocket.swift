//
//  ServerManager.swift
//  SocketServer
//
//  Created by GongsiWang on 2022/3/23.
//

import Foundation

class YYSocket {
    //
    fileprivate var client: TCPClient
    
    init(addr: String, port: NSInteger) {
        client = TCPClient(addr: addr, port: port)
    }
    
}

extension YYSocket {
    
    func connectServer() -> Bool {
        
        return client.connect(timeout: 5).0
        
    }
}
