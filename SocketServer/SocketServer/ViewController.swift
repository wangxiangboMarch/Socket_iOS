//
//  ViewController.swift
//  SocketServer
//
//  Created by GongsiWang on 2022/3/23.
//

import Cocoa

class ViewController: NSViewController {

    fileprivate lazy var socket = ServerManager()
    
    @IBOutlet weak var infoField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func startServer(_ sender: NSButton) {
        
        infoField.stringValue = "服务器已开启"
        socket.startRunning()
    }
    
    @IBAction func stopServer(_ sender: NSButton) {
        infoField.stringValue = "服务器已关闭"
    }
    
}
