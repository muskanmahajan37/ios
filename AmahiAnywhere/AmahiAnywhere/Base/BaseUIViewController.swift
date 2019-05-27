//
//  BaseUIViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/17/18.
//  Copyright © 2018 Amahi. All rights reserved.


import UIKit
import Foundation
import GoogleCast

class BaseUIViewController: UIViewController {
    
    override func viewDidLoad() {
      //  let castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        //castButton.tintColor = UIColor.gray
        //navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
          let castButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = UIColor.red
       // navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
        self.navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
        
        print("#############")
        print("#############")
        print("#############")
        print("#############")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavigationBarBackgroundAccordingToCurrentConnectionMode()
        addActiveDownloadObservers()
        addLanTestObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
}

extension BaseUIViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
}
