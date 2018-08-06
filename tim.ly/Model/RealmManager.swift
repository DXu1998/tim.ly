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
    
    // mainly just to add an observer for the background entering
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(prepForBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // just to remove the observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func prepForBackground() {
        syncToDatabase()
    }
    
    // Syncs our Realm database to the online MYSQL
    private func syncToDatabase() {
       
        // we query the realm database for readings that haven't been synced
        let periods = realm.objects(Period.self).filter("synced = false")
        
        // we iterate through each of the readings
        for period in periods {
            
            // we grab the string representation of the completion timestamp
            var strTime = period.completionTime.description
            
            // we format the string to what we need for the url request
            // we also take this opportunity to point out that string formatting in Swift is way harder than it should be
            strTime = strTime.replacingOccurrences(of: ":", with: "")
            strTime = strTime.replacingOccurrences(of: " ", with: "")
            strTime = strTime.replacingOccurrences(of: "-", with: "")
            
            let index = strTime.index(strTime.endIndex, offsetBy: -5)
            let sub = strTime[..<index]
            
            strTime = String(sub)
        
            // we declare the other variables we need for the sql insert
            var strDuration = "\(period.duration)"
        
            var strType = ""
            
            if period.pomodoroType == "short" {
                strType = "2"
            }
            else if period.pomodoroType == "long" {
                strType = "3"
            }
            else if period.pomodoroType == "work" {
                strType = "1"
            }
            else {
                strType = ""
            }
            
            // we create the url
            if let url = URL(string: "http://ec2-35-171-4-69.compute-1.amazonaws.com/insert.php?timestamp=\(strTime)&duration=\(strDuration)&type=\(strType)") {
                do {
                    
                    // we actually load the url
                    let contents = try String(contentsOf: url)
                    
                    // if we get back what we need
                    if contents != "success!" {
                        print("something went wrong")
                        break
                    }
                    
                } catch {
                    print("content could not be loaded")
                    break
                }
            } else {
                print("bad URL")
                break
            }
            
            // we enter the period as synced
            try! realm.write {
                period.synced = true
            }

            
        }
        
    }
    
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
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
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
