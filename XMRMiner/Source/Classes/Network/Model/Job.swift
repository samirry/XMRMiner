//
//  Job.swift
//  XMRMiner
//
//  Created by Nick Lee on 10/9/17.
//

import Foundation
import ObjectMapper
import NSData_FastHex

struct Job: Mappable {
    
    // MARK: Properties
    
    var id = ""
    var blob = Data()
    var target = Data()
    
    // MARK: Mappable
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        var blobStr = ""
        blobStr <- map["blob"]
        blob = NSData(hexString: blobStr) as Data
        
        var targetStr = ""
        targetStr <- map["target"]
        target = NSData(hexString: targetStr) as Data
        
        id <- map["id"]
    }
    
}
