//
//  SocialTableViewCell.swift
//  EGO
//
//  Created by 황재하 on 2/14/23.
//

import UIKit

class SocialTableViewCell: UITableViewCell, UITableViewDelegate {

    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendMainEgg: UIImageView!
    @IBOutlet weak var friendSubEgg1: UIImageView!
    @IBOutlet weak var friendSubEgg2: UIImageView!
    @IBOutlet weak var friendSubEgg3: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // 셀 경계값 조정
        contentView.layer.borderWidth = 0
        // 셀 모서리 둥글게
        contentView.layer.cornerRadius = 10
        // 셀 배경색 지정
        contentView.backgroundColor = UIColor(displayP3Red: 255/255, green: 233/255, blue: 176/255, alpha: 1)
    }
    
    // 셀 간격 조정
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    //

}
