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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO read settings values from pList and set switches and counters appropriately
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // all the switch functions
    @IBAction func pomodoroChanged(_ sender: Any) {
        pomodoroLabel.text = "\(Int(pomodoroSwitch.value)) Min."
    }
    
    @IBAction func shortChanged(_ sender: Any) {
        shortLabel.text = "\(Int(shortSwitch.value)) Min."
    }
    
    @IBAction func longChanged(_ sender: Any) {
        longLabel.text = "\(Int(longSwitch.value)) Min."
    }
    
    @IBAction func sessionChanged(_ sender: Any) {
        sessionLabel.text = "\(Int(sessionSwitch.value)) Pomodoros"
    }
    
    @IBAction func dailyChanged(_ sender: Any) {
        dailyLabel.text = "\(Int(dailySwitch.value)) Sessions"
    }
    
    
    // define back button action
    @IBAction func backButtonPressed(_ sender: Any) {
        
        // TODO update values in pList
        
        // update info back in original view controller
        delegate?.updateSettings()
        
        self.dismiss(animated: true, completion: nil)
    }
    

}
