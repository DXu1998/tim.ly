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
    private func createPeriod(completionTime: Date, duration: Int, synced: Bool, pomodoroType: PomodoroState) -> Period {
    
        // we create a period objec to fill in
        let bob = Period()
        
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
    
    // storing a reading
    // it might be more efficient to group readings and write them as batches but whatever
    func storePeriod(cTime: Date, duration: Int, wasSynced: Bool, pType: PomodoroState) {
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        // we start the enclosure for writing data to Realm
        do {
            
            // we start writing to realm
            try realm.write {
                    
                // we instantiate our object using our helper method
                let bob = createPeriod(completionTime: cTime, duration: duration, synced: wasSynced, pomodoroType: pType)
                
                // we write our object to Realm
                realm.add(bob)
                
            }
            
        } catch {
            print("error encountered writing to Realm: \(error)")
        }
        
    }
    
}
