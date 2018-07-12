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
    var nIdentifiers: [String] = [] // contains the identifiers for all the scheduled notifications
    
    // state var to prevent things from happening when app initially boots up
    var didEnterBackground = false
    
    // constructor needs pomodoro passed
    init(pomodoro: Pomodoro) {
        self.pomodoroState = pomodoro
    }
    
    // for use when app is backgrounding -- saves the current timestamp
    func saveTime(curSeconds: Int) {
        
        didEnterBackground = true
        
        // we save the time of backgrounding
        secondsLeft = curSeconds
        bgTime = Date()
        
        // we get the notifications saved
        // this may take awhile which is why we do this after we've saved the time of stoppage
        scheduleNotifications(timeRemaining: secondsLeft)
        
        
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
    func updateTime() -> Int {
        
        // holder variable for the time we return out
        var finalTime = 0
        
        // we don't want this to run when app initially launches
        if didEnterBackground {
            
            // we dump all our notifications
            descheduleNotifications()
            
            didEnterBackground = false
            
            // below is technically a TimeInterval object which we cast into its number of seconds
            let timeElapsed = Int(Date().timeIntervalSince(bgTime))
            incrementPomodoro(timeElapsed: timeElapsed)
            
            finalTime = secondsLeft
            
        }
        
        return finalTime
        
    }
    
    // Schedules all the necessary notifications when app is backgrounding
    func scheduleNotifications(timeRemaining: Int) {
        
        // we clear all previously scheduled notifications
        nIdentifiers = []
        
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
        
        nIdentifiers.append("PomodoroNotification")
        
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
            
            // we save the identifier into our array
            nIdentifiers.append(strIdentifier)
            
        }

    }
    
    // deschedules all the notifications remaining when app is coming out of background
    func descheduleNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: nIdentifiers)
    }
    
    // handles saving of context to UserDefault
    func saveContext() {
        
    }
    
    // handles loading of app state from UserDefault and returns timerIsRunning var to main VC
    func loadContext() -> Bool {
        
        
        // TODO insert actual return
        return true
        
    }
    
}

