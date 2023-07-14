//
//  SettingViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 6/17/23.
//

import UIKit
import FirebaseAuth
import Firebase
import Toast_Swift

class SettingViewController: UIViewController{
    
    @IBOutlet weak var settingTableView: UITableView!
    let tableArray = ["Log out","Delete Account","Feedback and report bugs","About developer"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.delegate = self
        settingTableView.dataSource = self
        self.settingTableView.rowHeight = 70
    }
    func deleteAccount(){
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print("error")
            } else {
                print("success")
            }
        }
        do {
            try Auth.auth().signOut()
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "SignViewController")
            UIApplication.shared.windows.first?.rootViewController? = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
        } catch let signOutError as NSError{
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    
    
    func deleteUserPostCommentStorage(){
        print("deleteUserPost")
        let boardNames = ["General","Question","Market","Hangout","Event"]
        let group = DispatchGroup()
        for boardName in boardNames {
            group.enter()
            Firestore.firestore().collection("post").document(boardName).collection("postData").getDocuments(){ (querySnapshot, error) in
                if let e = error {
                    print("There was an issue retrieving data from Firestore.\(e)")
                }
                else{
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            if let bodyText = data["content"] as? String, let titleText = data["title"] as? String,
                               let like = data["like"] as? Int,
                               let boardType = data["boardType"] as? String,
                               let postId = data["postId"] as? String,
                               let date = data["date"] as? Timestamp,
                               let uid = data["uid"] as? String,
                               let image = data["image"] as? String {
                                if(uid == Auth.auth().currentUser?.uid){
                                    print("image\(image)")
                                    group.enter()
                                    Storage.storage().reference().child("images/\(postId)/\(image)").delete() { error in
                                        if let error = error {
                                            print("error made where deleting")
                                        }
                                        else{
                                            print("successfully removed")
                                        }
                                        group.leave()
                                    }
                                    group.enter()
                                    Firestore.firestore().collection("post").document(boardType).collection("postData").document(postId).delete(){
                                        err in
                                        print("deletepost1")
                                        if let err = err {
                                            print("Error removing document: \(err)")
                                        } else {
                                            print("Document successfully removed!")
                                        }
                                        group.leave()
                                    }
                                }
                                group.enter()
                                Firestore.firestore().collection("post").document(boardType).collection("postData").document(postId).collection("comment").getDocuments { (querySnapshot, error) in
                                    if let e = error {
                                        print("There was an issue retrieving data from Firestore.\(e)")
                                    }
                                    else{
                                        if let snapshotDocuments = querySnapshot?.documents {
                                            for doc in snapshotDocuments{
                                                let data = doc.data()
                                                if let content = data["content"] as? String,
                                                   let commentId = data["commentId"] as? String,
                                                   let date = data["date"] as? Timestamp,
                                                   let uid = data["uid"] as? String,
                                                   let like = data["like"] as? Int{
                                                    if (uid == Auth.auth().currentUser?.uid){
                                                        group.enter()
                                                        Firestore.firestore().collection("post").document(boardType).collection("postData").document(postId).collection("comment").document(commentId).delete(){
                                                            err in
                                                            if let err = err {
                                                                print("Error removing document: \(err)")
                                                            } else {
                                                                print("Comment successfully removed!")
                                                            }
                                                            group.leave()
                                                        }
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    group.leave()
                                }
                            }
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main){
                    self.deleteAccount()
                }
            }
        }
        
    }
    
}


extension SettingViewController:UITableViewDelegate{
    
}



extension SettingViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = settingTableView.dequeueReusableCell(withIdentifier: "tableview_cell")
        cell?.textLabel!.text = self.tableArray[indexPath.row]
        cell!.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = DispatchGroup()
        if indexPath.row == 0 {
            
            let alert = UIAlertController(title: "Do you want to log out?", message: "", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "confirm", style: .default){ action in
                do {
                    try Auth.auth().signOut()
                    let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = mainStoryboard.instantiateViewController(withIdentifier: "SignViewController")
                    UIApplication.shared.windows.first?.rootViewController? = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                    
                } catch let signOutError as NSError{
                    print("Error signing out: %@", signOutError)
                }
                
            }
            let cancel = UIAlertAction(title: "cancel", style:.destructive, handler: nil)
            alert.addAction(confirm)
            alert.addAction(cancel)
            present(alert, animated: true,completion: nil)
        }
        else if indexPath.row == 1 {
            let alert = UIAlertController(title: "Do you want to delete account?", message: "", preferredStyle: .alert)
            
            let confirm = UIAlertAction(title: "confirm", style: .default){ action in
                self.deleteUserPostCommentStorage()
                
            }
            
            let cancel = UIAlertAction(title: "cancel", style:.destructive, handler: nil)
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            
            present(alert, animated: true,completion: nil)
            
            
        }
        
        else if indexPath.row == 2 {
            let feedbackAlert = UIStoryboard.init(name: "feedbackAlert", bundle: nil)
            let feedbackAlertViewController = feedbackAlert.instantiateViewController(withIdentifier:"feedbackAlertViewController" ) as! feedbackAlertViewController
            feedbackAlertViewController.modalPresentationStyle = .overCurrentContext
            feedbackAlertViewController.providesPresentationContextTransitionStyle = true
            feedbackAlertViewController.definesPresentationContext = true
            feedbackAlertViewController.feedbackDelegate = self
            feedbackAlertViewController.modalTransitionStyle = .crossDissolve
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            self.present( feedbackAlertViewController,animated:true, completion: nil)
            
        }
        
        else if indexPath.row == 3{
            let aboutDeveloperAlert = UIStoryboard.init(name: "aboutDeveloperAlert", bundle: nil)
            let aboutDeveloperAlertViewController = aboutDeveloperAlert.instantiateViewController(withIdentifier:"aboutDeveloperAlertViewController" ) as! aboutDeveloperAlertViewController
            aboutDeveloperAlertViewController.modalPresentationStyle = .overCurrentContext
            aboutDeveloperAlertViewController.providesPresentationContextTransitionStyle = true
            aboutDeveloperAlertViewController.definesPresentationContext = true
            aboutDeveloperAlertViewController.aboutDeveloperDelegate = self
            aboutDeveloperAlertViewController.modalTransitionStyle = .crossDissolve
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            self.present( aboutDeveloperAlertViewController,animated:true, completion: nil)
            
        }
    }
}


extension SettingViewController:feedbackAlertViewControllerDelegate{
    func cancelAlertButtonTapped() {
        self.dismiss(animated: true)
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    func submitAlertButtonTapped(feedbackText: String) {
        let userId = (Auth.auth().currentUser?.uid)!
        let feedbackId = UUID().uuidString
        let feedbackData = ["feedbackContent":feedbackText
                          ,"date":Date(),"feedbackID":feedbackId] as [String : Any]
        FirebaseManager.shared.firestore.collection("feedback").document(userId).collection("feedbackDocuments").document(feedbackId).setData(feedbackData){
            error in
            if let error = error {
                print(error)
                return
            }
            print("success")
        }
    }
    
    
}


extension SettingViewController: aboutDeveloperAlertViewControllerDelegate{
    func cancelButtonTapped() {
        self.dismiss(animated: true)
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
}
