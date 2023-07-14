//
//  MainTabBarController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 3/23/23.
//

import UIKit
import BTNavigationDropdownMenu
import Firebase
import Elliotable
import Toast_Swift



class MainTabBarController: UITabBarController{

    static var userName:String?
    static var menuName: String = "All"
    static var currentSchedule: Schedule?
    var itemList = ["All","General","Question","Market","Hangout","Event"]
    var scheduleArray:[Schedule] = []
    var addedCourse:[SchCourse] = []
    var courseList:[ElliottEvent]?
    
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Rename Schedule", handler: { (_) in
                self.renameSchedule()
            }),
            UIAction(title: "Delete Schedule", attributes: .destructive, handler: { (_) in
                self.deleteSchedule()

            }),

        ]
    }

    var demoMenu: UIMenu {
        return UIMenu(image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    let uid = Auth.auth().currentUser?.uid
    lazy var menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title(MainTabBarController.menuName), items: itemList)

    override func viewDidLoad() {
        print("working")
        var signViewController = SignViewController()
        super.viewDidLoad()
        self.delegate = self
        loadSchedule(){ (ScheduleArray)->Void in
            if ScheduleArray!.count != 0 {
                    for i in 0..<ScheduleArray!.count {
                        self.scheduleArray.append(ScheduleArray![i])

                    }
            }
        }
        signViewController.loadUserName { username in
            MainTabBarController.userName = username
        }
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationItem(vc: self.selectedViewController!)
        
        
    }

    private func updateNavigationItem(vc:UIViewController){
        switch vc {
        
        case is gradeSearchViewController:
            navigationController?.setNavigationBarHidden(true, animated: false)
        case is profileViewController:
            navigationController?.setNavigationBarHidden(true, animated: false)
        case is CreateViewController:
            navigationController?.setNavigationBarHidden(false, animated: false)
            
        case is HomeViewController:
            setPostDropDown()
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItems = nil
            
        case is ScheduleViewController:
            setScheduleDropDown()
            navigationController?.setNavigationBarHidden(false, animated: false)
            let editClass = UIBarButtonItem(title: nil, image:UIImage(systemName: "square.and.arrow.up"), primaryAction: nil, menu: demoMenu)
            let createSchedulerImg = UIImage(systemName: "calendar.badge.plus")
            let createScheduler = UIBarButtonItem(image:createSchedulerImg, style: .plain, target: self, action:#selector(createButtonTapped) )
            navigationItem.leftBarButtonItems = [createScheduler,editClass]
            
            
//        case is profileViewController:

        default: break
        }
    }
    
    func renameSchedule(){
        let renameAlert = UIStoryboard.init(name: "renameAlert", bundle: nil)
        let renameViewController = renameAlert.instantiateViewController(withIdentifier:"renameAlertViewController" ) as! renameAlertViewController
        renameViewController.modalPresentationStyle = .overCurrentContext
        renameViewController.providesPresentationContextTransitionStyle = true
        renameViewController.definesPresentationContext = true
        renameViewController.renameDelegate = self
        renameViewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.present(renameViewController,animated:true, completion: nil)
    }
    
    
    
    func deleteSchedule(){
        Firestore.firestore().collection("schedule").document(uid!).collection("scheduleList").document(MainTabBarController.currentSchedule!.scheduleID).delete(){
            err in
            if let err = err{
                print("Error removing document: \(err)")
            } else{
                print("Document successfully removed!")
                self.loadSchedule(){
                     (ScheduleArray)->Void in
                        self.scheduleArray = []
                             for i in 0..<ScheduleArray!.count {
                                 self.scheduleArray.append(ScheduleArray![i])

                             }
                    if(self.scheduleArray.count != 0){
                        MainTabBarController.currentSchedule = self.scheduleArray.last
                    }
                    self.setScheduleDropDown()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "labelShow"), object: nil)
                }
            }
        }

    }



    func setScheduleDropDown(){
        var scheduleitemList:[String] = []
        for i in 0..<scheduleArray.count{
            scheduleitemList.append(scheduleArray[i].name)
            print("check4\(scheduleArray[i].name)")
        }
        if scheduleArray.isEmpty{
            menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title("Create Schedule"), items: scheduleitemList)
        }
        else if MainTabBarController.currentSchedule == nil {
            MainTabBarController.currentSchedule = scheduleArray[0]
            menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title(scheduleitemList[0]), items: scheduleitemList)
        }
        else{
            menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title(MainTabBarController.currentSchedule!.name), items: scheduleitemList)
        }
        self.navigationItem.titleView = menuView
        menuView.arrowPadding = 15
        menuView.navigationBarTitleFont = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        menuView.cellSelectionColor = .systemGray4
        menuView.cellBackgroundColor = .white
        menuView.cellSeparatorColor = menuView.cellBackgroundColor
        menuView.shouldKeepSelectedCellColor = true
        menuView.arrowTintColor = UIColor.black
        menuView.cellTextLabelFont = UIFont.systemFont(ofSize: 16)
        menuView.checkMarkImage = nil
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            MainTabBarController.currentSchedule = self?.scheduleArray[indexPath]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scheduleChange"), object: self?.menuView)
        }
    }
    
    func setPostDropDown(){
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title(MainTabBarController.menuName), items: itemList)
        self.navigationItem.titleView = menuView
        menuView.arrowPadding = 15
        menuView.navigationBarTitleFont = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        menuView.cellSelectionColor = .systemGray4
        menuView.cellBackgroundColor = .white
        menuView.cellSeparatorColor = menuView.cellBackgroundColor
        menuView.shouldKeepSelectedCellColor = true
        menuView.arrowTintColor = UIColor.black
        menuView.cellTextLabelFont = UIFont.systemFont(ofSize: 16)
        menuView.checkMarkImage = nil
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            MainTabBarController.menuName = (self?.itemList[indexPath])!
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "change"), object: self?.menuView)
        }
    }

    func loadSchedule(completion:@escaping (Array<Schedule>?)->Void){
        var ScheduleArray:[Schedule] = []
        var schedule:Schedule?
        Firestore.firestore().collection("schedule").document(uid!).collection("scheduleList").order(by:"date",descending: false).getDocuments(){ (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving data from Firestore.\(e)")
                completion(nil)
            }
            else{
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let name = data["name"] as? String, let term = data["term"]as? String, let scheduleID = data["scheduleID"] as? String, let date = data["date"] as? Timestamp
                            {
                            schedule = Schedule(name: name, term: term, scheduleID: scheduleID, date:date.dateValue())
                            ScheduleArray.append(schedule!)
                            
                            
                        }
                    }
                }
                completion(ScheduleArray)
            }
            
        }
        
    }
    
    func loadScheduleCourse (schedule:Schedule, completion:@escaping ([ElliottEvent]?)->Void){
        var result : [ElliottEvent] = []
        Firestore.firestore().collection("schedule").document(uid!).collection("scheduleList").document(schedule.scheduleID).collection("schCourse").getDocuments(){ (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving data from Firestore.\(e)")
            }else{
                
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        
                        if let courseDay = data["courseDay"] as? String,
                           let courseId = data["courseId"] as? String,
                           let courseName = data["courseName"] as? String,
                           let endTime = data["endTime"] as? String,
                           let professor = data["professor"]as? String,
                           let roomName = data["roomName"]as? String,
                           let startTime = data["startTime"]as? String
                        {
                            let randomRed:CGFloat = CGFloat(drand48())
                            let randomGreen:CGFloat = CGFloat(drand48())
                            let randomBlue:CGFloat = CGFloat(drand48())
                            let randomColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
                            for i in 0..<courseDay.count{
                                var singleLetterDay = courseDay[courseDay.index(courseDay.startIndex, offsetBy: i)]
                                var elliotDay:ElliotDay?
                                if singleLetterDay == "M"{
                                    elliotDay = .monday
                                }
                                else if singleLetterDay == "T"{
                                    elliotDay = .tuesday
                                }
                                else if singleLetterDay == "W"{
                                    elliotDay = .wednesday
                                }
                                else if singleLetterDay == "R"{
                                    elliotDay = .thursday
                                }
                                else if singleLetterDay == "F"{
                                    elliotDay = .friday
                                }
                                result.append(ElliottEvent(courseId: courseName, courseName: courseId, roomName: roomName, professor: professor, courseDay: elliotDay!, startTime: startTime, endTime: endTime, backgroundColor: randomColor))
                            }
                        }
                    }
                }
            }
            completion(result)
        }
    }
    
    
    
    func loadAddedCourse (schedule:Schedule, completion:@escaping ([SchCourse]?)->Void){
        var result : [SchCourse] = []
        Firestore.firestore().collection("schedule").document(uid!).collection("scheduleList").document(schedule.scheduleID).collection("schCourse").getDocuments(){ (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving data from Firestore.\(e)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        
                        if let courseDay = data["courseDay"] as? String,
                           let courseId = data["courseId"] as? String,
                           let courseName = data["courseName"] as? String,
                           let endTime = data["endTime"] as? String,
                           let professor = data["professor"]as? String,
                           let roomName = data["roomName"]as? String,
                           let schCourseId = data["schCourseId"]as? String,
                           let section = data["section"]as? String,
                           let type = data["type"]as? String,
                           let crn = data["crn"]as? Int,
                           let time = data["time"]as? String,
                           let startTime = data["startTime"]as? String{
                            result.append(SchCourse(courseId: courseName, courseName: courseId, roomName: roomName, professor: professor, courseDay: courseDay, startTime: startTime, endTime: endTime,section: section, schCourseId: schCourseId, time: time, crn:crn, type:type))
                        }
                    }
                }
            }
            completion(result)
        }
    }
    
    
    @objc func createButtonTapped(){
        let customAlert = UIStoryboard.init(name: "CustomAlert", bundle: nil)
        let alertviewController = customAlert.instantiateViewController(withIdentifier:"CustomAlertViewController" ) as! CustomAlertViewController
        alertviewController.scheduleArray = scheduleArray
        alertviewController.delegate = self
        alertviewController.modalPresentationStyle = .overCurrentContext
        alertviewController.providesPresentationContextTransitionStyle = true
        alertviewController.definesPresentationContext = true
        alertviewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.present(alertviewController,animated:true, completion: nil)
    }
    
}


extension MainTabBarController: UITabBarControllerDelegate {


    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            // Check if bar item selected is center
        if let getSelectedIndex =  tabBarController.viewControllers?.firstIndex(of: viewController), getSelectedIndex == 2 {
            guard let viewController = self.storyboard?.instantiateViewController (withIdentifier: "CreateViewController")  else { return false }
            self.navigationController?.pushViewController(viewController, animated: true)
            return false
         }

         return true
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateNavigationItem(vc: viewController)
    }
    
}

extension MainTabBarController: CustomAlertDelegate{
    
    func cancelAlertButtonTapped() {
        self.dismiss(animated: true)
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    func createAlertButtonTapped(){
       self.navigationController?.navigationBar.isUserInteractionEnabled = true
       loadSchedule(){
            (ScheduleArray)->Void in
                if ScheduleArray!.count != 0 {
                    self.scheduleArray = []
                    for i in 0..<ScheduleArray!.count {
                        self.scheduleArray.append(ScheduleArray![i])
                    
                    }
                }
           MainTabBarController.currentSchedule = self.scheduleArray.last
           self.setScheduleDropDown()
           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
           if(ScheduleArray!.count == 1){
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "labelShow"), object: nil)
           }
        }
    }
}


extension MainTabBarController: renameAlertViewControllerDelegate{
    func cancelButtonTapped() {
        self.dismiss(animated: true)
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    func renameButtonTapped() {
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        loadSchedule(){
             (ScheduleArray)->Void in
                 if ScheduleArray!.count != 0 {
                     self.scheduleArray = []
                     for i in 0..<ScheduleArray!.count {
                         self.scheduleArray.append(ScheduleArray![i])
                         print("done")
                     }
                 }
            self.setScheduleDropDown()
         }
    }
    
}


