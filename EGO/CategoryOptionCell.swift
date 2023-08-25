//
//  CategoryOptionCell.swift
//  EGO
//
//  Created by bugon cha on 2023/08/17.
//

import UIKit

class CategoryOptionCell: UITableViewCell {

    
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryOption: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
