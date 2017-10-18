//
//  ViewController.swift
//  OSXMiner
//
//  Created by Nick Lee on 10/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import XMRMiner

class ViewController: NSViewController {

    let miner = Miner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miner.delegate = self
        miner.start()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
}

extension ViewController: MinerDelegate {
    func miner(updatedStats stats: MinerStats) {
        print(stats.hashRate)
    }
}