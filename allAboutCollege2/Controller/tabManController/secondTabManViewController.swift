//
//  secondTabManViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/30/23.
//

import UIKit
import Firebase
class secondTabManViewController: UIViewController {
    @IBOutlet weak var secondTabManTable: UITableView!
    var myCommentArray:[MyComment] = []
    var postArray:[Post] = []
    let group = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        let myCommentTableViewCellNib = UINib(nibName: "myCommentTableViewCell", bundle: nil)
        self.secondTabManTable.delegate = self
        self.secondTabManTable.dataSource = self
        self.secondTabManTable.register(myCommentTableViewCellNib, forCellReuseIdentifier: "myCommentViewCell")
        self.secondTabManTable.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAllPostComment { myComment in
            self.myCommentArray = myComment!
            self.secondTabManTable.reloadData()
        }
    }

    
    func loadAllPostComment(completion:@escaping (Array<MyComment>?)->Void){
        var selectedPost:Post?
        var myComment:MyComment?
        self.postArray = []
        let group = DispatchGroup()
        let boardNames = ["General","Question","Market","Party","Hangout","Event"]
        self.myCommentArray = []
        for boardName in boardNames {
            group.enter()
            Firestore.firestore().collection("post").document(boardName).collection("postData").whereField("comment", isNotEqualTo: 0).getDocuments() { (querySnapshot,error) in
                if let e = error{
                    print("There was an issue retrieving data from Firestore.\(e)")
                }else{
                    print("documentNum\(querySnapshot!.documents.count)")
                    for doc in querySnapshot!.documents{
                        let data = doc.data()
                        if let bodyText = data["content"] as? String, let titleText = data["title"] as? String,
                           let like = data["like"] as? Int,
                           let boardType = data["boardType"] as? String,
                           let postId = data["postId"] as? String,
                           let date = data["date"] as? Timestamp,
                           let uid = data["uid"] as? String,
                           let image = data["image"] as? String{
                            group.enter()
                            self.updateLikeImage (boardType: boardType, postId: postId)
                            {(likeFilled)->Void in
                                selectedPost = Post(bodyText: bodyText, like: like, titleText: titleText,  image: image, boardType: boardType, postId: postId,likePressed:likeFilled!,date:date.dateValue(),uid: uid, diffDate: self.getTimeDiff(date: date))
                                self.postArray.append(selectedPost!)
                                print("postArray2\(self.postArray.count)")
                                group.leave()
                            }
                            
                        }
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main){
            print("postArray3\(self.postArray.count)")
            for i in 0..<self.postArray.count{
                Firestore.firestore().collection("post").document(self.postArray[i].boardType).collection("postData").document(self.postArray[i].postId).collection("comment").getDocuments() { [self]
                    (querySnapshot, error) in
                    if let e = error{
                        print("There was an issue retrieving data from Firestore.\(e)")
                    }
                    else{
                        
                        for doc in querySnapshot!.documents{
                            let data = doc.data()
                            if let content = data["content"] as? String,
                               let commentId = data["commentId"] as? String,
                               let date = data["date"] as? Timestamp,
                               let uid = data["uid"] as? String,
                               let like = data["like"] as? Int
                            {
                                if(uid == Auth.auth().currentUser?.uid){
                                    myComment = MyComment(selectedPost: postArray[i], commmentTextTitle: postArray[i].titleText, commentContent: content,commentId:commentId )
                                    self.myCommentArray.append(myComment!)
                                    
                                }
//                                self.myCommentArray = self.myCommentArray.sorted(by: {$0.date > $1.date})
                                completion(self.myCommentArray)
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    func cellLoad(cell:myCommentTableViewCell, myComment:MyComment, indexpath:IndexPath){
        cell.selectionStyle = .none
        cell.commentTitle.text = myComment.commmentTextTitle
        print("myComment\(myComment.commmentTextTitle)")
        cell.commentContent.text = myComment.commentContent
        cell.delegate = self
        cell.configure(with: indexpath)
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
    

    
}



extension secondTabManViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count\(self.myCommentArray.count)")
        return self.myCommentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > myCommentArray.count-1 {
            return UITableViewCell()
        }
        else{
            let comment = myCommentArray[indexPath.row]
            print("comment\(comment.commmentTextTitle)")
            print("check\(comment.commentContent)")
            let cell = secondTabManTable.dequeueReusableCell(withIdentifier: "myCommentViewCell",for:indexPath ) as! myCommentTableViewCell
            cellLoad(cell: cell, myComment: comment, indexpath: indexPath )
            return cell
        }
    }
    
        
}


extension secondTabManViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("checking4\(indexPath.row)")
            if(indexPath == nil || indexPath.row >= self.myCommentArray.count){
                print("checking45")
               return
            }
            var postSelected = myCommentArray[indexPath.row].selectedPost
            
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vr = mainStoryboard.instantiateViewController(identifier: "DetailViewController") as! DetailViewController
            vr.postSelected = postSelected
            self.navigationController?.pushViewController(vr, animated:true)
    }
    
}


extension secondTabManViewController:myCommentViewCellDelegate{
    func deleteButtonPressed(with indexPath: IndexPath) {
        var myComment = myCommentArray[indexPath.row]
        Firestore.firestore().collection("post").document(myComment.selectedPost.boardType).collection("postData").document(myComment.selectedPost.postId).collection("comment").document(myComment.commentId).delete(){
            err in
            if let err = err{
                print("Error removing document: \(err)")
            } else{
                print("Document successfully removed!")
                self.myCommentArray.remove(at: indexPath.row)
                self.secondTabManTable.deleteRows(at: [indexPath], with: .automatic)
                self.secondTabManTable.reloadData()
            }
        }
    }
}
    

