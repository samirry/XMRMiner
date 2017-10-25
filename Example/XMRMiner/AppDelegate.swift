//
//  AppDelegate.swift
//  XMRMiner
//
//  Created by nickplee on 10/09/2017.
//  Copyright (c) 2017 nickplee. All rights reserved.
//

import UIKit
import XMRMiner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let miner = Miner(destinationAddress: "46oUXWagF22GP43Uetur611bzpHiG8z4xPtYoBppGhxAZ51HwCVmfUDfo7maSkyVR2acwwJBzx1MJP8wJvDaNC2NMD9BkxA")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        miner.delegate = window?.rootViewController as? MinerDelegate
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        miner.stop()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        do {
            try miner.start()
        }
        catch {
            print("something bad happened")
        }
    }
    
}

