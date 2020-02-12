//
//  MemeMeTextFieldDelegate.swift
//  MemeMe-1.0
//
//  Created by Anderson Rodrigues on 11/11/2019.
//  Copyright © 2019 Anderson Rodrigues. All rights reserved.
//

import UIKit

class MemeMeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text! == "TOP" || textField.text! == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}
