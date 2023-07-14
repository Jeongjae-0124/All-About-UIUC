//
//  UsernameViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 3/18/23.
//

import UIKit
import Foundation
import Firebase
class UsernameViewController: UIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let authUserModel = AuthUserModel()
        confirmButton.setTitleColor(UIColor.black, for: .normal) 
    }
    

    @IBAction func confirmPressed(_ sender: UIButton) {
        checkDuplicate(username: userName.text!) { duplicate in
            if(duplicate == true){
                self.view.makeToast("A user with that username already exists")
            }
            else{
                self.storeUserInformation(userName: self.userName.text!)
                let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationViewController")
                self.view.window?.rootViewController? = vc
            }
        }
        
        
        
        
        
    }

    
    private func storeUserInformation(userName:String){
        let user = Auth.auth().currentUser
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = userName
        user?.reload()
        guard let uid = user?.uid else { return }
        let userData = ["email":user?.email, "uid": uid, "username":userName]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { error in
                if let error = error {
                    print(error)
                    return
                }
                print("success")
        }
    }
    
    func checkDuplicate(username:String,completion:@escaping (Bool?)->Void){
        Firestore.firestore().collection("users").getDocuments { (querySnapshot, error) in
            if let e = error{
                print("There was an issue retrieving data from Firestore.\(e)")
            }
            else{
                if querySnapshot?.documents.count == 0 {
                    completion(false)
                }
                for doc in querySnapshot!.documents{
                    let data = doc.data()
                    if let userName = data["username"] as? String{
                        if(userName == username){
                            completion(true)
                        }
                        else{
                            completion(false)
                        }
                    }
                }
                    
            }
        }
    }
    
}
