//
//  ViewController.swift
//  SocketClient
//
//  Created by GongsiWang on 2022/3/23.
//

import UIKit
import WelfareLibrary
import CoreTelephony

class ViewController: UIViewController {

    fileprivate  var socket = YYSocket(addr: "192.168.31.124", port: 7878)
//    YYSocket(addr: "192.168.5.212", port: 7878)
    
    fileprivate let cellularData = CTCellularData.init()
    
    @IBOutlet weak var logView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        logView.layoutManager.allowsNonContiguousLayout = false
        // 获取网络权限状态
        let cellularData = CTCellularData.init()
        switch cellularData.restrictedState {
        case .notRestricted:
            setServer()
        default:
            testHttp()
        }
        
        setServer()
        
    }
    /// 设置socket 连接
    fileprivate func setServer() {
        if socket.connectServer() {
            setLogMessage(msg: "服务器连接成功")
            socket.startReadMessage()
            socket.delegate = self
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
 
    
    func testHttp() {
        let url = URL(string: "https://www.baidu.com")!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, res, error in
            
        }
        dataTask.resume()
    }
    
    func requestTelephonyAuthorization() {
        // 监听网络权限变化
        cellularData.cellularDataRestrictionDidUpdateNotifier = {state in
            switch state {
            case .notRestricted:
                self.setServer()
            default:
                self.testHttp()
            }
        }
    }
    
    func setLogMessage(msg: String) {
        logView.text = logView.text + "\n" + msg
        logView.scrollRangeToVisible(NSRange(location: logView.text.count, length: 1))
    }
}

extension ViewController: YYSocketDelegate {
    func socket(_ socket: YYSocket, joinRoom user: User) {
        
        setLogMessage(msg: "\(user.name) 进入房间")
    }
    
    func socket(_ socket: YYSocket, leaveRoom user: User) {
        setLogMessage(msg: "\(user.name) 离开房间")
    }
    
    func socket(_ socket: YYSocket, chatMsg: TextMessage) {
        setLogMessage(msg: "\(chatMsg.user.name) 说：\(chatMsg.text)")
    }
    
    func socket(_ socket: YYSocket, giftMsg: GifMessage) {
        setLogMessage(msg: "\(giftMsg.user.name) 收到礼物：\(giftMsg.name) 地址：\(giftMsg.url)")
    }
}
