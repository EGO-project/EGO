//
//  ProfileCustomCell.swift
//  EGO
//
//  Created by 박기태 on 2023/02/19.
//

import UIKit

class ProfileCustomCell: UITableViewCell {
    @IBOutlet weak var profileImg: UIView!
    @IBOutlet weak var profileName: UIView!
    @IBOutlet weak var profileId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
