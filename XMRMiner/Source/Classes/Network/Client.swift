//
//  Client.swift
//  CPJSONRPC
//
//  Created by Nick Lee on 10/9/17.
//

import Foundation
import CocoaAsyncSocket
import ObjectMapper

protocol ClientDelegate: class {
    func client(_ client: Client, receivedJob: Job)
}

final class Client {
    
    // MARK: Types
    
    fileprivate struct Constants {
        struct Tags {
            static let sendRequest = 1
            static let readResponse = 2
        }
        static let terminator = Data(bytes: [0x0A])
    }
    
    // MARK: Properties
    
    weak var delegate: ClientDelegate?
    let url: URL
    let agent: String
    
    // MARK: Private Properties
    
    private var socket: GCDAsyncSocket!
    private let socketDelegate = ClientStreamDelegate()
    
    // MARK: Initialization
    
    public init(url u: URL, agent a: String) {
        url = u
        agent = a
        socketDelegate.client = self
        socket = GCDAsyncSocket(delegate: socketDelegate, delegateQueue: .main)
    }
    
    // MARK: Network
    
    public func connect() throws {
        try socket.connect(toHost: url.host ?? "", onPort: UInt16(url.port ?? 3333))
    }
}

extension Client {
    fileprivate func login() throws {
        try send(method: "login", id: 1, params: [
            "login": url.user ?? "",
            "pass": url.password ?? "",
            "agent": agent
            ])
    }
    
    private func send(method: String, id: Int, params: Any) throws {
        let message = RPCRequest(method: method, id: id, params: params)
        guard let json = Mapper().toJSONString(message), let jsonData = json.data(using: .utf8) else {
            return // TODO: throw something
        }
        let terminatedData = jsonData + Constants.terminator
        socket.write(terminatedData, withTimeout: 30, tag: Constants.Tags.sendRequest)
    }
}

extension Client {
    fileprivate func socketConnected() {
        try! login()
    }
    
    fileprivate func didReceive(response: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: response, options: [])) as? [String : Any], let response = Mapper<RPCResponse>().map(JSON: json) else {
            return
        }
        
        switch response.result {
        case .success(let result):
            if let resultDict = result as? [String : Any], let jobJson = resultDict["job"], let job = Mapper<Job>().map(JSONObject: jobJson) {
                delegate?.client(self, receivedJob: job)
            }
        default:
            break
        }
        
    }
}

@objc private final class ClientStreamDelegate: NSObject, GCDAsyncSocketDelegate {
    weak var client: Client?
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        client?.socketConnected()
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        switch tag {
        case Client.Constants.Tags.sendRequest:
            sock.readData(to: Client.Constants.terminator, withTimeout: 30, tag: Client.Constants.Tags.readResponse)
        default:
            break
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        switch tag {
        case Client.Constants.Tags.readResponse:
            client?.didReceive(response: data)
        default:
            break
        }
    }
}
