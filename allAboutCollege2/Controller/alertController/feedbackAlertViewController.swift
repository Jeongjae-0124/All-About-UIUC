//
//  feedbackAlertViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 6/25/23.
//

import UIKit

protocol feedbackAlertViewControllerDelegate {
    func cancelAlertButtonTapped()
    func submitAlertButtonTapped(feedbackText:String)
}


class feedbackAlertViewController: UIViewController {
    var feedbackDelegate : feedbackAlertViewControllerDelegate?
    @IBOutlet weak var feedbackTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        feedbackTextView.delegate = self
        feedbackTextView.text = "Feedback and report bugs"
        feedbackTextView.textColor = .lightGray
        feedbackTextView.layer.borderWidth = 1.0
        feedbackTextView.layer.borderColor = UIColor.black.cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
    }
    
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        self.feedbackDelegate?.submitAlertButtonTapped(feedbackText: feedbackTextView.text)
        self.feedbackTextView.text = "Feedback and report bugs"
        self.feedbackTextView.textColor = .lightGray
        feedbackTextView.resignFirstResponder()
        self.view.makeToast("Feedback is successfully uploaded. Thanks for your feedback")
    }
    

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.feedbackDelegate?.cancelAlertButtonTapped()
    }
    

}


extension feedbackAlertViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == feedbackTextView{
            if feedbackTextView.textColor == .lightGray{
                feedbackTextView.text = ""
                feedbackTextView.textColor = .black
            }
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == feedbackTextView{
            if feedbackTextView.text == ""{
                feedbackTextView.text = "Feedback and report bugs"
                feedbackTextView.textColor = .lightGray
            }
        }

    }
    
}
