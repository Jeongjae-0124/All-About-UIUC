//
//  reportAlertViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 6/19/23.
//

import UIKit

protocol reportAlertViewControllerDelegate {
    func cancelAlertButtonTapped()
    func reportAlertButtonTapped(post:Post,reportText:String)
}

class reportAlertViewController: UIViewController {
    var reportDelegate : reportAlertViewControllerDelegate?
    var reportPost:Post?
    @IBOutlet weak var reportTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        reportTextView.delegate = self
        reportTextView.text = "Report reason"
        reportTextView.textColor = .lightGray
        reportTextView.layer.borderWidth = 1.0
        reportTextView.layer.borderColor = UIColor.black.cgColor
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
    }
    
    

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.reportDelegate?.cancelAlertButtonTapped()
    }
    
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        self.reportDelegate?.reportAlertButtonTapped(post:reportPost!, reportText: reportTextView.text)
        self.reportTextView.text = "Report reason"
        self.reportTextView.textColor = .lightGray
        reportTextView.resignFirstResponder()
        self.view.makeToast("Report is successfully uploaded. Thanks for your report")
    }
    
   
}

extension reportAlertViewController: UITextViewDelegate{

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == reportTextView{
            if reportTextView.textColor == .lightGray{
                reportTextView.text = ""
                reportTextView.textColor = .black
            }
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == reportTextView{
            if reportTextView.text == ""{
                reportTextView.text = "Report reason"
                reportTextView.textColor = .lightGray
            }
        }

    }
    
}
