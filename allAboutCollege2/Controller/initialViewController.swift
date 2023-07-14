//
//  initialViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/28/23.
//

import UIKit
import Firebase
class initialViewController: UIViewController {
    var window: UIWindow?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("first4")
        var signViewController = SignViewController()
        signViewController.loadUserName(completion: { username in
            if username != nil{
                print("first4")
                print("This is user1: \(username)")
                let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationViewController")
                UIApplication.shared.windows.first?.rootViewController? = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
            else{
                let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "SignViewController")
                UIApplication.shared.windows.first?.rootViewController? = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        })

    }
    
    

    

}
