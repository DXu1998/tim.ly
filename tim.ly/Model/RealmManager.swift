//
//  RealmManager.swift
//  tim.ly
//
//  Handles writing to Realm and updating to cloud database when applicable
//
//  Created by Daniel Xu on 7/22/18.
//  Copyright © 2018 Daniel Xu. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMananager {
    
    let realm = try! Realm()
    
    // serves as initializer for the Realm Object since an actual init() method is more painful
    func createPeriod(completionTime: Date, duration: Int, synced: Bool, pomodoroType: PomodoroState) -> Period {
    
        // we create a period objec to fill in
        var bob = Period()
        
        // we set our attributes
        bob.completionTime = completionTime
        bob.duration = duration
        bob.synced = synced
        
        // the underlying obj-c won't handle our enum so we have to carry things over to strings
        switch pomodoroType {
        case PomodoroState.longBreak:
            bob.pomodoroType = "long"
        case PomodoroState.shortBreak:
            bob.pomodoroType = "short"
        case PomodoroState.work:
            bob.pomodoroType = "work"
        }
        
        return bob
    
    }
    
    // storing one or more readings
    
}
