//
//  gradeListTableViewCell.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 6/27/23.
//

import UIKit

class gradeListTableViewCell: UITableViewCell {

    @IBOutlet weak var courseInstr: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellWithValuesOf(_ grade: Grade){
        courseTitle.text = grade.courTitle
        courseInstr.text = grade.instructor
        courseInstr.adjustsFontSizeToFitWidth=true
        courseTitle.adjustsFontSizeToFitWidth=true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
