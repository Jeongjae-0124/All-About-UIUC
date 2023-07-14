//
//  CustomAlertViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/11/23.
//

import UIKit
import DropDown
import Firebase
import BTNavigationDropdownMenu
import Toast_Swift

protocol CustomAlertDelegate {
    func cancelAlertButtonTapped()
    func createAlertButtonTapped()
}


class CustomAlertViewController: UIViewController {
    
    
    @IBOutlet weak var scheduleTitle: UITextField!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dropView: UIView!
    @IBOutlet weak var btnSelected: UIButton!
    var schviewController = ScheduleViewController()
    var delegate : CustomAlertDelegate?
    let dropdown = DropDown()
    var duplicateName:Bool?
    let itemList = ["Fall 23"]
    var scheduleArray:[Schedule] = []
    let uid = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        initDropDown()
        setDropdown()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
    }

    @IBAction func createButtonTapped(_ sender: Any) {
        for i in 0..<scheduleArray.count{
            if(scheduleArray[i].name == scheduleTitle.text){
                duplicateName = true
            }
        }
        if duplicateName == true {
            self.view.makeToast("Schedule name is duplicate. Try another name")
            duplicateName = false
        }
        else{
            saveSchedule()
            self.delegate?.createAlertButtonTapped()
            self.dismiss(animated: true)
            
        }
        

    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.delegate?.cancelAlertButtonTapped()

        
    }
    
    
    func initDropDown(){
        dropView.layer.cornerRadius = 8
        tfInput.borderStyle = .none
        DropDown.appearance().textColor = UIColor.black // 아이템 텍스트 색상
        DropDown.appearance().selectedTextColor = UIColor.red // 선택된 아이템 텍스트 색상
        DropDown.appearance().backgroundColor = UIColor.white // 아이템 팝업 배경 색상
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray // 선택한 아이템 배경 색상
        DropDown.appearance().setupCornerRadius(8)
        dropdown.dismissMode = .automatic // 팝업을 닫을 모드 설정
        tfInput.text = "Fall 23" // 힌트 텍스트
    }
    
    func setDropdown(){
        dropdown.dataSource = itemList
        // anchorView를 통해 UI와 연결
        dropdown.anchorView = self.dropView
        // View를 갖리지 않고 View아래에 Item 팝업이 붙도록 설정
        dropdown.bottomOffset = CGPoint(x: 0, y: dropView.bounds.height)
        // Item 선택 시 처리
        dropdown.selectionAction = { [weak self] (index, item) in
            //선택한 Item을 TextField에 넣어준다.
            self!.tfInput.text = item
        }
    }
    
    
    @IBAction func dropDownClicked(_ sender: Any) {
        dropdown.show()
    }
    
    
    func saveSchedule(){
        let scheduleId = UUID().uuidString
        let scheduleData = ["name":scheduleTitle.text, "term":tfInput.text, "scheduleID":scheduleId, "date":Date()] as [String : Any]
        FirebaseManager.shared.firestore.collection("schedule")
            .document(uid!).collection("scheduleList").document(scheduleId).setData(scheduleData) { error in
            if let error = error {
                            print(error)
                            return
            }
            print("success")
        }
        
    }
    
  
    
}
