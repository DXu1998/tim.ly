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
    
    init(pomodoro: Pomodoro) {
        self.pomodoroState = pomodoro
    }
    
}

