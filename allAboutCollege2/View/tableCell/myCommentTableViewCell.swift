//
//  myCommentTableViewCell.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 6/7/23.
//

import UIKit


protocol myCommentViewCellDelegate: AnyObject{
    func deleteButtonPressed(with indexPath: IndexPath)
}


class myCommentTableViewCell: UITableViewCell {
    private var indexPath:IndexPath?
    @IBOutlet weak var dotMenu: UIButton!
    @IBOutlet weak var commentContent: UILabel!
    @IBOutlet weak var commentTitle: UILabel!
    weak var delegate: myCommentViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let delete = UIAction(title: "Delete", attributes: .destructive, handler: { _ in
            print("deleteworking")
            self.delegate?.deleteButtonPressed(with: self.indexPath!)
        })
        let buttonMenu = UIMenu(title: "", children: [delete])
        dotMenu.menu = buttonMenu
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(with indexPath: IndexPath){
        self.indexPath = indexPath
    }
    
}
