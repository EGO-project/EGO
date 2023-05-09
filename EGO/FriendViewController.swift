//
//  FriendViewController.swift
//  EGO
//
//  Created by 황재하 on 5/5/23.
//

import UIKit

class FriendViewController: UIViewController {

    // 전 뷰의 값을 전달받을 프로퍼티 생성
    var name: String?
    var ego: String?
    
    // 프로퍼티의 값이 들어감 오브젝트들
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendEgo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateData()
        // Do any additional setup after loading the view.
    }
    
    // 받아온 값을 오브젝트에 저장하는 함수
    func updateData() {
        if let name = self.name, let ego = self.ego{
                   let ego = UIImage(named: "\(ego).png")
                   friendEgo.image = ego
                   friendName.text = name
               }
    }

}
