//
//  Connector.swift
//  Down
//
//  Created by Ruud Puts on 18/12/15.
//  Copyright © 2015 Ruud Puts. All rights reserved.
//

import Alamofire

public protocol Connector {
    
    var host: String? { get set }
    var apiKey: String? { get set }
    
    func validateHost(host: String, completion: (hostValid: Bool, apiKey: String?) -> (Void))
    
    func fetchApiKey(completion: (String?) -> (Void))
    func fetchApiKey(username username: String?, password: String?, completion: (String?) -> (Void))
    
}

extension Response {

    // TODO: Use this in a Bolts implementation
    func validateResponse() -> Bool {
        return result.isSuccess && response != nil && response?.statusCode < 400
    }
    
}