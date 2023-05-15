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
    @IBOutlet weak var profileCode: UILabel!
    @IBOutlet weak var logOut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 함수 업데이트
        myNameFB()
        myCodeFB()
    }
    
    // user Name을 파이어베이스에 받아와서 화면에 출력
    func myNameFB() {
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        self.ref.child("member").child(safeEmail).child("nickname").observeSingleEvent(of: .value) { snapshot  in
            print("\(snapshot)")
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.profileName.text = value
            }
        }
    }
    
    // user Code을 파이어베이스에 받아와서 화면에 출력
    func myCodeFB() {
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        self.ref.child("member").child(safeEmail).child("friendCode").observeSingleEvent(of: .value) { snapshot  in
            print("\(snapshot)")
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.profileCode.text = value
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController: ProfileViewController = segue.destination as? ProfileViewController else {return}
        nextViewController.pNameLbl = profileName?.text
        nextViewController.pCodeLbl = profileCode.text
    }
}
