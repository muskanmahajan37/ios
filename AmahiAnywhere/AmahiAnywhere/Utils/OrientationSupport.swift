//
//  OrientationSupport.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 30/05/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import Foundation

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
}
