//
//  profileViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/29/23.
//

import UIKit
import Firebase
class profileViewController: UIViewController {
    @IBOutlet weak var userName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(true, animated: animated)
        userName.text = MainTabBarController.userName
    }
    
   
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        print("appear")
    }

    @IBAction func settingButtonTapped(_ sender: Any) {
        let vr = storyboard?.instantiateViewController(identifier: "SettingViewController") as! SettingViewController
        self.navigationController?.pushViewController(vr, animated:true)

    }

}



