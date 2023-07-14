//
//  CreateViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 3/26/23.
//

import UIKit
import DropDown
import RxKeyboard
import Firebase
import FirebaseStorage

class CreateViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageDelete: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dropView: UIView!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var btnSelect: UIButton!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var bodyTextView: UITextView!
    var isExpand: Bool = false
    var isImageShowing = false
    let dropdown = DropDown()
    var keyHeight: CGFloat?
    let itemList = ["General","Question","Market","Hangout","Event"]
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
        initDropDown()
        setDropdown()
        bodyTextView.delegate = self
        titleTextView.delegate = self
        titleTextView.isScrollEnabled = false
        bodyTextView.isScrollEnabled = false
        textViewDidChange(titleTextView)
        textViewDidChange(bodyTextView)
        titleTextView.text = "Title"
        titleTextView.textColor = .lightGray
        bodyTextView.text = "Body Text"
        bodyTextView.textColor = .lightGray
        imageView.isHidden = true
        imageDelete.isHidden = true
        imageHeight.constant = 0
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardNotification()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
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
                self.toolBar.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets

            
            }
        
        
    }
    

    

    @objc private func keyboardWillHide(_ notification: Notification) {
        self.toolBar.transform = .identity
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
       
    }

    
    
    private func configureItems(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.postClicked)
        )
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 20)], for: .normal)
    }
            
    @objc func postClicked(){
        if tfInput.text == "Select Catagory"{
            self.view.makeToast("Select the Catagory")
        }
        else{
            savePost()
       
            bodyTextView.text = "Body Text"
            bodyTextView.textColor = .lightGray
            
            titleTextView.text = "Title"
            titleTextView.textColor = .lightGray
            
            bodyTextView.resignFirstResponder()
            titleTextView.resignFirstResponder()
            
            
            imageView.image = .none
            imageView.isHidden = true
            imageDelete.isHidden = true
            imageHeight.constant = 0
            
            self.view.makeToast("Post is successfully uploaded")
        }
    }
    
    func savePost(){
        var imageName = ""
        let user = Auth.auth().currentUser
        let postId = UUID().uuidString
        let boardType = tfInput?.text
        if imageView.image != .none{
            print("should not show")
            imageName = UUID().uuidString
            uploadImage(image: imageView.image!, name:("\(user!.uid)/\(postId)/\(imageName)"))
        }
        guard let uid = user?.uid else { return }
        let postData = ["boardType": boardType,"postId":postId, "title": titleTextView.text, "content": bodyTextView.text, "date": Date(), "uid": uid, "like":0,"image":imageName ,"comment":0] as [String : Any]
        FirebaseManager.shared.firestore.collection("post")
            .document(boardType ?? "").collection("postData").document(postId).setData(postData) { error in
                if let error = error {
                    print(error)
                    return
                }
                print("success")
        }
    }
    
    
    func uploadImage(image: UIImage, name: String) {
        let storageRef = Storage.storage().reference().child("images/\(name)")
        let data = image.jpegData(compressionQuality: 0.1)
        guard data != nil else{return}
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        // uploda data
        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, err) in
                if let err = err {
                    print("err when uploading jpg\n\(err)")
                }
                
                if let metadata = metadata {
                    print("metadata: \(metadata)")
                }
            }
        }
        
    }
    
   
    
    func initDropDown(){
        dropView.layer.cornerRadius = 8
        tfInput.borderStyle = .none
        DropDown.appearance().textColor = UIColor.black // 아이템 텍스트 색상
        DropDown.appearance().selectedTextColor = UIColor.red // 선택된 아이템 텍스트 색상
        DropDown.appearance().backgroundColor = UIColor.white // 아이템 팝업 배경 색상
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
// 선택한 아이템 배경 색상
        DropDown.appearance().setupCornerRadius(8)
        dropdown.dismissMode = .automatic // 팝업을 닫을 모드 설정
        tfInput.text = "Select Catagory" // 힌트 텍스트
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

    @IBAction func dropdownClicked(_ sender: Any) {
        dropdown.show()
    }
    
    
    
    @IBAction func imageDeleteClicked(_ sender: UIButton) {
        imageView.image = .none
        imageView.isHidden = true
        imageDelete.isHidden = true
        imageHeight.constant = 0
        
    }
    
    
}


extension CreateViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView == titleTextView{
            let titleSize = CGSize(width: textView.contentSize.width, height: .infinity)
            let titleEstimatedSize = textView.sizeThatFits(titleSize)
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height{
                    constraint.constant = titleEstimatedSize.height
                }
            }
        }
        
        else if textView == bodyTextView{
            let bodySize = CGSize(width: bodyTextView.contentSize.width, height: .infinity)
            let bodyEstimatedSize = bodyTextView.sizeThatFits(bodySize)
            bodyTextView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height{
                    constraint.constant = bodyEstimatedSize.height
                }
            }
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == titleTextView{
            if titleTextView.textColor == .lightGray{
                titleTextView.text = ""
                titleTextView.textColor = .black
            }
        }
        else if textView == bodyTextView{
            if bodyTextView.textColor == .lightGray{
                bodyTextView.text = ""
                bodyTextView.textColor = .black
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == titleTextView{
            if titleTextView.text == ""{
                titleTextView.text = "Title"
                titleTextView.textColor = .lightGray
            }
        }
        else if textView == bodyTextView{
            if bodyTextView.text == ""{
                bodyTextView.text = "Body Text"
                bodyTextView.textColor = .lightGray
            }
        }
        
    }
}

extension CreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func imageButtonPressed(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated:true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
            imageView.isHidden = false
            imageHeight.constant = 135
            imageDelete.isHidden = false
            self.view.layoutIfNeeded()
        }
        dismiss(animated: true, completion: nil)
    }
}

