//
//  renameAlertViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/29/23.
//

import UIKit
import Firebase

protocol renameAlertViewControllerDelegate {
    func cancelButtonTapped()
    func renameButtonTapped()
}
class renameAlertViewController: UIViewController {
    @IBOutlet weak var newScheduleName: UITextField!
    var renameDelegate : renameAlertViewControllerDelegate?
    var mainTabBarController = MainTabBarController()
    let uid = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
    }
    
    
    @IBAction func renameButtonTouched(_ sender: Any) {
        MainTabBarController.currentSchedule!.name = self.newScheduleName.text!
        Firestore.firestore().collection("schedule").document(uid!).collection("scheduleList").document(MainTabBarController.currentSchedule!.scheduleID).updateData(["name":newScheduleName.text]){
            err in
            if let err = err{
                print("Error updating document: \(err)")
            }
            
            else{
                print("Document successfully updated")
        
                }
            }
        self.renameDelegate?.renameButtonTapped()
        self.dismiss(animated: true)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.renameDelegate?.cancelButtonTapped()
        
    }
    
}
