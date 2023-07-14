//
//  TabManViewController.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/30/23.
//

import UIKit
import Tabman
import Pageboy

class TabManViewController: TabmanViewController {

    @IBOutlet var tabView: UIView!
    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let vc2 = UIStoryboard.init(name: "tabMan", bundle: nil).instantiateViewController(withIdentifier: "firstTabManViewController") as! firstTabManViewController
        let vc3 = UIStoryboard.init(name: "tabMan", bundle: nil).instantiateViewController(withIdentifier: "secondTabManViewController") as! secondTabManViewController
                  
        viewControllers.append(vc2)
        viewControllers.append(vc3)
        
        
        self.dataSource = self
                
        let bar = TMBar.ButtonBar()
                
        //탭바 레이아웃 설정
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .centerDistributed
        bar.layout.contentMode = .intrinsic
        //        .fit : indicator가 버튼크기로 설정됨
        bar.layout.interButtonSpacing = view.bounds.width / 6

                
        //배경색
        bar.backgroundView.style = .clear
        bar.backgroundColor = .white
                
        //간격설정
        bar.layout.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 10)
                
        //버튼 글시 커스텀
        bar.buttons.customize{
            (button)
            in
            button.tintColor = .gray
            button.selectedTintColor = .black
        }
        //indicator
        bar.indicator.weight = .custom(value: 3)
        bar.indicator.overscrollBehavior = .bounce
        bar.indicator.tintColor = .blue

        addBar(bar, dataSource: self, at:.top)
        
    }
    

    

}


extension TabManViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
        case 0:
            return TMBarItem(title: "Post")
        case 1:
            return TMBarItem(title: "Comment")
        default:
            let title = "Page \(index)"
           return TMBarItem(title: title)
        }
    }

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}
