//
//  ScheduleViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 4/22/23.
//

import UIKit
import RealmSwift
import SwiftCSV
import Firebase
import DropDown
import Elliotable
import BTNavigationDropdownMenu
class ScheduleViewController: UIViewController {
    
    static var delete:Bool = false
    lazy var realm:Realm = {
         return try! Realm()
     }()
    var courseRealmList : Results<Course>?
    var mainTabBarController = MainTabBarController()
    private let daySymbol = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    let uid = Auth.auth().currentUser?.uid
    var elliotEventArray:[ElliottEvent] = []
    var selectschCourse :SchCourse?
    let testLabel = UILabel()
    let itemList = ["Edit Schedule Name","Delete Schedule"]
    
    
  
    
    @IBOutlet weak var timetable: Elliotable!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(selectedSchedule), name: NSNotification.Name(rawValue: "scheduleChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedSchedule), name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(labelShow), name: NSNotification.Name(rawValue: "labelShow"), object: nil)
        
        let config1 = Realm.Configuration(
            fileURL: Bundle.main.url(forResource: "Course", withExtension: "realm"), readOnly: true)
        realm = try! Realm(configuration: config1)
        courseRealmList = realm.objects(Course.self)
        timetable.delegate = self
        timetable.dataSource = self
        timetable.isFullBorder = true
        timetable.roundCorner   = .none
        timetable.borderWidth   = 1
        timetable.courseItemTextSize = 12.5
        timetable.elliotBackgroundColor = UIColor.white
        timetable.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        timetable.symbolBackgroundColor = UIColor.lightGray
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let addClass = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(addButtonTapped) )
        
        self.tabBarController?.navigationItem.rightBarButtonItem = addClass
        print("show")
        labelShow()
        reload()
        
        
        
    }
    
    
    
    @objc func selectedSchedule(){
        DispatchQueue.main.async {
            self.reload()
        }
        
    }
  
    
    @objc func addButtonTapped(){
        
        let viewController =
        self.storyboard?.instantiateViewController(withIdentifier: "courseViewController") as! courseViewController
        if mainTabBarController.courseList?.isEmpty == false{
            viewController.SchcourseList = mainTabBarController.courseList!
        }
        self.navigationController?.pushViewController(viewController, animated: true)
        reload()
    }
    
    @objc func actionButtonTapped(){
            
    }
    
    
    func reload(){
        print("label5:\(mainTabBarController.scheduleArray.count)")
      
        print(mainTabBarController.scheduleArray.count)
        if mainTabBarController.scheduleArray.isEmpty == false{
            print("working1")
            if MainTabBarController.currentSchedule == nil{
                print("working1")
                MainTabBarController.currentSchedule = mainTabBarController.scheduleArray[0]
                mainTabBarController.loadScheduleCourse(schedule:MainTabBarController.currentSchedule!) { (result) in
                    self.mainTabBarController.courseList = result!
                    self.timetable.reloadData()
                }
                mainTabBarController.loadAddedCourse(schedule:MainTabBarController.currentSchedule!) { (result) in
                    self.mainTabBarController.addedCourse = result!
                    print("addedCourseNum:\(self.mainTabBarController.addedCourse.count)")
                    print("addedCourse:\(self.mainTabBarController.addedCourse)")
                }
            }
            else{
                print("working2")
                mainTabBarController.loadScheduleCourse(schedule:MainTabBarController.currentSchedule!) { (result) in
                    self.mainTabBarController.courseList = result!
                    self.timetable.reloadData()
                }
                
                mainTabBarController.loadAddedCourse(schedule:MainTabBarController.currentSchedule!) { (result) in
                    self.mainTabBarController.addedCourse = result!
                    print("addedCourseNum2:\(self.mainTabBarController.addedCourse.count)")
                    print("addedCourse2:\(self.mainTabBarController.addedCourse)")
                }
            }
        }
        else{
            if MainTabBarController.currentSchedule != nil{
                mainTabBarController.loadScheduleCourse(schedule:MainTabBarController.currentSchedule!) { (result) in
                    self.mainTabBarController.courseList = result!
                    self.timetable.reloadData()
                }
                
                mainTabBarController.loadAddedCourse(schedule:MainTabBarController.currentSchedule!) { (result) in
                    self.mainTabBarController.addedCourse = result!
                    
                }
            }
        }
        
        
      
    }
    
    
    @objc func labelShow(){
        mainTabBarController.loadSchedule(){ (ScheduleArray)->Void in
            print("count\(ScheduleArray?.count)")
            self.mainTabBarController.scheduleArray = []
            for i in 0..<ScheduleArray!.count {
                self.mainTabBarController.scheduleArray.append(ScheduleArray![i])
            }
            if(self.mainTabBarController.scheduleArray.count == 0){
                self.timetable.isHidden = true
                self.view.addSubview(self.testLabel)
                print("labelshown")
                let attributedString = NSMutableAttributedString(string: "")
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName:"calendar.badge.plus")
                imageAttachment.bounds = CGRect(x: 0, y: -6, width: 25, height: 25)
                attributedString.append(NSAttributedString(string: "Create your own class \n schedule by clicking "))
                attributedString.append(NSAttributedString(attachment: imageAttachment))
                self.testLabel.attributedText = attributedString
                
                self.testLabel.translatesAutoresizingMaskIntoConstraints = false
                self.testLabel.sizeToFit()
                self.testLabel.numberOfLines = 2
                self.testLabel.font = UIFont.systemFont(ofSize: 25)
                self.testLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                self.testLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                print("enable3")
                self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = false
                self.tabBarController?.navigationItem.leftBarButtonItems![1].isEnabled = false
                self.testLabel.isHidden = false

            }
            else{
                print("labelhidden")
                self.testLabel.isHidden = true
                self.timetable.isHidden = false
                self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = true
                self.tabBarController?.navigationItem.leftBarButtonItems![1].isEnabled = true
            }
            print("label4:\(self.mainTabBarController.scheduleArray.count)")
        }
        
    }
    
    
}
    
    extension ScheduleViewController:ElliotableDelegate,ElliotableDataSource{
        func elliotable(elliotable: Elliotable, didSelectCourse selectedCourse: ElliottEvent) {
            var courseTotalDay :String = ""
            var selectedschCourse:SchCourse?
            self.tabBarController!.navigationController?.navigationBar.isUserInteractionEnabled = false
            let scheduleDetail = UIStoryboard.init(name: "scheduleCourseDetail", bundle: nil)
            let schDetail = scheduleDetail.instantiateViewController(withIdentifier:"scheduleCourseDetailViewController" ) as! scheduleCourseDetailViewController
            schDetail.schDelegate = self
            schDetail.modalPresentationStyle = .overCurrentContext
            schDetail.providesPresentationContextTransitionStyle = true
            schDetail.definesPresentationContext = true
            schDetail.modalTransitionStyle = .crossDissolve
            elliotEventArray = []
            
            for i in 0..<mainTabBarController.courseList!.count{
                var compareCourse = mainTabBarController.courseList![i]
                if(selectedCourse.backgroundColor == compareCourse.backgroundColor){
                    if compareCourse.courseDay == .monday{
                        courseTotalDay += "M"
                    }
                    else if compareCourse.courseDay == .tuesday{
                        courseTotalDay += "T"
                    }
                    else if compareCourse.courseDay == .wednesday{
                        courseTotalDay += "W"
                    }
                    else if compareCourse.courseDay == .thursday{
                        courseTotalDay += "R"
                    }
                    else if compareCourse.courseDay == .friday{
                        courseTotalDay += "F"
                    }
                }
            }
            for i in 0..<mainTabBarController.addedCourse.count{
                var compareCourse = mainTabBarController.addedCourse[i]
                if(selectedCourse.courseId == compareCourse.courseId && selectedCourse.courseName == compareCourse.courseName && selectedCourse.startTime == compareCourse.startTime && selectedCourse.endTime == compareCourse.endTime && compareCourse.courseDay == courseTotalDay && selectedCourse.professor == compareCourse.professor && selectedCourse.roomName == compareCourse.roomName){
                    selectedschCourse = SchCourse(courseId: compareCourse.courseId, courseName: compareCourse.courseName, roomName: compareCourse.roomName, professor: compareCourse.professor, courseDay: compareCourse.courseDay, startTime: compareCourse.startTime, endTime: compareCourse.endTime, section:compareCourse.section,schCourseId: compareCourse.schCourseId, time: compareCourse.time, crn: compareCourse.crn, type: compareCourse.type)
                }
            }
            selectschCourse = selectedschCourse
            schDetail.selectedschCourse = selectedschCourse
            self.present(schDetail,animated:true, completion: nil)
        }
        
        func elliotable(elliotable: Elliotable, didLongSelectCourse longSelectedCourse: ElliottEvent) {
            
        }
        
        func elliotable(elliotable: Elliotable, at dayPerIndex: Int) -> String {
            return self.daySymbol[dayPerIndex]
        }
        
        func numberOfDays(in elliotable: Elliotable) -> Int {
            return self.daySymbol.count
        }
        
        
        func courseItems(in elliotable: Elliotable) -> [ElliottEvent] {
            return mainTabBarController.courseList ?? []
            
        }
    }
    
    
    extension ScheduleViewController:scheduleCourseDetailDelegate{
        func outsideTouchTapped() {
            self.dismiss(animated: true)
            self.tabBarController!.navigationController?.navigationBar.isUserInteractionEnabled = true
        }
        
        func removeButtonTapped() {
            Firestore.firestore().collection("schedule").document(uid!).collection("scheduleList").document(MainTabBarController.currentSchedule!.scheduleID).collection("schCourse").document((selectschCourse?.schCourseId)!).delete(){
                err in
                if let err = err{
                    print("Error removing document: \(err)")
                } else{
                    print("Document successfully removed!")
                    self.reload()
                    
                }
            }
            self.dismiss(animated: true)
            self.tabBarController!.navigationController?.navigationBar.isUserInteractionEnabled = true
        }
        
    }

    
   

