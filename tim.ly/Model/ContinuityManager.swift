//
//  ContinuityManager.swift
//  tim.ly
//
//  Manages the preservation of the app state on app termination and information retrieval when app restarts
//  Also for simplicity and nice structure this class will manage all interactions with the UserDefaults
//
//  Created by Daniel Xu on 7/8/18.
//  Copyright © 2018 Daniel Xu. All rights reserved.
//

import Foundation

class ContinuityManager {
    
    // saves all passed parameters into the UserDefaults
    // I am aware this is not exactly the explicit purpose of UserDefaults but whatever
    func saveState(quitTime: Date, secondsLeft: Int,numRounds: Int, goalProgress: Int, quitState: PomodoroState) {
        
    }
    
    // because I want to be cleaner and do the data encapsulation more, when loading parameters to restore the app state
    // each parameter will take its own function
    
    
    
}
