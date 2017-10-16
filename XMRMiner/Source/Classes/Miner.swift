//
//  Miner.swift
//  CocoaAsyncSocket
//
//  Created by Nick Lee on 10/9/17.
//

import Foundation
import NSData_FastHex

public class Miner {
    let client = Client(url: URL(string: "stratum+tcp://46oUXWagF22GP43Uetur611bzpHiG8z4xPtYoBppGhxAZ51HwCVmfUDfo7maSkyVR2acwwJBzx1MJP8wJvDaNC2NMD9BkxA:worker20@pool.supportxmr.com:5555")!, agent: "")
    
    let jobSemaphore = DispatchSemaphore(value: 1)
    var job: Job?
    
    public init() {
        client.delegate = self
    }
    
    public func start() {
        try! client.connect()
        
        for i in 0 ..< 1 {
            let t = Thread(block: mine)
            t.name = "Mining Thread \(i+1)"
            t.start()
        }
    }
}

extension Miner: ClientDelegate {
    func client(_ client: Client, receivedJob: Job) {
        jobSemaphore.wait()
        job = receivedJob
        print("new job")
        jobSemaphore.signal()
    }
}

extension Miner {
    
    fileprivate func mine() {
        
        let hasher = HashContext()
        
        while true {
            
            jobSemaphore.wait()
            guard let job = job else {
               jobSemaphore.signal()
                continue
            }
            job.nonce += 1
            let blob = job.blob
            jobSemaphore.signal()
            
            print("input: ", blob as NSData)
            
            let result = hasher.hashData(blob)
            print("input:", blob as NSData)
            print(job.id, ": ", result as NSData)
            
            if job.evaluate(hash: result) {
                print("yay!")
            }
            
            
        }
        
    }
}

