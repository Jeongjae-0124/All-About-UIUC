//
//  courseViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 4/23/23.
//

import UIKit
import SwiftSoup
import RealmSwift
import SwiftCSV
import Firebase
import Toast_Swift
import Elliotable
class courseViewController: UIViewController {
    var realm = try! Realm()
    var courseList : Results<Course>?
    var filterCourse: List<Course>?
    var selectedCourse: Course?
    var sch = ScheduleViewController()
    var SchcourseList:[ElliottEvent] = []
    @IBOutlet weak var courseTableView: UITableView!
    let uid = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        realmInit()
        configureItems()
        
        let courseTableViewCellNib = UINib(nibName: "courseCell", bundle: nil)
        self.courseTableView.delegate = self
        self.courseTableView.dataSource = self
        self.courseTableView.register(courseTableViewCellNib, forCellReuseIdentifier: "courseCell")
        self.courseTableView.rowHeight = UITableView.automaticDimension
        
        self.filterCourse = courseList?.list
        

    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardNotification()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(keyboardWillShow),
          name: UIResponder.keyboardWillShowNotification,
          object: nil
        )

        NotificationCenter.default.addObserver(
          self,
          selector: #selector(keyboardWillHide),
          name: UIResponder.keyboardWillHideNotification,
          object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                print("keyboardHeightup: \(keyboardHeight)")
              
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
                courseTableView.contentInset = contentInsets
                courseTableView.scrollIndicatorInsets = contentInsets

            
            }
        
        
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        courseTableView.contentInset = .zero
        courseTableView.scrollIndicatorInsets = .zero
       
    }

    
    
    func realmInit(){
        
        let config1 = Realm.Configuration(
            fileURL: Bundle.main.url(forResource: "Course", withExtension: "realm"), readOnly: true, schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
            })
        realm = try! Realm(configuration: config1)
        courseList = realm.objects(Course.self)
        
    }
    
    func courseCellLoad(cell:courseCell, course:Course){
            cell.courseCode.text = course.subjectCode + " " + String(course.courseNum)
            cell.courseSection.text = "- \(course.section)"
            cell.courseTitle.text = course.courseName
            cell.courseDay.text = course.day + ","
            cell.courseTime.text = course.time
            cell.courseInstr.text = course.instructor
    }
    
    
    private func configureItems(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.addClicked)
        )
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 20)], for: .normal)
    }
    
    @objc func addClicked(){
        if selectedCourse == nil {
            print("SelectCourse")
        }
        else if selectedCourse!.day == "n.a." || selectedCourse?.time == "ARRANGED"{
            self.view.makeToast("The course time is not arranged yet")
        }
        else {
            
            var schCourse = parseCourse(course: selectedCourse!)
            var duplicateBool = checkDuplicate(course:schCourse)
            print(duplicateBool)
            if duplicateBool == true{
                self.view.makeToast("This course can not be added due to a time conflict")
            }
            else{
                saveCourse(course: schCourse)
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    func saveCourse(course:SchCourse){
        var mainTabBarController = MainTabBarController()
        let schCourseId = UUID().uuidString
        let schCourseData = ["courseId":course.courseId, "courseName":course.courseName,"roomName":course.roomName,"professor":course.professor,"courseDay":course.courseDay,"startTime":course.startTime,"endTime":course.endTime,"section": course.section, "schCourseId":schCourseId, "time":course.time,"crn":course.crn,"type": course.type]as [String : Any]
        print("menu \(MainTabBarController.menuName)")
        FirebaseManager.shared.firestore.collection("schedule")
            .document(uid!).collection("scheduleList").document(MainTabBarController.currentSchedule!.scheduleID).collection("schCourse").document(schCourseId).setData(schCourseData) { error in
            if let error = error {
                            print(error)
                            return
            }
            print("success")
        }

    }
    func parseCourse(course:Course)->SchCourse{
        var courseTitle = "\(course.subjectCode) \(course.courseNum)"
        var location = course.location
        var courseName = course.courseName
        var instructor = course.instructor
        var courseType = course.type
        var crn = course.crn
        var type = course.type
        var courseDay = course.day
        var time = course.time
        var section = course.section
        var startIndex = course.time.firstIndex(of: " ")
        var startTime = String(course.time [course.time.startIndex...startIndex!])
        var endIndex = course.time.lastIndex(of: " ")
        var endTime = String(course.time[course.time.index(after: endIndex!)..<course.time.endIndex])
        startTime = convert24(time: startTime)
        endTime = convert24(time: endTime)
        return SchCourse(courseId: courseTitle, courseName: courseName, roomName: location, professor: instructor, courseDay: courseDay, startTime: startTime, endTime: endTime, section: section, time:time ,crn:  crn, type: type)
        
    }
    
    func checkDuplicate(course:SchCourse)->Bool{
        print("num:\(SchcourseList.count)")
        for i in 0..<SchcourseList.count{
            var singleDay : String?
            var compareCourse:ElliottEvent = SchcourseList[i]
            if(compareCourse.courseDay == .monday){
                singleDay = "M"
            }
            else if (compareCourse.courseDay == .tuesday){
                singleDay = "T"
            }
            else if (compareCourse.courseDay == .wednesday){
                singleDay = "W"
            }
            else if (compareCourse.courseDay == .thursday){
                singleDay = "R"
            }
            else if (compareCourse.courseDay == .friday){
                singleDay = "F"
            }
            if(course.courseDay!.contains(singleDay!) && ( (course.startTime == compareCourse.startTime) || (course.endTime == compareCourse.endTime) || (course.startTime! > compareCourse.startTime && course.startTime! < compareCourse.endTime) || (course.endTime! > compareCourse.startTime && course.endTime! < compareCourse.endTime))){
                return true
            }
            
            
            
        }
        return false
    }
    
    
    
    
    func convert24(time:String)->String{
        let dateAsString = time
        let df = DateFormatter()
        df.dateFormat = "hh:mma"
        let date = df.date(from: dateAsString)
        df.dateFormat = "HH:mm"
        let time24 = df.string(from: date!)
        return time24
    }
    
    
    func isAlphabet(_ str: String) -> Bool {
      for char in str {
        if !char.isLetter { return false }
      }
      return true
    }
    
}

extension courseViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourse = filterCourse?[indexPath.row]
        self.view.endEditing(true)
    }
}

extension courseViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != ""{
            filterCourse?.removeAll()
            for course in courseList!.list {
                var courseCode = course.subjectCode.lowercased() + String(course.courseNum)
                
                var courseTrim = course.courseName.replacingOccurrences(of: " ", with: "").lowercased()
                var searchTrim = searchText.replacingOccurrences(of: " ", with: "").lowercased()
                if searchTrim.count <= 7 || isAlphabet(searchTrim) == false {
                    if courseCode.contains(searchTrim){
                        filterCourse?.append(course)
                    }
                }
                else{
                    if courseTrim.contains(searchTrim){
                        filterCourse?.append(course)
                    }
                }
                
            }
            print(filterCourse?.count)
            courseTableView.reloadData()
        }
        else{
            self.filterCourse = courseList?.list
            courseTableView.reloadData()
        }
    }
}

extension courseViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCourse!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let course = filterCourse![indexPath.row]
        let cell = courseTableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! courseCell
        courseCellLoad(cell:cell,course:course)
        return cell
        
    }
}

extension Results {
  var list: List<Element> {
    reduce(.init()) { list, element in
      list.append(element)
      return list
    }
  }
}
