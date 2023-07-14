//
//  aboutDeveloperAlertViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 6/28/23.
//

import UIKit

protocol aboutDeveloperAlertViewControllerDelegate {
    func cancelButtonTapped()
    
}


class aboutDeveloperAlertViewController: UIViewController {
    var aboutDeveloperDelegate : aboutDeveloperAlertViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.aboutDeveloperDelegate?.cancelButtonTapped()
    }
    
}
