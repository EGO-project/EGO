//
//  SocialTableViewCell.swift
//  EGO
//
//  Created by 김민석 on 2/14/23.
//

import UIKit
import Firebase
import FirebaseDatabase

class SocialTableViewCell: UITableViewCell, UITableViewDelegate {
    
    @IBOutlet weak var friendsName: UILabel!
    @IBOutlet weak var friendsEgo1: UIImageView!
    @IBOutlet weak var friendsEgo2: UIImageView!
    @IBOutlet weak var friendsEgo3: UIImageView!
    @IBOutlet weak var friendsEgo4: UIImageView!
    @IBOutlet weak var friendsEgo5: UIImageView!
    
    var eggTapHandler: ((egg) -> Void)?

    
    var friendName: String? {
        didSet {
            friendsName.text = friendName
        }
    }
    
    var friendEggs: [egg] = [] {
        didSet {
            // Reset images
            friendsEgo1.image = nil
            friendsEgo2.image = nil
            friendsEgo3.image = nil
            friendsEgo4.image = nil
            friendsEgo5.image = nil

            // 친구의 알들을 이미지 뷰에 설정
            for (index, ego) in friendEggs.prefix(5).enumerated() {
                let imageName = ego.kind + "_" + ego.state
                let imageView: UIImageView
                switch index {
                case 0:
                    imageView = friendsEgo1
                case 1:
                    imageView = friendsEgo2
                case 2:
                    imageView = friendsEgo3
                case 3:
                    imageView = friendsEgo4
                case 4:
                    imageView = friendsEgo5
                default:
                    continue
                }
                
                imageView.image = UIImage(named: imageName)
                imageView.isUserInteractionEnabled = true
                
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(eggTapped(_:)))
                imageView.addGestureRecognizer(tapRecognizer)
                imageView.tag = index
            }
        }
    }

    @objc private func eggTapped(_ recognizer: UITapGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView, imageView.tag < friendEggs.count {
            let selectedEgg = friendEggs[imageView.tag]
            eggTapHandler?(selectedEgg)
        }
    }

    
}

