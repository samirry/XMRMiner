//
//  RPCObject.swift
//  CocoaAsyncSocket
//
//  Created by Nick Lee on 10/9/17.
//

import Foundation
import ObjectMapper

class RPCObject: Mappable {
    private var jsonrpc = "2.0"
    
    init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        jsonrpc <- map["jsonrpc"]
    }
}
