//
//  commentViewCell.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 4/8/23.
//

import UIKit
protocol commentViewCellDelegate:AnyObject{
    func commentLikeButtonPressed(with indexPath:IndexPath, likeFilled:Bool)
    func commentDeleteButtonPressed(with indexPath: IndexPath)
}


class commentViewCell:UITableViewCell{
    private var indexPath:IndexPath?
    var updateCommentLabel: (()->Void)?
    weak var commentdelegate:commentViewCellDelegate?
    @IBOutlet weak var dotMenu: UIButton!
    @IBOutlet weak var likeNum: UILabel!
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var commentContent: UILabel!
    @IBOutlet weak var timeDiff: UILabel!
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
            self.commentdelegate?.commentDeleteButtonPressed(with: self.indexPath!)
        })
        let buttonMenu = UIMenu(title: "", children: [delete])
        dotMenu.menu = buttonMenu
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func likeButtonPressed(_ sender: Any) {
        if thumbImage.image == UIImage(systemName: "hand.thumbsup"){
            print("pressed")
            thumbImage.image = UIImage(systemName:"hand.thumbsup.fill")
            commentdelegate?.commentLikeButtonPressed(with: indexPath!, likeFilled: true)
            updateCommentLabel?()

        }
        else if thumbImage.image == UIImage(systemName: "hand.thumbsup.fill"){
            thumbImage.image = UIImage(systemName:"hand.thumbsup")
            commentdelegate?.commentLikeButtonPressed(with: indexPath!, likeFilled: false)
            updateCommentLabel?()
        }
       
    }
    
    func configure(with indexPath: IndexPath){
        self.indexPath = indexPath
    }

    
}
