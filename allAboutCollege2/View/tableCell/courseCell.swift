//
//  courseCell.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 5/9/23.
//

import UIKit

class courseCell: UITableViewCell {

    @IBOutlet weak var courseCode: UILabel!
    @IBOutlet weak var courseSection: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseDay: UILabel!
    @IBOutlet weak var courseTime: UILabel!
    @IBOutlet weak var courseInstr: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
