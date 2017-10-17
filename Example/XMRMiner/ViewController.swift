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
    
    var miner = Miner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        miner.delegate = self
        miner.start()
        
        // Do any additional setup after loading the view, typically from a nib.
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
