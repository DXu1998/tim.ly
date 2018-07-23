//
//  Period.swift
//  tim.ly
//
//  Data storage object for use in Realm database
//
//  Created by Daniel Xu on 7/22/18.
//  Copyright © 2018 Daniel Xu. All rights reserved.
//

import Foundation
import RealmSwift

class Period: Object {
    
    // we assign a bunch of defaults that will pretty much always be changed
    
    @objc dynamic var completionTime: Date = Date()// timestamp of period completion
    @objc dynamic var duration: Int = -1// duration of previous period in minutes
    @objc dynamic var synced: Bool = false// if this particular reading has been synced with cloud
    @objc dynamic var pomodoroType: String = ""// the particular state of the pomodoro
   
}
