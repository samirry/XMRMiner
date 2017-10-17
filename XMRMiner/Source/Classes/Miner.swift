//
//  Miner.swift
//  CocoaAsyncSocket
//
//  Created by Nick Lee on 10/9/17.
//

import Foundation
import NSData_FastHex

public protocol MinerDelegate: class {
    func miner(updatedStats stats: MinerStats)
}

public class Miner {
    
    // MARK: Public Properties
    
    public weak var delegate: MinerDelegate?
    
    // MARK: Internal Properties
    
    let client = Client(url: {
        var components = URLComponents()
        components.scheme = "stratum+tcp"
        components.user = "46oUXWagF22GP43Uetur611bzpHiG8z4xPtYoBppGhxAZ51HwCVmfUDfo7maSkyVR2acwwJBzx1MJP8wJvDaNC2NMD9BkxA"
        
        let uuid = UIDevice.current.identifierForVendor!.uuid
        let b = [uuid.0, uuid.1, uuid.2, uuid.3, uuid.4, uuid.5, uuid.6, uuid.7, uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15]
        let uuidData = Data(bytes: b)
        components.password = (uuidData as NSData).hexStringRepresentationUppercase(false)
        
        components.host = "pool.supportxmr.com"
        components.port = 5555
        return components.url!
    }(), agent: "")
    
    let jobSemaphore = DispatchSemaphore(value: 1)
    var job: Job?
    
    var threads: [Thread] = []
    
    let statsSemaphore = DispatchSemaphore(value: 1)
    var stats = MinerStats()
    
    public init() {
        client.delegate = self
    }
    
    public func start() {
        try! client.connect()
        
        let threadCount = 1 //ProcessInfo.processInfo.activeProcessorCount
        
        for i in 0 ..< threadCount {
            if #available(iOS 10, *) {
                let t = Thread(block: mine)
                t.name = "Mining Thread \(i+1)"
                t.start()
            }
            else {
                DispatchQueue.global(qos: .userInteractive).async(execute: mine)
            }
        }
    }
    
    public func stop() {
        threads.forEach { $0.cancel() }
        threads = []
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
        
        while !Thread.current.isCancelled {
            autoreleasepool {
                hash(with: hasher)
            }
        }
        
    }
    
    private func hash(with hasher: HashContext) {
        jobSemaphore.wait()
        guard let job = job else {
            jobSemaphore.signal()
            return
        }
        job.nonce += 1
        let blob = job.blob
        let currentNonce = job.nonce
        jobSemaphore.signal()
        
        let result = hasher.hashData(blob)
        
        statsSemaphore.wait()
        stats.hashes += 1
        let now = Date()
        if (now.timeIntervalSince(stats.lastDate) >= 0.1) {
            let s = self.stats
            DispatchQueue.main.async {
                self.delegate?.miner(updatedStats: s)
            }
            stats.lastDate = now
            stats.hashes = 0
        }
        statsSemaphore.signal()
        
        if job.evaluate(hash: result) {
            DispatchQueue.main.async {
                do {
                    try self.client.submitJob(id: job.id, jobID: job.jobID, result: result, nonce: currentNonce)
                }
                catch {
                    print("error!")
                }
            }
            statsSemaphore.wait()
            stats.submittedHashes += 1
            DispatchQueue.main.async {
                self.delegate?.miner(updatedStats: self.stats)
            }
            statsSemaphore.signal()
        }
    }
}

