//
//  ViewController.swift
//  tim.ly
//
//  Created by Daniel Xu on 6/2/18.
//  Copyright © 2018 Daniel Xu. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController, SettingsDelegate {

    // UI elements
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerBar: UIProgressView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var roundBar: UIProgressView!
    @IBOutlet weak var modeLabel: UILabel!
    
    // other things
    var seconds = 5
    var secondsSet = 5
    var timer = Timer()
    
    // some state things
    var timerIsRunning = false
    
    // some constants
    let alertSound: SystemSoundID = 1009
    let pomodoro = Pomodoro()
    
    
    // Begin functions here
    
    override func viewDidLoad() {
        
        // we do some housekeeping and initial conditions
        super.viewDidLoad()
        timerBar.progress = 0.0
        roundBar.progress = 0.0
        modeLabel.text = pomodoro.toString()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func runTimer() {
        
        // we set the timer duration
        secondsSet = pomodoro.stateDurations[pomodoro.currentState]! * 60
        seconds = secondsSet
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        timerIsRunning = true
    }
    
    func signalEnd() {
        
        // update state
        pomodoro.advanceState(endedNaturally: true)
        
        // soem basic housekeeping that may be reset
        secondsSet = pomodoro.stateDurations[pomodoro.currentState]! * 60
        seconds = secondsSet
        timerIsRunning = false
        
        runTimer()
        
        // update our labels
        updateTimerLabel()
        startButton.setTitle("Pause", for: .normal)
        modeLabel.text = pomodoro.toString()
        
        AudioServicesPlaySystemSound(alertSound)
        
    }
    
    @objc func updateTimer() {
        
        // we update our timer
        seconds -= 1
        
        if seconds < 1 {
            timer.invalidate()
            signalEnd()
        }
        
        updateTimerLabel()
        
    }
    
    func updateTimerLabel() {
        
        // we pull the values we need to display
        var minutesLeft = String(Int(seconds / 60))
        var secondsLeft = String(Int(seconds % 60))
        
        // some formatting things
        if Int(seconds / 60) < 10 {
            minutesLeft = "0" + minutesLeft
        }
        if Int(seconds % 60) < 10 {
            secondsLeft = "0" + secondsLeft
        }
        
        timerLabel.text = "\(minutesLeft):\(secondsLeft)"
        
        // update progress bars
        timerBar.progress = Float(secondsSet - seconds) / Float(secondsSet)
        roundBar.progress = Float(pomodoro.numSessions) / Float(4)
        
    }
    
    // Here begins all the dumb code controlling our buttons
    
    // --- Code for the stop button ---
    
    // for the inital color change
    @IBAction func stopPress(_ sender: UIButton) {
        
        stopButton.backgroundColor = UIColor(red: 0.09, green: 0.26, blue: 0.44, alpha: 1)
        
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        
        // change button color back
        stopButton.backgroundColor = UIColor(red: 0.12, green: 0.29, blue: 0.46, alpha: 1)
        
        // stop the timer
        timer.invalidate()
        
        // update state
        pomodoro.advanceState(endedNaturally: false)
        
        // reset things
        secondsSet = pomodoro.stateDurations[pomodoro.currentState]! * 60
        seconds = secondsSet
        timerIsRunning = false
        
        // update our labels
        updateTimerLabel()
        startButton.setTitle("Start", for: .normal)
        modeLabel.text = pomodoro.toString()
        
    }
    

    // really only used to change button color on press
    @IBAction func startPress(_ sender: UIButton) {
        
        startButton.backgroundColor = UIColor(red: 0.09, green: 0.26, blue: 0.44, alpha: 1)
        
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        
        // change button color back
        startButton.backgroundColor = UIColor(red: 0.12, green: 0.29, blue: 0.46, alpha: 1)
        
        if !timerIsRunning {
            startButton.setTitle("Pause", for: .normal)
            timerIsRunning = true
            runTimer()
        }
        else {
            startButton.setTitle("Start", for: .normal)
            timer.invalidate()
            timerIsRunning = false
        }
    }
    
    // segway preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // make ourselves grabbable for the new ViewController
        if segue.identifier == "settingsSegue" {
            let destinationVC = segue.destination as! SettingsViewController
            destinationVC.delegate = self
        }
        
    }
    
    // implementation of settings delegate
    func updateSettings() {
        
    }
    
}

