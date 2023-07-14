//
//  Schedule.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/11/23.
//

import Foundation
class Schedule{
    var name : String
    let term : String
    let scheduleID: String
    let date: Date
    init(name:String, term:String,scheduleID:String, date:Date) {
        self.name = name
        self.term = term
        self.scheduleID = scheduleID
        self.date = date
    }
}
