//
//  HomeViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 3/18/23.
import UIKit
import Foundation
import Firebase
import BTNavigationDropdownMenu
import FirebaseStorage
import Kingfisher
class HomeViewController: UIViewController{
    let mainTabBarController = MainTabBarController()
    var imageView:UIImage?
    let currentUser = Auth.auth().currentUser
    var isloaded: Bool = false
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var myTableView: UITableView!
    var postArray:[Post] = []
    let testLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(selectedmenu), name: NSNotification.Name(rawValue: "change"), object: nil)
        let myTableViewCellNib = UINib(nibName: "tableViewCell", bundle: nil)
        let myImageTableViewCellNib = UINib(nibName: "imageTableViewCell", bundle: nil)
        
        
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(selectedmenu), for: .valueChanged)
        self.myTableView.register(myTableViewCellNib, forCellReuseIdentifier: "mytableViewCell")
        self.myTableView.register(myImageTableViewCellNib, forCellReuseIdentifier: "myImageTableViewCell")
        self.myTableView.rowHeight = UITableView.automaticDimension
        DispatchQueue.main.async {
            if MainTabBarController.menuName == "All" || MainTabBarController.menuName == nil{
                self.loadAllPost()
                print("menu:\(MainTabBarController.menuName)")
            }
            else{
                self.loadPost(boardtype: MainTabBarController.menuName ?? "")
                print("menu:\(MainTabBarController.menuName)")
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(refreshControl.isRefreshing){
            self.refreshControl.endRefreshing()
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {

    }

    
    @objc func selectedmenu(){
        DispatchQueue.main.async {
            if MainTabBarController.menuName == "All"{
                self.loadAllPost()
            }
            else{
                self.loadPost(boardtype: MainTabBarController.menuName ?? "")
            }
        }
    }

    

  

    
    func updateLikeImage(boardType:String, postId:String, completion:@escaping (Bool?)->Void){
        var currentUser = Auth.auth().currentUser?.uid
        var likeFilled:Bool?
        Firestore.firestore().collection("post").document(boardType).collection("postData").document(postId).collection("likedUser").document(String(currentUser!)).getDocument { (document, error) in
            if let document = document, document.exists{
                likeFilled = true
                completion(likeFilled)
            }
            
            else{
                likeFilled = false
                completion(likeFilled)
            }
        }
      
    }
    
    func loadPost(boardtype:String){
        var post:Post?
        print("documentNum2")
        Firestore.firestore().collection("post").document(boardtype).collection("postData").order(by:"date",descending: false).getDocuments() { (querySnapshot, error) in
            self.postArray = []
            if let e = error {
                print("There was an issue retrieving data from Firestore.\(e)")
            }else{
                if querySnapshot!.documents.count == 0{
                    self.myTableView.isHidden = true
                    self.view.addSubview(self.testLabel)
                    print("labelshown")
                    let attributedString = NSMutableAttributedString(string: "")
                    attributedString.append(NSAttributedString(string: "No Posts yet"))
                    self.testLabel.attributedText = attributedString
                    
                    self.testLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.testLabel.sizeToFit()
                    self.testLabel.numberOfLines = 2
                    self.testLabel.font = UIFont.systemFont(ofSize: 25)
                    self.testLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    self.testLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                    print("enable3")
                    self.testLabel.isHidden = false
                    
                }
                else{
                    self.testLabel.isHidden = true
                    self.myTableView.isHidden = false
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
                                self.updateLikeImage (boardType: boardType, postId: postId) {(likeFilled)->Void in
                                    post = Post(bodyText: bodyText, like: like, titleText: titleText,  image: image, boardType: boardType, postId: postId,likePressed:likeFilled!,date:date.dateValue(),uid:uid,diffDate: self.getTimeDiff(date: date))
                                    self.postArray.append(post!)
                                    self.myTableView.reloadData()

                                }
                            }
                        }
                    }
                }
                
                 
               
            }
        }
    }
    
    func loadAllPost(){
        var post:Post?
        let boardNames = ["General","Question","Market","Party","Hangout","Event"]
        self.postArray = []
        for boardName in boardNames {
            Firestore.firestore().collection("post").document(boardName).collection("postData").getDocuments(){ (querySnapshot, error) in
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore.\(e)")
                }
                
                else{
                        self.testLabel.isHidden = true
                        self.myTableView.isHidden = false
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
                                    
                                    self.updateLikeImage (boardType: boardType, postId: postId) {(likeFilled)->Void in
                                        post = Post(bodyText: bodyText, like: like, titleText: titleText,  image: image, boardType: boardType, postId: postId,likePressed:likeFilled!,date:date.dateValue(),uid: uid, diffDate: self.getTimeDiff(date: date))
                                        print("date:\(post?.diffDate)")
                                        self.postArray.append(post!)
                                        self.postArray = self.postArray.sorted(by: {$0.date > $1.date})
                                        print("post:\(post?.titleText)")
                                        self.myTableView.reloadData()
                                        
                                    }
                                    
                                }
                            }
                        }
                }
            }
        }
    }
    
    
    
    func fetchImage(postId:String,userId:String,imageName:String,  completion: @escaping (URL?)->Void){
        var url:URL?
        let ref = Storage.storage().reference().child("images/\(userId)/\(postId)/\(imageName)")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        
        ref.downloadURL { (url, error) in
                completion(url)
        }
        completion(nil)
    }


    func updateLabel(post:Post, completion: @escaping (Int?)->Void) {
        var likeNum:Int?
        print("hello")
        Firestore.firestore().collection("post").document(post.boardType).collection("postData").document(post.postId).getDocument(){
            (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving data from Firestore.\(e)")
            }
            else{
                let data = querySnapshot?.data()
                likeNum = (data!["like"] as? Int)!
                completion(likeNum)
            }
        }
        completion(nil)
    }
    
    
    
   
    func cellLoad(cell:tableViewCell, post:Post, indexpath:IndexPath,imageBool:Bool){
        cell.selectionStyle = .none
        
        
        if imageBool == true {
            self.fetchImage(postId: post.postId,userId: post.uid, imageName: post.image) { (url)->Void in
                if let url = url{
                    cell.postImageView.kf.indicatorType  = .activity
                    cell.postImageView.kf.setImage(with:url)
                }
            }
        }
        
        if !(cell is imageTableViewCell){
            cell.bodyText.text = post.bodyText
            if cell is postViewCell && imageBool == false{
                cell.postImageView.isHidden = true
                cell.postImageHeight.constant = 0
            }
        }
        cell.titleText.text = post.titleText
        print(post.titleText)
        if post.uid != currentUser?.uid {
            cell.dotMenu.isHidden = true
            cell.dotMenu2.isHidden = false
            
        }
        else{
            cell.dotMenu.isHidden = false
            cell.dotMenu2.isHidden = true
        }
        
        cell.boardType.text = post.boardType
        cell.timeDiff.text = " •\(post.diffDate)"
        cell.likeNum.text = String(post.like)
        cell.configure(with: indexpath)
        cell.delegate = self
        if post.likePressed == true {
            cell.isTouched = true
            cell.thumbImage.setNeedsDisplay()
        }
        else{
            cell.isTouched = false
            cell.thumbImage.setNeedsDisplay()
        }
        cell.updateLabel = {
            self.updateLabel(post: post) { (likeNum)->Void in
                if let likeNum = likeNum {
                    cell.likeNum.text = String(likeNum)
                }
            }
            cell.likeNum.setNeedsDisplay()
        }
        print("load")
        cell.layoutIfNeeded()
    }
    
    func getTimeDiff(date:Timestamp) ->String{
        var timeDiff = Date().timeIntervalSince(date.dateValue())
        if timeDiff < 60{
            return "\(Int(timeDiff))s"
        }
        else if timeDiff >= 60 && timeDiff < 3600{
            return "\(Int(timeDiff / 60))m"
        }
        else if timeDiff >= 3600 && timeDiff < 86400{
            return "\(Int(timeDiff / 3600))h"
        }
        else if timeDiff >= 86400 && timeDiff < 31536000{
            return "\(Int(timeDiff/86400))d"
        }
        else if timeDiff >= 31536000{
            return "\(Int(timeDiff/31536000))y"
        }
        
        return ""
    }
    
    
    
    func ImageLikeSave(post:Post){
        let currentUser = (Auth.auth().currentUser?.uid)!
        let data = ["userId":currentUser]
        if post.likePressed == true{
            FirebaseManager.shared.firestore.collection("post").document(post.boardType ).collection("postData").document(post.postId).collection("likedUser").document(currentUser).setData(data){
                error in
                    if let error = error {
                        print(error)
                        return
                    }
                    print("success")
            }
        }
        
        else{
            FirebaseManager.shared.firestore.collection("post").document(post.boardType ).collection("postData").document(post.postId).collection("likedUser").document(currentUser).delete(){
                error in
                    if let error = error {
                        print(error)
                        return
                    }
                    print("success")
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath == nil || indexPath.row >= self.postArray.count){
            print("checking45")
           return
        }

        var postSelected = postArray[indexPath.row]
        let vr = storyboard?.instantiateViewController(identifier: "DetailViewController") as! DetailViewController
        vr.postSelected = postSelected
        self.navigationController?.pushViewController(vr, animated:true)
    }
    
    

    
    
}

extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.row > postArray.count-1 {
            return UITableViewCell()
        }
        else{
            let post = postArray[indexPath.row]
            if postArray[indexPath.row].image != ""{
                let cell:imageTableViewCell = self.myTableView.dequeueReusableCell(withIdentifier: "myImageTableViewCell",for:indexPath ) as! imageTableViewCell
                cellLoad(cell: cell, post: post, indexpath: indexPath, imageBool: true)
                return cell
            }
            let cell = myTableView.dequeueReusableCell(withIdentifier: "mytableViewCell",for:indexPath ) as! tableViewCell
            cellLoad(cell: cell, post: post, indexpath: indexPath, imageBool: false)
            return cell
        }
    }
}

extension HomeViewController: tableViewCellDelegate{
    func reportButtonPressed(with indexPath: IndexPath) {
        
        let reportAlert = UIStoryboard.init(name: "reportAlert", bundle: nil)
        let reportAlertViewController = reportAlert.instantiateViewController(withIdentifier:"reportAlertViewController" ) as! reportAlertViewController
        reportAlertViewController.modalPresentationStyle = .overCurrentContext
        reportAlertViewController.providesPresentationContextTransitionStyle = true
        reportAlertViewController.definesPresentationContext = true
        reportAlertViewController.reportDelegate = self
        reportAlertViewController.reportPost = postArray[indexPath.row]
        reportAlertViewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.present(reportAlertViewController,animated:true, completion: nil)
    }
    
    func likeButtonPressed(with indexPath: IndexPath, likeFilled:Bool) {
        var post = postArray[indexPath.row]
        if likeFilled {
            Firestore.firestore().collection("post").document(post.boardType).collection("postData").document(post.postId).updateData(["like":FieldValue.increment(1.0)])
            post.likePressed = true
            post.like += 1
            ImageLikeSave(post: post)
        }
        else{
            Firestore.firestore().collection("post").document(post.boardType).collection("postData").document(post.postId).updateData(["like":FieldValue.increment(-1.0)])
            post.likePressed = false
            post.like -= 1
            ImageLikeSave(post: post)
        }
        
    }
    
    func deleteButtonPressed(with indexPath: IndexPath) {
        print("post111:\(indexPath.row)")
        var post = postArray[indexPath.row]
        if post.image != ""{
            Storage.storage().reference().child("images/\(post.uid)/\(post.postId)/\(post.image)").delete() { error in
                if let error = error {
                    print("error made where deleting")
                }
                else{
                    print("successfully removed")
                }
            }
        }
        Firestore.firestore().collection("post").document(post.boardType).collection("postData").document(post.postId).delete(){
            err in
            if let err = err{
                print("Error removing document: \(err)")
            } else{
                print("Document successfully removed!")
                self.postArray.remove(at: indexPath.row)
                self.myTableView.deleteRows(at: [indexPath], with: .fade)
                self.myTableView.reloadData()
            }
        }
    }
    
}

extension HomeViewController:reportAlertViewControllerDelegate{
    func cancelAlertButtonTapped() {
        self.dismiss(animated: true)
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    
    func reportAlertButtonTapped(post:Post,reportText:String) {
        let reportId = UUID().uuidString
        let reportData = ["reportContent":reportText
                          ,"date":Date(),"reportID":reportId] as [String : Any]
        FirebaseManager.shared.firestore.collection("report").document(post.postId).collection("reportDocuments").document(reportId).setData(reportData){
            error in
            if let error = error {
                print(error)
                return
            }
            print("success")
        }
    }
    
   
}

