//
//  ProfileViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/02/19.
//

import UIKit

class ProfileViewController: UIViewController {
    // 이전 MoreViewController에서 text 값을 받아오기 위한 변수
    var pNameLbl: String?
    var pCodeLbl: String?

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    // MoreViewController에서 가져온 값을 각 Label에 적용
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameLbl.text = self.pNameLbl
        codeLbl.text = self.pCodeLbl
    }
}

// 데이터 베이스에서 받아온 프로필을 moreViewController에서 받아오기
// 회원이 가지고 있는 알을 개수 파악해서 데이터 받아오기
// 받아온 알에 공개여부를 결정할 수 있는 기능 구현
// 회원 이름을 수정하고 그 정보를 데이터 베이스에 전송하는 기능
