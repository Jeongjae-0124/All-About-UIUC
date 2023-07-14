//
//  DetailViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 4/6/23.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {
    var homeViewController = HomeViewController()
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentView: UIView!
    
    @IBOutlet weak var detailPost: UITableView!
    var postSelected:Post?
    var commentArray:[Comment] = []
    var firstLoad:Bool = true
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myPostTableCell = UINib(nibName: "postViewCell", bundle: nil)
        let myCommentTableCell = UINib(nibName: "commentViewCell", bundle: nil)
        self.detailPost.delegate = self
        self.detailPost.dataSource = self
        self.detailPost.register(myPostTableCell, forCellReuseIdentifier: "myPostTableCell")
        self.detailPost.register(myCommentTableCell, forCellReuseIdentifier: "myCommentViewCell")
        self.detailPost.rowHeight = UITableView.automaticDimension
        self.detailPost.estimatedRowHeight = 100
        commentTextView.isScrollEnabled = false
        commentTextView.delegate = self
        commentTextView.layer.cornerRadius = 10

        
        commentTextView.text = "Add a comment"
        commentTextView.textColor = .lightGray
        
        loadAllComment { commentArray in
            self.commentArray = commentArray!
            self.detailPost.reloadData()
        }
        print("\(commentArray.count)")
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissTap)

        
    }
    
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard(recognizer: UITapGestureRecognizer) {
         view.endEditing(true)
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
                self.commentView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)

            
            }
        
        
    }
    

    

    @objc private func keyboardWillHide(_ notification: Notification) {
        self.commentView.transform = .identity
    }

    
    
    func ImageLikeSave(comment:Comment){
        let post = postSelected
        let currentUser = (Auth.auth().currentUser?.uid)
        let data = ["userId":currentUser]
        if comment.likePressed == true{
            FirebaseManager.shared.firestore.collection("post").document(post!.boardType).collection("postData").document(post!.postId).collection("comment").document(comment.commentId).collection("likedUser").document(currentUser!).setData(data){
                error in
                if let error = error {
                    print(error)
                    return
                }
                print("success")
            }
        }
        
        else{
            FirebaseManager.shared.firestore.collection("post").document(post!.boardType).collection("postData").document(post!.postId).collection("comment").document(comment.commentId).collection("likedUser").document(currentUser!).delete(){
                error in
                    if let error = error {
                        print(error)
                        return
                    }
                    print("success")
            }
        }
    }
    
    
   
    @IBAction func postButtonPressed(_ sender: Any) {
        saveComment()
        loadAllComment { commentArray in
            self.commentArray = commentArray!
            self.detailPost.reloadData()
            let indexPath = IndexPath(row: self.commentArray.count, section: 0)
            print("indexPath\(indexPath.row)")
            self.detailPost.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        
        self.commentTextView.text = ""
        self.commentTextViewHeight.constant = 50
        self.view.endEditing(true)

        
        

    }
    
    
    
    func saveComment(){
        let user = Auth.auth().currentUser
        let boardType = postSelected?.boardType
        let postId = postSelected?.postId
        let commentId = UUID().uuidString
        guard let uid = user?.uid else { return }
        let commentData = ["commentId":commentId, "content": commentTextView.text, "date": Date(), "uid": uid, "like":0 ] as [String : Any]
        FirebaseManager.shared.firestore.collection("post")
            .document(boardType ?? "").collection("postData").document(postId ?? "").collection("comment").document(commentId).setData(commentData) { error in
                if let error = error {
                    print(error)
                    return
                }
                print("success")
        }
        Firestore.firestore().collection("post").document(postSelected!.boardType).collection("postData").document(postSelected!.postId).updateData(["comment":FieldValue.increment(1.0)])
    }
    
    func updateLikeImage(commentId:String, completion:@escaping (Bool?)->Void){
        var post = postSelected
        var currentUser = Auth.auth().currentUser?.uid
        var likeFilled:Bool?
        Firestore.firestore().collection("post").document(post!.boardType).collection("postData").document(post!.postId).collection("comment").document(commentId).collection("likedUser").document(String(currentUser!)).getDocument { (document, error) in
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
    
    func loadAllComment(completion:@escaping (Array<Comment>?)->Void){
        var comment:Comment?
        Firestore.firestore().collection("post").document(postSelected!.boardType).collection("postData").document(postSelected!.postId).collection("comment").order(by:"date",descending: true).getDocuments(){ (querySnapshot, error) in
            self.commentArray = []
            if let e = error {
                print("There was an issue retrieving data from Firestore.\(e)")
            }else{
                print("working1")
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        print("This is data \(data)")
                        print("working 2")
                        if let commentId = data["commentId"] as? String,
                           let content = data["content"] as? String,
                           let like = data["like"] as? Int,
                           let date = data["date"] as? Timestamp,
                           let uid = data["uid"] as? String {
                            self.updateLikeImage( commentId: commentId) { (likeFilled)->Void in
                                comment = Comment(commentId: commentId, content: content, like: like, uid: uid, date:date.dateValue(), likePressed: likeFilled!,diffDate: self.getTimeDiff(date: date))
                                self.commentArray.append(comment!)
                                self.commentArray = self.commentArray.sorted(by: {$0.date < $1.date})
                                completion(self.commentArray)
                            }
        
                        }
                    }
                }
            }
        }
    }
    
    func updateCommentLabel(comment:Comment, completion: @escaping (Int?)->Void){
        var likeNum:Int?
        Firestore.firestore().collection("post").document(postSelected!.boardType).collection("postData").document(postSelected!.postId).collection("comment").document(comment.commentId).getDocument(){
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
    
    
}



extension DetailViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
extension DetailViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if indexPath.row == 0 {
            let cell: postViewCell = self.detailPost.dequeueReusableCell(withIdentifier: "myPostTableCell",for:indexPath) as! postViewCell
            if postSelected?.image == ""{
                homeViewController.cellLoad(cell: cell, post: postSelected!, indexpath: indexPath, imageBool: false)
            }
            else{
                homeViewController.cellLoad(cell: cell, post: postSelected!, indexpath: indexPath, imageBool: true)
            }
            cell.delegate = self
            cell.configure(with: indexPath)
            cell.selectionStyle = .none
            cell.layoutIfNeeded()
            return cell
        }
        
        else{
            let comment = commentArray[indexPath.row-1]
            let cell: commentViewCell = self.detailPost.dequeueReusableCell(withIdentifier: "myCommentViewCell",for:indexPath) as! commentViewCell
            cell.commentContent.text = comment.content
            cell.likeNum.text = String(comment.like)
            cell.selectionStyle = .none
            cell.configure(with: indexPath)
            cell.commentdelegate = self
            cell.timeDiff.text = " •\(comment.diffDate)"
            cell.updateCommentLabel = {
                self.updateCommentLabel(comment:comment){ (likeNum)->Void in
                    if let likeNum = likeNum {
                        cell.likeNum.text = String(likeNum)
                    }
                }
                cell.likeNum.setNeedsDisplay()
            }
            
            if comment.uid != currentUser?.uid {
                cell.dotMenu.isHidden = true
            }
            else{
                cell.dotMenu.isHidden = false
            }
            
            if comment.likePressed == true {
                cell.isTouched = true
                cell.thumbImage.setNeedsDisplay()
            }
            else{
                cell.isTouched = false
                cell.thumbImage.setNeedsDisplay()
            }
            cell.layoutIfNeeded()
            return cell
        }
    }
}


extension DetailViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
                // 어떤 textview를 선택하는지에 따라 다른 코드 실행
        if textView == commentTextView {
                        // textview 사이즈 선언해준다 width는 textview 사이즈 만큼 높이는 무한으로 얼마나 많은 양을 쓸지 모르니
            let commentSize = CGSize(width: textView.contentSize.width, height: .infinity)
                        // textview 사이즈를 위에 설정해준 사이즈로 맞춰준다
            let commentEstimatedSize = textView.sizeThatFits(commentSize)
            //높이가 동적으로 커지게 만드는 코드
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height{
                    constraint.constant = commentEstimatedSize.height
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == commentTextView{
                        // textview 색이 lightgray 즉 처음 설정해놓은 색이면 글색을 black 으로 바꾸고 textview 비운다.
            if commentTextView.textColor == .lightGray{
                commentTextView.text = ""
                commentTextView.textColor = .black
            }
        }
    }
    
   
    
}

extension DetailViewController: tableViewCellDelegate{
    func reportButtonPressed(with indexPath: IndexPath) {
        let reportAlert = UIStoryboard.init(name: "reportAlert", bundle: nil)
        let reportAlertViewController = reportAlert.instantiateViewController(withIdentifier:"reportAlertViewController" ) as! reportAlertViewController
        reportAlertViewController.modalPresentationStyle = .overCurrentContext
        reportAlertViewController.providesPresentationContextTransitionStyle = true
        reportAlertViewController.definesPresentationContext = true
        reportAlertViewController.reportDelegate = self
        reportAlertViewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.present(reportAlertViewController,animated:true, completion: nil)
    }
    
    func deleteButtonPressed(with indexPath: IndexPath) {
        if postSelected!.image != ""{
            Storage.storage().reference().child("images/\(postSelected!.uid)/\(postSelected!.postId)/\(postSelected!.image)").delete() { error in
                if let error = error {
                    print("error made where deleting")
                }
                else{
                    print("successfully removed")
                }
            }
        }
        Firestore.firestore().collection("post").document(postSelected!.boardType).collection("postData").document(postSelected!.postId).delete(){
            err in
            if let err = err{
                print("Error removing document: \(err)")
            } else{
                print("Document successfully removed!")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func likeButtonPressed(with indexpath:IndexPath, likeFilled:Bool) {
        var post = postSelected
        if likeFilled {
            Firestore.firestore().collection("post").document(post!.boardType).collection("postData").document(post!.postId).updateData(["like":FieldValue.increment(1.0)])
            post!.likePressed = true
            post?.like += 1
            homeViewController.ImageLikeSave(post: post!)
            
        }
        else{
            
            Firestore.firestore().collection("post").document(post!.boardType).collection("postData").document(post!.postId).updateData(["like":FieldValue.increment(-1.0)])
            post!.likePressed = false
            post?.like -= 1
            homeViewController.ImageLikeSave(post: post!)
        }
        
    }
}

extension DetailViewController: commentViewCellDelegate{
  
    
    func commentLikeButtonPressed(with indexPath: IndexPath, likeFilled: Bool) {
        let post = postSelected
        var comment = commentArray[indexPath.row-1]
        
        if likeFilled  {
            Firestore.firestore().collection("post").document(post!.boardType).collection("postData").document(post!.postId).collection("comment").document(comment.commentId).updateData(["like":FieldValue.increment(1.0)])
            comment.likePressed = true
            comment.like += 1
            ImageLikeSave(comment: comment)
        }
        else{
            
            Firestore.firestore().collection("post").document(post!.boardType).collection("postData").document(post!.postId).collection("comment").document(comment.commentId).updateData(["like":FieldValue.increment(-1.0)])
            comment.likePressed = false
            comment.like -= 1
            ImageLikeSave(comment: comment)
        }
    }
    
    func commentDeleteButtonPressed(with indexPath: IndexPath) {
        print("deleteworking1")
        let post = postSelected
        print("index\(indexPath.row)")
        var comment = commentArray[indexPath.row-1]
        Firestore.firestore().collection("post").document(post!.boardType).collection("postData").document(post!.postId).collection("comment").document(comment.commentId).delete(){
            err in
            if let err = err{
                print("Error removing document: \(err)")
            } else{
                print("Document successfully removed!")
                self.commentArray.remove(at: indexPath.row-1)
                self.detailPost.deleteRows(at: [indexPath], with: .fade)
                self.detailPost.reloadData()
            }
        }
    }
}


extension DetailViewController:reportAlertViewControllerDelegate{
    func reportAlertButtonTapped(post: Post, reportText: String) {
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
    

    
    func cancelAlertButtonTapped() {
        self.dismiss(animated: true)
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    

    
   
}





