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
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var goalBar: UIProgressView!
    
    // some constants set for the puposes of the pomodoro timer
    var seconds = -1
    var secondsSet = -1
    var timer = Timer()
    
    // some state things
    var timerIsRunning = false
    
    // some constants
    let alertSound: SystemSoundID = 1009
    let pomodoro = Pomodoro() // pomodoro state machine -- contains all relevant data for pomodoro running
    var configPath = "" // empty to begin with
    var bgManager: BackgroundManager! // handles foregrounding and backgrounding procedure for app
    
    
    // Begin functions here
    
    override func viewDidLoad() {
        
        // we do some housekeeping and initial conditions
        super.viewDidLoad()
        timerBar.progress = 0.0
        roundBar.progress = 0.0
        modeLabel.text = pomodoro.toString()
        
        // we check how our config.plist file is doing and move it to the documents directory if we need to
        // code mostly copied from StackOverflow
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let plistPath = paths.appending("/config.plist")
        let fileManager = FileManager.default
        
        // if we can't find our plist in the documents directory
        if !fileManager.fileExists(atPath: plistPath)
        {
            // we copy everything over
            let bundle = Bundle.main.path(forResource: "config", ofType: "plist")
            try! fileManager.copyItem(atPath: bundle!, toPath: plistPath)
        }
        
        configPath = plistPath
        
        // we pull the settings off the pList
        updateSettings()
        
        // we set our labels initially -- we multiply by 60 b/c the pomdoro class stores time in minutes
        secondsSet = 60 * pomodoro.stateDurations[pomodoro.currentState]!;
        seconds = secondsSet;
        
        updateTimerLabel()
        
        // we properly instantiate the BackgroundManager
        bgManager = BackgroundManager(pomodoro: self.pomodoro)
        
        // we instantiate listeners/observers to trigger operations on app foregrounding and backgrounding
        NotificationCenter.default.addObserver(self, selector: #selector(prepForBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(prepForForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func prepForBackground() {
        
        print("did background")
        
        bgManager!.saveTime(curSeconds: seconds)

    }
    
    @objc func prepForForeground() {
        
        timerIsRunning = bgManager!.loadContext()
        
        // basically if we're foregrounding from the background
        if timerIsRunning {
            // we update the current time on the clock from our background manager
            seconds = bgManager!.updateTime()
            
            // we check if we might be on a different state and update accordingly
            secondsSet = 60 * pomodoro.stateDurations[pomodoro.currentState]!
            modeLabel.text = pomodoro.toString()
        }
        
        // if we're foregrounding as part of initial startup or if the timer isn't running
        // either way we shouldn't mess anything up by restoring the state from the ContinuityManager
        else {
            
        }

    }
    
    // implementation of settings delegate
    func updateSettings() {
        
        // we grab our settings from the pList
        
        // we need some optionals in case the config pList is no good
        // btw I anticipate this happening approximately never
        var myConfig: NSDictionary?
        myConfig = NSDictionary(contentsOf: URL(fileURLWithPath: configPath))

        // we unwrap the dict optional and see what we get out of it
        if let configDict = myConfig {
            
            // we set all the values in the pomodoro
            
            // please don't ask me how this cast works -- I really have no f*cking clue
            pomodoro.sessionGoal = Int((configDict.value(forKey: "sessionGoal") as! NSNumber).doubleValue)
            pomodoro.dailyGoal = Int((configDict.value(forKey: "dailyGoal") as! NSNumber).doubleValue)
            pomodoro.stateDurations[PomodoroState.work] = Int((configDict.value(forKey: "pomodoroLength") as! NSNumber).doubleValue)
            pomodoro.stateDurations[PomodoroState.shortBreak] = Int((configDict.value(forKey: "shortLength") as! NSNumber).doubleValue)
            pomodoro.stateDurations[PomodoroState.longBreak] = Int((configDict.value(forKey: "longLength") as! NSNumber).doubleValue)
            
        }
        
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
    
    func continueTimer() {
        
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
        roundBar.progress = Float(pomodoro.numSessions) / Float(pomodoro.sessionGoal)
        goalBar.progress = Float(pomodoro.goalProgress) / Float(pomodoro.dailyGoal)
        
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
            continueTimer()
        }
        else {
            startButton.setTitle("Start", for: .normal)
            timer.invalidate()
            timerIsRunning = false
        }
    }
    
    // shade in settings button on press
    @IBAction func settingsPressed(_ sender: Any) {
        settingsButton.backgroundColor = UIColor(red: 0.09, green: 0.26, blue: 0.44, alpha: 1)
    }
    
    // segway preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // make ourselves grabbable for the new ViewController
        if segue.identifier == "settingsSegue" {
            
            // we make the correct cast
            let destinationVC = segue.destination as! SettingsViewController
            
            // we pass our new SettingsViewController some information
            destinationVC.delegate = self
            destinationVC.configPath = self.configPath
            
            destinationVC.dailyGoal = pomodoro.dailyGoal
            destinationVC.longLength = pomodoro.stateDurations[PomodoroState.longBreak]!
            destinationVC.shortLength = pomodoro.stateDurations[PomodoroState.shortBreak]!
            destinationVC.pomodoroLength = pomodoro.stateDurations[PomodoroState.work]!
            destinationVC.sessionGoal = pomodoro.sessionGoal
            
        }
        
    }
    
}

