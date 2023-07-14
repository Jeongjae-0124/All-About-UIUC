//
//  myTableViewCell.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 4/3/23.
//

import Foundation
import UIKit
import Firebase

protocol tableViewCellDelegate : AnyObject {
    func likeButtonPressed(with indexPath:IndexPath,likeFilled:Bool)
    func deleteButtonPressed(with indexPath: IndexPath)
    func reportButtonPressed(with indexPath: IndexPath)

}


class tableViewCell: UITableViewCell {
    private var indexPath:IndexPath?
    var updateLabel: (()->Void)?
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileWidth: NSLayoutConstraint!
    @IBOutlet weak var profileHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var likeNum: UILabel!
    @IBOutlet weak var timeDiff: UILabel!
    weak var delegate: tableViewCellDelegate?
    @IBOutlet weak var dotMenu: UIButton!
    
    
    @IBOutlet weak var dotMenu2: UIButton!
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var boardType: UILabel!
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var bodyText: UILabel!
    @IBOutlet weak var postImageView:UIImageView!
    @IBOutlet weak var postImageHeight: NSLayoutConstraint!
   
    
    var isTouched: Bool? {
        didSet{
            if isTouched == true {
                thumbImage.image = UIImage(systemName: "hand.thumbsup.fill")
            }
            else{
                thumbImage.image = UIImage(systemName: "hand.thumbsup")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let delete = UIAction(title: "Delete", attributes: .destructive, handler: { _ in
            self.delegate?.deleteButtonPressed(with:self.indexPath!)
        })
        
        let report = UIAction(title: "Report", attributes: .destructive, handler: { _ in
            self.delegate?.reportButtonPressed(with: self.indexPath!)
        })
        let buttonMenu = UIMenu(title: "", children: [delete])
        let buttonMenu2 = UIMenu(title: "", children: [report])
        dotMenu.menu = buttonMenu
        dotMenu2.menu = buttonMenu2
    
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        if thumbImage.image == UIImage(systemName: "hand.thumbsup"){
            thumbImage.image = UIImage(systemName:"hand.thumbsup.fill")
            delegate?.likeButtonPressed(with: indexPath!, likeFilled: true)
            updateLabel?()

        }
        else if thumbImage.image == UIImage(systemName: "hand.thumbsup.fill"){
            thumbImage.image = UIImage(systemName:"hand.thumbsup")
            delegate?.likeButtonPressed(with: indexPath!, likeFilled: false)
            updateLabel?()
        }
       
    }
    
    func configure(with indexPath: IndexPath){
        self.indexPath = indexPath
    }
}
