//
//  BackgroundManager.swift
//  tim.ly
//
//  Manages the app when it goes into background
//  Ensures timer continuity and schedules and deschedules timer notifications
//
//  Created by Daniel Xu on 6/28/18.
//  Copyright © 2018 Daniel Xu. All rights reserved.
//

import Foundation
import UserNotifications

class BackgroundManager {
    
    var secondsLeft = -1 // seconds left on the timer in the ViewController at time of backgrounding
    var pomodoroState: Pomodoro // holds reference to pomodoro state object passed by ViewController
    var bgTime = Date() // contains the time of backgrounding
    var parentVC: ViewController // holds reference to our containing ViewController
    
    let defaults = UserDefaults.standard
    
    // constructor needs pomodoro passed
    init(vc: ViewController) {
        self.parentVC = vc
        self.pomodoroState = vc.pomodoro
    }
    
    // for use when app is backgrounding -- saves the current timestamp
    func saveState() {
        
        // we save the time of backgrounding
        secondsLeft = parentVC.seconds
        bgTime = Date()
        
        // we get the notifications saved
        // this may take awhile which is why we do this after we've saved the time of stoppage
        if parentVC.timerIsRunning {
            scheduleNotifications(timeRemaining: secondsLeft)
        }
            
        // then we save everything about the app state to UserDefaults in case we don't come back
        defaults.set(parentVC.timerIsRunning, forKey: "timerIsRunning")
        defaults.set(secondsLeft, forKey: "secondsLeft")
        defaults.set(parentVC.secondsSet, forKey: "secondsSet")
        defaults.set(pomodoroState.goalProgress, forKey: "goalProgress")
        defaults.set(pomodoroState.numSessions, forKey: "numSessions")
        defaults.set(bgTime, forKey: "bgTime")
        
        // because we can't store enums explicitly
        switch pomodoroState.currentState {
            
        case PomodoroState.shortBreak:
            defaults.set(2, forKey: "currentState")
        
        case PomodoroState.longBreak:
            defaults.set(3, forKey: "currentState")
        
        case PomodoroState.work:
            defaults.set(1, forKey: "currentState")
        
        }
        
        // to avoid null value situations when we boot up the app for the first time
        defaults.set(true, forKey: "shouldRecoverState")
        
    }
    
    // advances pomodoro state to appropriate point after coming out of background mode
    func incrementPomodoro(timeElapsed: Int) {
        
        // if we don't actually need to advance the state
        if timeElapsed < secondsLeft {
            secondsLeft -= timeElapsed
        }
            
        else {
            
            // we make one advance of the state
            var time = timeElapsed
            time -= secondsLeft
            secondsLeft = 0 // technically all the time here was used up
            pomodoroState.advanceState(endedNaturally: true) // we finish out our state
            
            // we decide if we need to advance the state again
            while true {
                
                // if we do need to advance the state
                if time >= 60 * pomodoroState.stateDurations[pomodoroState.currentState]! {
                    
                    // we subtract away the duration of that state
                    time -= 60 * pomodoroState.stateDurations[pomodoroState.currentState]!
                    
                    // we actually advance the state
                    pomodoroState.advanceState(endedNaturally: true)
                    
                }
                
                // if we don't we redistribute some things and cancel out
                else {
                    
                    // we assign the leftovers to secondsLeft to be passed out of here
                    secondsLeft = 60 * pomodoroState.stateDurations[pomodoroState.currentState]! - time
                    break
                    
                }
                
            }
            
        }
        
    }
    
    // calculates time passed and calculates current pomodoro state for UI updates
    func recoverState() {
        
        // check if we need to recover the state
        let shouldRecoverState = defaults.bool(forKey: "shouldRecoverState")
        
        if !shouldRecoverState {
            return
        }
        
        // we dump all our notifications if we need to
        descheduleNotifications()
        
        // we recover the state of our app from where we left off
        parentVC.timerIsRunning = defaults.bool(forKey: "timerIsRunning")
        parentVC.secondsSet = defaults.integer(forKey: "secondsSet")
        parentVC.seconds = defaults.integer(forKey: "secondsLeft")
        secondsLeft = parentVC.seconds
        pomodoroState.goalProgress = defaults.integer(forKey: "goalProgress")
        pomodoroState.numSessions = defaults.integer(forKey: "numSessions")
        
        // it's a little trickier to get the date object in case it's null
        let bgTimeOptional = defaults.object(forKey: "bgTime") as? Date
        
        // we tentatively unwrap the optional
        if (bgTimeOptional != nil) {
            
            bgTime = bgTimeOptional!
            
            // then we check to see if we should reset our daily goal -- basically if we've passed midnight
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "en_US")

            // we grab the current time
            let currentDate = Date()
            
            let strCurDate = dateFormatter.string(from: currentDate)
            let strBgDate = dateFormatter.string(from: bgTime)
            
            if strBgDate != strCurDate {
                pomodoroState.goalProgress = 0
            }
            
        }
        
        
        
        switch defaults.integer(forKey: "currentState") {
        case 1:
            pomodoroState.currentState = PomodoroState.work
        case 2:
            pomodoroState.currentState = PomodoroState.shortBreak
        case 3:
            pomodoroState.currentState = PomodoroState.longBreak
        default:
            pomodoroState.currentState = PomodoroState.work
        }
        
        // if the timer was running and we need to calculate a new time
        if parentVC.timerIsRunning {
        
            // holder variable for the time we put out
            var finalTime = 0
            
            // below is technically a TimeInterval object which we cast into its number of seconds
            let timeElapsed = Int(Date().timeIntervalSince(bgTime))
            incrementPomodoro(timeElapsed: timeElapsed)
            
            finalTime = secondsLeft
            
            parentVC.seconds = finalTime
            
            // we check if we might be on a different state and update accordingly
            parentVC.secondsSet = 60 * pomodoroState.stateDurations[pomodoroState.currentState]!
            parentVC.modeLabel.text = pomodoroState.toString()
            
            // we change allow the timer to continue running in the viewController
            parentVC.continueTimer()
            parentVC.startButton.setTitle("Pause", for: .normal)
            
        }
        
        // we update the appearance of the UI
        parentVC.updateTimerLabel()
        
    }
    
    // Schedules all the necessary notifications when app is backgrounding
    func scheduleNotifications(timeRemaining: Int) {
        
        // we create our three types of notifications
        let pomodoroNotification = UNMutableNotificationContent()
        pomodoroNotification.body = "Pomodoro finished"
        pomodoroNotification.sound = UNNotificationSound.default()
        
        let sBreakNotification = UNMutableNotificationContent()
        sBreakNotification.body = "Short break finished"
        sBreakNotification.sound = UNNotificationSound.default()

        let lBreakNotification = UNMutableNotificationContent()
        lBreakNotification.body = "long break finished"
        lBreakNotification.sound = UNNotificationSound.default()
        
        // we copy our pomodoro
        let cpPomodoro = pomodoroState.copy() as! Pomodoro
        
        // we schedule our first notification
        var useContent = pomodoroNotification
        
        // first we figure out which notification to schedule
        switch cpPomodoro.currentState {
            case PomodoroState.shortBreak:
                useContent = sBreakNotification
            case PomodoroState.longBreak:
                useContent = lBreakNotification
            case PomodoroState.work:
                useContent = pomodoroNotification
        }
        
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeRemaining), repeats: false)
         let request = UNNotificationRequest(identifier: "PomodoroNotification", content: useContent, trigger: trigger)
         UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        // we advance the state of our copied pomodoro because we've scheduled a notification for it
        cpPomodoro.advanceState(endedNaturally: true)
        
        // we make a copy of our timeRemaining for future use
        var cumulTime = timeRemaining
        
        // we go ahead and schedule the next 52 notifications
        for i in 1...52 {
            
            // we create this loop's identifier
            let strIdentifier = "pomNotification\(i)"
            
            // first we figure out what notification we should use next
            switch cpPomodoro.currentState {
                
            case PomodoroState.shortBreak:
                
                // we should note that going forward cumulTime is in seconds
                cumulTime += 60 * cpPomodoro.stateDurations[cpPomodoro.currentState]!
                
                // we create our notification and schedule it
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(cumulTime), repeats: false)
                let request = UNNotificationRequest(identifier: strIdentifier, content: sBreakNotification, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
            case PomodoroState.longBreak:
                
                cumulTime += 60 * cpPomodoro.stateDurations[cpPomodoro.currentState]!
                
                // we create our notification and schedule it
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(cumulTime), repeats: false)
                let request = UNNotificationRequest(identifier: strIdentifier, content: lBreakNotification, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
            case PomodoroState.work:
                
                cumulTime += 60 * cpPomodoro.stateDurations[cpPomodoro.currentState]!
                
                // we create our notification and schedule it
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(cumulTime), repeats: false)
                let request = UNNotificationRequest(identifier: strIdentifier, content: pomodoroNotification, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
            }
            
            // we advance our pomodoro to set the next notification
            cpPomodoro.advanceState(endedNaturally: true)
            
        }

    }
    
    // deschedules all the notifications remaining when app is coming out of background
    func descheduleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}

