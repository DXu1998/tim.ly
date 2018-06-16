//
//  SettingsViewController.swift
//  tim.ly
//
//  Created by Daniel Xu on 6/12/18.
//  Copyright © 2018 Daniel Xu. All rights reserved.
//

import UIKit

// to trigger settings refresh on pass back
protocol SettingsDelegate {
    func updateSettings()
}

class SettingsViewController: UIViewController {

    // some constants I really should pass over but whatever
    let configPath = Bundle.main.path(forResource: "config", ofType: "plist")
    
    // declare delegate variable
    var delegate: SettingsDelegate?
    
    // all switch variables
    @IBOutlet weak var pomodoroSwitch: UIStepper!
    @IBOutlet weak var shortSwitch: UIStepper!
    @IBOutlet weak var longSwitch: UIStepper!
    @IBOutlet weak var sessionSwitch: UIStepper!
    @IBOutlet weak var dailySwitch: UIStepper!
    
    
    // all counter label variables
    @IBOutlet weak var pomodoroLabel: UILabel!
    @IBOutlet weak var shortLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var dailyLabel: UILabel!
    
    // we also declare a set of variables to hold the actual values to avoid unpleasantness
    var pomodoroLength: Int = -1
    var shortLength: Int = -1
    var longLength: Int = -1
    var sessionGoal: Int = -1
    var dailyGoal: Int = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // we were passed the previous state's settings from the Pomdoro object held by ViewController and update the labels with those values
        // we should also note that the Pomdoro object's values were set from the pList so we have no issues there
        pomodoroLabel.text = "\(pomodoroLength) Min."
        pomodoroSwitch.value = Double(pomodoroLength)
        
        shortLabel.text = "\(shortLength) Min."
        shortSwitch.value = Double(shortLength)
        
        longLabel.text = "\(longLength) Min."
        longSwitch.value = Double(longLength)
        
        sessionLabel.text = "\(sessionGoal) Pomodoros"
        sessionSwitch.value = Double(sessionGoal)
        
        dailyLabel.text = "\(dailyGoal) Sessions"
        dailySwitch.value = Double(dailyGoal)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // all the switch functions
    @IBAction func pomodoroChanged(_ sender: Any) {
        pomodoroLength = Int(pomodoroSwitch.value)
        pomodoroLabel.text = "\(pomodoroLength) Min."
    }
    
    @IBAction func shortChanged(_ sender: Any) {
        shortLength = Int(shortSwitch.value)
        shortLabel.text = "\(shortLength) Min."
    }
    
    @IBAction func longChanged(_ sender: Any) {
        longLength = Int(longSwitch.value)
        longLabel.text = "\(longLength) Min."
    }
    
    @IBAction func sessionChanged(_ sender: Any) {
        sessionGoal = Int(sessionSwitch.value)
        sessionLabel.text = "\(sessionGoal) Pomodoros"
    }
    
    @IBAction func dailyChanged(_ sender: Any) {
        dailyGoal = Int(dailySwitch.value)
        dailyLabel.text = "\(dailyGoal) Sessions"
    }
    
    
    // define back button action
    @IBAction func backButtonPressed(_ sender: Any) {
        
        // TODO update values in pList
        updatePList()
        
        // update info back in original view controller
        delegate?.updateSettings()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func updatePList() {
        
        // we check that the path to the pList is good
        // we anticipate this being the case pretty mcuh always
        if let path = configPath {
            
            if var dict = NSMutableDictionary(contentsOfFile: path) {
                
                // we change the values in the dict
                dict.setValue(pomodoroLength as Any, forKey: "pomodoroLength")
                dict.setValue(dailyGoal as Any, forKey: "dailyGoal")
                dict.setValue(longLength as Any, forKey: "longLength")
                dict.setValue(sessionGoal as Any, forKey: "sessionGoal")
                dict.setValue(shortLength as Any, forKey: "shortLength")
                
                // we write the dict back to its URL
                dict.write(to: URL(fileURLWithPath: path), atomically: false)
                
            }
            
        }
        
    }
    

}
