//
//  SocialTableViewCell.swift
//  EGO
//
//  Created by 황재하 on 2/14/23.
//

import UIKit

class SocialTableViewCell: UITableViewCell, UITableViewDelegate {
    
    @IBOutlet weak var friendsName: UILabel!
    // 친구 삭제 버튼
    @IBOutlet weak var friendsEgo1: UIImageView!
    @IBOutlet weak var friendsEgo2: UIImageView!
    @IBOutlet weak var friendsEgo3: UIImageView!
    @IBOutlet weak var friendsEgo4: UIImageView!
    @IBOutlet weak var friendsEgo5: UIImageView!

    // Assuming the friendsEgo images are named with the friend's name
    var friend: String = "" {
        didSet {
            friendsName.text = friend
            // Assuming the friendsEgo images are named with the friend's name
            friendsEgo1.image = UIImage(named: "\(friend)_1")
            friendsEgo2.image = UIImage(named: "\(friend)_2")
            friendsEgo3.image = UIImage(named: "\(friend)_3")
            friendsEgo4.image = UIImage(named: "\(friend)_4")
            friendsEgo5.image = UIImage(named: "\(friend)_5")
        }
    }
}
