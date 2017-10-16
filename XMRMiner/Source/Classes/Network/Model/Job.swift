//
//  Job.swift
//  XMRMiner
//
//  Created by Nick Lee on 10/9/17.
//

import Foundation
import ObjectMapper
import NSData_FastHex

class Job: Mappable {
    
    // MARK: Properties
    
    private(set) var id = ""
    private(set) var blob = Data()
    private(set) var target: UInt64 = 0
    
    var nonce: UInt32 {
        get {
            let start = 39
            let sd = blob.subdata(in: start ..< start + MemoryLayout<UInt32>.size)
            let v = sd.withUnsafeBytes { (a: UnsafePointer<UInt32>) -> UInt32 in a.pointee }
            return v.littleEndian
        }
        set {
            let start = 39
            let range: Range<Data.Index> = start ..< start + MemoryLayout<UInt32>.size
            var newBytes = blob.subdata(in: range)
            newBytes.withUnsafeMutableBytes { (a: UnsafeMutablePointer<UInt32>) -> Void in
                a.pointee = newValue.littleEndian
            }
            blob.replaceSubrange(range, with: newBytes)
        }
    }
    
    // MARK: Mappable
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        var blobStr = ""
        blobStr <- map["blob"]
        blob = NSData(hexString: blobStr) as Data
        
        var targetStr = ""
        targetStr <- map["target"]
        let targetData = NSData(hexString: targetStr) as Data
        target = targetData.withUnsafeBytes { (ptr: UnsafePointer<UInt64>) -> UInt64 in
            return ptr.pointee
        }
        
        id <- map["id"]
    }
    
    // MARK: Target Test
    
    func evaluate(hash result: Data) -> Bool {
        let start = 24
        let sd = result.subdata(in: start ..< start + MemoryLayout<UInt64>.size)
        let v = sd.withUnsafeBytes { (a: UnsafePointer<UInt64>) -> UInt64 in a.pointee }
        return v < target
    }
    
}
