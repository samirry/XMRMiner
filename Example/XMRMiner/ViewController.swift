//
//  ViewController.swift
//  XMRMiner
//
//  Created by nickplee on 10/09/2017.
//  Copyright (c) 2017 nickplee. All rights reserved.
//

import UIKit
import XMRMiner

class ViewController: UIViewController {
    
    @IBOutlet weak var hashrateLabel: UILabel!
    @IBOutlet weak var submittedHashesLabel: UILabel!
    
    let miner = Miner(destinationAddress: "46oUXWagF22GP43Uetur611bzpHiG8z4xPtYoBppGhxAZ51HwCVmfUDfo7maSkyVR2acwwJBzx1MJP8wJvDaNC2NMD9BkxA")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        miner.delegate = self
        
        do {
            try miner.start()
        }
        catch {
            fatalError("something bad happened")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: MinerDelegate {
    func miner(updatedStats stats: MinerStats) {
        hashrateLabel.text = "\(stats.hashRate) H/s"
        submittedHashesLabel.text = "\(stats.submittedHashes)"
    }
}
