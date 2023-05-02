//
//  NoticeTableViewCell.swift
//  EGO
//
//  Created by 박기태 on 2023/03/25.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {

    @IBOutlet weak var noticeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
