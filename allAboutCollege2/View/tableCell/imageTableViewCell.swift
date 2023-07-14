//
//  imageTableViewCell.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 4/4/23.
//

import Foundation
import UIKit




class imageTableViewCell:tableViewCell{
//    private var index:Int?
//    var isTouched: Bool? {
//        didSet{
//            if isTouched == true {
//                thumbImage.image = UIImage(systemName: "hand.thumbsup.fill")
//            }
//            else{
//                thumbImage.image = UIImage(systemName: "hand.thumbsup")
//            }
//        }
//    }
//    @IBOutlet weak  var likeNum: UILabel!
//    weak var delegate: tableViewCellDelegate?
//    @IBOutlet weak var titleText: UILabel!
//    @IBOutlet weak var boardType: UILabel!
//    @IBOutlet weak var thumbImage: UIImageView!
//    @IBOutlet weak var postImageView:UIImageView!
//    @IBOutlet weak var timeDiff: UILabel!
//    @IBOutlet weak var profileWidth: NSLayoutConstraint!
//    @IBOutlet weak var profileHeight: NSLayoutConstraint!
//    @IBOutlet weak var profileImage: UIImageView!
//    @IBOutlet weak var userName: UILabel!
//    @IBOutlet weak var dotMenu2: UIButton!
    
//    @IBOutlet weak var dotMenu: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        print("MytableViewCell - awakFromNib() called")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
        postImageView.image = nil
    
        

    }
    @IBAction override func likeButtonPressed(_ sender: Any) {
        super.likeButtonPressed((Any).self)
//        if thumbImage.image == UIImage(systemName: "hand.thumbsup"){
//            thumbImage.image = UIImage(systemName:"hand.thumbsup.fill")
//            delegate?.likeButtonPressed(with: index!,likeFilled: true)
//        }
//        else if thumbImage.image == UIImage(systemName: "hand.thumbsup.fill"){
//            thumbImage.image = UIImage(systemName:"hand.thumbsup")
//            delegate?.likeButtonPressed(with: index!,likeFilled: false)
//        }
    }
//
//    func configure(with index:Int){
//        self.index = index
//    }
//
}
