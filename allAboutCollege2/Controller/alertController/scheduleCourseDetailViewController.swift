//
//  scheduleCourseDetailViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/20/23.
//

import UIKit
import Elliotable

protocol scheduleCourseDetailDelegate {
    func outsideTouchTapped()
    func removeButtonTapped()
}
class scheduleCourseDetailViewController: UIViewController {
    var main = MainTabBarController()
    var schDelegate : scheduleCourseDetailDelegate?
    var selectedschCourse : SchCourse?
    var elliotEventArray : [ElliottEvent] = []
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseID: UILabel!
    @IBOutlet weak var courseSection: UILabel!
    @IBOutlet weak var courseCRN: UILabel!
    @IBOutlet weak var courseType: UILabel!
    @IBOutlet weak var courseTime: UILabel!
    @IBOutlet weak var courseDay: UILabel!
    @IBOutlet weak var courseLocation: UILabel!
    @IBOutlet weak var courseInstructor: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        courseName.text = selectedschCourse!.courseId
        courseID.text = selectedschCourse!.courseName
        courseSection.text = selectedschCourse!.section
    
        courseCRN.text = selectedschCourse!.crn?.description
        courseType.text = selectedschCourse!.type
        courseTime.text = selectedschCourse!.time
        courseDay.text = selectedschCourse!.courseDay
        courseLocation.text = selectedschCourse!.roomName
        courseInstructor.text = selectedschCourse!.professor
        
        courseName.sizeToFit()
        courseID.sizeToFit()
        courseSection.sizeToFit()
        courseCRN.sizeToFit()
        courseType.sizeToFit()
        courseTime.sizeToFit()
        courseDay.sizeToFit()
        courseLocation.sizeToFit()
        courseInstructor.sizeToFit()
        
        
    }
    

    @IBAction func removeButtonTapped(_ sender: Any) {
        self.schDelegate?.removeButtonTapped()
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.schDelegate?.outsideTouchTapped()

    }
    override func viewDidDisappear(_ animated: Bool) {
    }

}
