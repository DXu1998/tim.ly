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
    
    // storing one or more readings -- we think it would probably be more efficient to write multiple readings as batches
    // indices of each array correspond to a particular time period -- sizes of all arrays must be same
    func storePeriod(cTimes: [Date], durations: [Int], syncs: [Bool], pTypes: [PomodoroState]) {
        
        let numReadings = cTimes.count
        
        // we start the enclosure for writing data to Realm
        do {
            
            // we start writing to realm
            try realm.write {
                
                // we iterate through every element in our arrays
                for i in 0...(numReadings - 1) {
                    
                    // we instantiate our object using our helper method
                    let bob = createPeriod(completionTime: cTimes[i], duration: durations[i], synced: syncs[i], pomodoroType: pTypes[i])
                    
                    // we write our object to Realm
                    realm.add(bob)
                    
                }
                
            }
            
        } catch {
            print("error encountered writing to Realm: \(error)")
        }
        
    }
    
}
