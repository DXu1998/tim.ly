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

class BackgroundManager {
    
    var secondsLeft = -1
    var pomodoroState: Pomodoro
    var bgTime = Date()
    
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
            pomodoroState.advanceState(endedNaturally: true)
            
            // we decide if we need to advance the state again
            while true {
                
                // if we do need to advance the state
                if time > 60 * pomodoroState.stateDurations[pomodoroState.currentState]! {
                    
                    // we subtract away the duration of that state
                    time -= 60 * pomodoroState.stateDurations[pomodoroState.currentState]!
                    
                    // we actually advance the state
                    pomodoroState.advanceState(endedNaturally: true)
                    
                }
                
                // if we don't we redistribute some things and cancel out
                else {
                    
                    // we assign what's left in time to secondsLeft to be passed out of here
                    secondsLeft = time
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
            
            didEnterBackground = false
            
            // below is technically a TimeInterval object which we cast into its number of seconds
            let timeElapsed = Date().timeIntervalSince(bgTime)
            incrementPomodoro(timeElapsed: Int(timeElapsed))
            
            finalTime = secondsLeft
            
        }
        
        return finalTime
        
    }
    
    // Schedules all the necessary notifications when app is backgrounding
    func scheduleNotifications() {
        
    }
    
    // deschedules all the notifications remaining when app is coming out of background
    func descheduleNotifications() {
        
    }
    
}

