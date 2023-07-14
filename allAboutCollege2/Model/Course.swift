//
//  Course.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 4/24/23.
//

import Foundation
import RealmSwift


class Course:Object {
   @objc dynamic var subjectCode : String = ""
   @objc dynamic var courseNum = 1
   @objc dynamic var courseName : String = ""
    @objc dynamic var crn = 1
    @objc dynamic var type : String = ""
    @objc dynamic var section : String = ""
    @objc dynamic var time : String = ""
    @objc dynamic var day : String = ""
    @objc dynamic var location : String = ""
    @objc dynamic var instructor : String = ""
}
