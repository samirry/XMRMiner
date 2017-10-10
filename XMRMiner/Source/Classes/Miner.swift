//
//  Miner.swift
//  CocoaAsyncSocket
//
//  Created by Nick Lee on 10/9/17.
//

import Foundation

public class Miner {
    
    let client = Client(url: URL(string: "stratum+tcp://46oUXWagF22GP43Uetur611bzpHiG8z4xPtYoBppGhxAZ51HwCVmfUDfo7maSkyVR2acwwJBzx1MJP8wJvDaNC2NMD9BkxA:worker20@pool.supportxmr.com:5555")!, agent: "")
    
    public init() {
        client.delegate = self
    }
    
    public func start() {
        try! client.connect()
    }
    
}

extension Miner: ClientDelegate {
    func client(_ client: Client, receivedJob: Job) {
        print("jobby")
    }
}
