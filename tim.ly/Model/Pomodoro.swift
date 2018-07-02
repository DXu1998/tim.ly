//
//  Pomodoro.swift
//
//  State machine that keeps track of the current state of
//  the current Pomodoro
//
//  Also holds all the parameters for the pomodoro
//
//  Created by Daniel Xu on 6/6/18.
//  Copyright © 2018 Daniel Xu. All rights reserved.
//

import Foundation


enum PomodoroState {
    case work
    case shortBreak
    case longBreak
}

class Pomodoro: NSCopying {
    
    var numSessions = 0
    var currentState = PomodoroState.work
    var stateDurations: [PomodoroState: Int] = [PomodoroState.work: 1, PomodoroState.longBreak: 1, PomodoroState.shortBreak: 1]
    var dailyGoal = 12
    var sessionGoal = 4
    var goalProgress = 0

    
    init() {
        // this is the default initializer
    }
    
    // a constructor to support the copy constructor
    init(numSessions: Int, currentState: PomodoroState, stateDurations: [PomodoroState: Int], dailyGoal: Int, sessionGoal: Int, goalProgress: Int) {
        
        self.numSessions = numSessions
        self.currentState = currentState
        self.stateDurations = stateDurations
        self.dailyGoal = dailyGoal
        self.sessionGoal = sessionGoal
        self.goalProgress = goalProgress
        
    }
    
    // our actual copy constructor
    func copy(with zone: NSZone? = nil) -> Any {
        return Pomodoro(numSessions: self.numSessions, currentState: self.currentState, stateDurations: self.stateDurations, dailyGoal: self.dailyGoal, sessionGoal: self.sessionGoal, goalProgress: self.goalProgress)
    }
 
    // allows us to print current state
    func toString() -> String {
        
        switch currentState {
            
        case PomodoroState.shortBreak:
            return "Short Break"
            
        case PomodoroState.longBreak:
            return "Long Break"
            
        case PomodoroState.work:
            return "Work"
            
        }
        
    }
    
    // when we want to cancel out of our current session without touching anything
    func cancelSession() {
        advanceState(endedNaturally: false)
    }
    
    // when our current state has elapsed naturally
    func endSession() {
        advanceState(endedNaturally: true)
    }
    
    // when we want to reset the current session to 0 pomodoros done
    func clearSession() {
        
        currentState = PomodoroState.work
        numSessions = 0
        
    }
    
    func advanceState(endedNaturally: Bool) {
        
        // if we're coming out of a work session
        if currentState == PomodoroState.work {
            
            // we increment the counter if we need to
            if endedNaturally {
                numSessions += 1
            }
            
            // we decide if we want a long break or a short break
            if numSessions >= sessionGoal {
                currentState = PomodoroState.longBreak
            }
            else {
                currentState = PomodoroState.shortBreak
            }
            
        }
        
        // if we're coming out of a break
        else {

            // we reset our counter if previous was a long break
            if currentState == PomodoroState.longBreak {
                numSessions = 0
            }
            
            currentState = PomodoroState.work
            
        }
        
    }
    
}


