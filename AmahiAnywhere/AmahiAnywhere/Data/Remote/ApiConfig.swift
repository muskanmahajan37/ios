//
//  ********************************************************
//  *************   DO NOT COMMMIT THIS FILE   *************
//  *************         DO NOT SHARE IT      *************
//  ************* It Has Sensitive Credentials *************
//  ********************************************************
//
//  AmahiAnywhere/AmahiAnywhere/Data/Remote/ApiConfig.swift
//
//  AmahiAnywhere
//
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

struct ApiConfig {
    
    static let baseUrl =                       "https://example.com"
    static let proxyUrl =                      "https://example.com"
    
    private static let CLIENT_ID =              "C-I-D"
    private static let CLIENT_SECRET =          "C-S-T"
    
    
    static func oauthCredentials(username: String, password: String) -> [String : String] {
        
        let parameters =                          ["client_id": CLIENT_ID,
                                                   "client_secret": CLIENT_SECRET,
                                                   "username" : username,
                                                   "password" : password ]
        
        return parameters
    }
    
}
