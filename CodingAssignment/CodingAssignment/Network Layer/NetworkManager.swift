//
//  NetworkManager.swift
//  CodingAssignment
//
//  Created by FT User on 14/10/20.
//  Copyright © 2020 FT User. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    
    var authorizationCookie = EMPTY_STRING
    var operationQueue = OperationQueue.init()
    var xcsrf_token = EMPTY_STRING
    var set_cookie = EMPTY_STRING
    var session:URLSession!
    
    static let sharedHandler = NetworkManager.init()
    
    var isInternetAvailable:Bool {
        get {
            
            let reachbility = try? Reachability.init()
            reachbility?.allowsCellularConnection = true
            return reachbility?.connection != .unavailable
        }
        set{
            
        }
    }
    
    private override init() {
        super.init()
        
        // setting up session
        self.session = URLSession.shared
        session.configuration.httpShouldSetCookies = true
        session.configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.onlyFromMainDocumentDomain
        session.configuration.httpCookieStorage?.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.onlyFromMainDocumentDomain
    }
    
    
    // Error message in case of Internet connectivity issues
    func prepareErrorForNoInterNet() -> NSError {
        
        let error = NSError.init(domain: NETWORK_ERROR, code: 404, userInfo: [NSLocalizedDescriptionKey: CHECK_INTERNET])
        return error
    }
    
    // GET request
    func makeGetRequestFor(url: String, completion: @escaping((URLResponse?, Error?, Data?)->Void)) {
        
        if isInternetAvailable {
            operationQueue.addOperation {
                
                let url = URL.init(string: url)!
                
                // prepare url request and set headers
                var req = URLRequest.init(url: url)
                req.setValue(self.authorizationCookie, forHTTPHeaderField: "Cookie")
                req.setValue("application/json", forHTTPHeaderField: "Accept")
                req.setValue("fetch", forHTTPHeaderField: "X-CSRF-Token")
                
                if self.set_cookie.count > 0 {
                    req.setValue(self.set_cookie, forHTTPHeaderField: "Set-Cookie")
                }
                
                // create urlsession task
                let task = self.session.dataTask(with: req) { (data, res, err) in
                    if let apiData = data {
                        
                        do {
                            let strISOLatin = String(data: apiData, encoding: .isoLatin1)
                            let dataUTF8 = strISOLatin?.data(using: .utf8)
                            
                            let headers = (res as? HTTPURLResponse)?.allHeaderFields
                            
                            self.set_cookie = headers?["Set-Cookie"] as? String ?? ""
                            self.xcsrf_token = headers?["x-csrf-token"] as? String ?? ""
                            
                            completion(res,err,dataUTF8)
                            
                        }
                        
                    } else {
                        completion(res, err, nil)
                    }
                    
                }
                task.resume()
            }
        } else {
            let error = prepareErrorForNoInterNet()
            completion(nil, error, nil)
        }
    }
}
