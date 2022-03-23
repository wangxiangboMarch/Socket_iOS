//
//  ViewController.swift
//  SocketClient
//
//  Created by GongsiWang on 2022/3/23.
//

import UIKit

class ViewController: UIViewController {

    fileprivate  var socket = YYSocket(addr: "192.168.31.124", port: 7878)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor.white
        
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        if socket.connectServer() {
            print("链接了 服务器")
        }
        
        
    }
    
    
}

