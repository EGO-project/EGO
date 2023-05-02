//
//  MoreViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/02/19.
//

import UIKit
import Firebase
import FirebaseDatabase

class MoreViewController: UIViewController {
    
    // 상수 ref에 파이어베이스 주소를 넣음
    // reference는 데이터베이스의 특정 위치를 나타내고 읽고 쓰게끔 해준다
    let ref = Database.database().reference()
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileId: UILabel!
    @IBOutlet weak var logOut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 함수 업데이트
        updateLabel()
        updateCode()
    }
    // user Name을 파이어베이스에 받아와서 화면에 출력
    func updateLabel() {
        ref.child("myName").observeSingleEvent(of: .value) { snapshot in
            let labelValue = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.profileName.text = labelValue
            }
        }
    }
    // user ID Code을 파이어베이스에 받아와서 화면에 출력
    func updateCode() {
        ref.child("myCode").observeSingleEvent(of: .value) { snapshot in
            let labelValue = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.profileId.text = labelValue
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController: ProfileViewController = segue.destination as? ProfileViewController else {return}
        nextViewController.pNameLbl = profileName?.text
        nextViewController.pCodeLbl = profileId?.text
    }
}
