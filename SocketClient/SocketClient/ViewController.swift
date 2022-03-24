//
//  ViewController.swift
//  SocketClient
//
//  Created by GongsiWang on 2022/3/23.
//

import UIKit
import WelfareLibrary

class ViewController: UIViewController {

    fileprivate  var socket = YYSocket(addr: "192.168.5.212", port: 7878)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        if socket.connectServer() {
            print("服务器连接成功")
            socket.startReadMessage()
        }
    }
    
    @IBAction func joinRoom() {
        socket.enterRoom()
    }
    
    @IBAction func leaveRoom() {
        socket.leaveRoom()
    }
    
    @IBAction func sendText() {
        socket.sendChat(text: "这是一条文本消息")
    }
    
    @IBAction func sendGift() {
        socket.sendGif(name: "火箭", count: 1000, url: "http://www.baidu.com")
    }
    
}

