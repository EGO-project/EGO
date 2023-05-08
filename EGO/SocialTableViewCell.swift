//
//  SocialTableViewCell.swift
//  EGO
//
//  Created by 황재하 on 2/14/23.
//

import UIKit

class SocialTableViewCell: UITableViewCell, UITableViewDelegate {
    
    @IBOutlet weak var friendsName: UILabel!

    @IBOutlet weak var friendsEgo1: UIImageView!
    @IBOutlet weak var friendsEgo2: UIImageView!
    @IBOutlet weak var friendsEgo3: UIImageView!
    @IBOutlet weak var friendsEgo4: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
            // Cell 간격 조정
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        contentView.layer.cornerRadius = 10
      }      
}
