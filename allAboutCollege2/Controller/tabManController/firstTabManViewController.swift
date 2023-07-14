//
//  firstTabManViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/30/23.
//

import UIKit
import Firebase
class firstTabManViewController: UIViewController {
    
    @IBOutlet weak var firstTabManTable: UITableView!
    var myPostArray:[Post] = []
    var currentUid = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        let myTableViewCellNib = UINib(nibName: "tableViewCell", bundle: nil)
        let myImageTableViewCellNib = UINib(nibName: "imageTableViewCell", bundle: nil)
        self.firstTabManTable.delegate = self
        self.firstTabManTable.dataSource = self
        self.firstTabManTable.register(myTableViewCellNib, forCellReuseIdentifier: "mytableViewCell")
        self.firstTabManTable.register(myImageTableViewCellNib, forCellReuseIdentifier: "myImageTableViewCell")
        self.firstTabManTable.rowHeight = UITableView.automaticDimension
//        loadAllPost { postArray in
//            self.myPostArray = postArray!
//            self.firstTabManTable.reloadData()
//        }
    }
    
    override func  viewWillAppear(_ animated: Bool) {
        loadAllPost { postArray in
            self.myPostArray = postArray!
            self.firstTabManTable.reloadData()
        }
    }
    
    func loadAllPost(completion:@escaping (Array<Post>?)->Void){
        print("postArray44")
        var post:Post?
        let boardNames = ["General","Question","Market","Party","Hangout","Event"]
        self.myPostArray = []
        for boardName in boardNames {
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
                                    print("postArray99")
                                    self.updateLikeImage (boardType: boardType, postId: postId) {(likeFilled)->Void in
                                        if(uid == Auth.auth().currentUser?.uid){
                                            post = Post(bodyText: bodyText, like: like, titleText: titleText,  image: image, boardType: boardType, postId: postId,likePressed:likeFilled!,date:date.dateValue(),uid:uid,diffDate: self.getTimeDiff(date: date))
                                            self.myPostArray.append(post!)
                                        }
                                        self.myPostArray = self.myPostArray.sorted(by: {$0.date > $1.date})
                                        completion(self.myPostArray)
                                    }
                                            
                                }
                            }
                    }
                }
            }
        }
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
    
    
    
    func fetchImage(postId:String,userId:String,imageName:String,  completion: @escaping (URL?)->Void){
        var url:URL?
        let ref = Storage.storage().reference().child("images/\(userId)/\(postId)/\(imageName)")
        print("images/\(userId)/\(postId)/\(imageName)")
        
        ref.downloadURL { (url, error) in
                completion(url)
        }
        completion(nil)
    }
    
    
    func cellLoad(cell:tableViewCell, post:Post, indexpath:IndexPath,imageBool:Bool){
        cell.selectionStyle = .none
        if imageBool == true {
            print("images")
            self.fetchImage(postId: post.postId,userId: post.uid, imageName: post.image) { (url)->Void in
                if let url = url{
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
        cell.boardType.text = post.boardType
        cell.timeDiff.text = " •\(post.diffDate)"
        cell.likeNum.text = String(post.like)
        cell.configure(with: indexpath)
        cell.profileWidth.constant = 0
        cell.userName.font = UIFont.systemFont(ofSize: CGFloat(0))
        cell.userName.isHidden = true
        cell.delegate = self
        if post.uid != Auth.auth().currentUser?.uid {
            cell.dotMenu.isHidden = true
            cell.dotMenu2.isHidden = false
            
        }
        else{
            cell.dotMenu.isHidden = false
            cell.dotMenu2.isHidden = true
        }
        
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
    

extension firstTabManViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > myPostArray.count-1 {
            return UITableViewCell()
        }
        else{
            let post = myPostArray[indexPath.row]
            if myPostArray[indexPath.row].image != ""{
                let cell:imageTableViewCell = self.firstTabManTable.dequeueReusableCell(withIdentifier: "myImageTableViewCell",for:indexPath ) as! imageTableViewCell
                cellLoad(cell: cell, post: post, indexpath: indexPath, imageBool: true)
                return cell
            }
            let cell = firstTabManTable.dequeueReusableCell(withIdentifier: "mytableViewCell",for:indexPath ) as! tableViewCell
            cellLoad(cell: cell, post: post, indexpath: indexPath, imageBool: false)
            return cell
        }
        
        
    }
}
    
    
extension firstTabManViewController: tableViewCellDelegate{
    func reportButtonPressed(with indexPath: IndexPath) {
        
    }
    
    
    func deleteButtonPressed(with indexPath: IndexPath) {
        print("post222:\(indexPath.row)")
        var post = myPostArray[indexPath.row]
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
                self.myPostArray.remove(at: indexPath.row)
                self.firstTabManTable.deleteRows(at: [indexPath], with: .automatic)
                self.firstTabManTable.reloadData()
            }
        }
    }

    
        
    func likeButtonPressed(with indexPath: IndexPath, likeFilled:Bool) {
            var post = myPostArray[indexPath.row]
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
    

}
    

extension firstTabManViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath == nil || indexPath.row >= self.myPostArray.count){
            print("checking45")
           return
        }
        var postSelected = myPostArray[indexPath.row]
        print("index\(indexPath.row)")
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vr = mainStoryboard.instantiateViewController(identifier: "DetailViewController") as! DetailViewController
            vr.postSelected = postSelected
            self.navigationController?.pushViewController(vr, animated:true)
    }
}
    
    
