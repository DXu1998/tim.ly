//
//  MinutePicker.swift
//  tim.ly
//
//  Contains the view and delegate functionality for any UIPickerViews of 1-60 minutes
//
//  Created by Daniel Xu on 6/13/18.
//  Copyright © 2018 Daniel Xu. All rights reserved.
//

import Foundation
import UIKit

class MinutePicker: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 65
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        
    }
    
}
