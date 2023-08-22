//
//  eggAddViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import Foundation
import Firebase
//import FirebaseAuth
//import FirebaseDatabase

//import KakaoSDKAuth
//import KakaoSDKUser
//import KakaoSDKCommon

class eggAddViewController: UIViewController {

    var selectName: String?
    
    @IBOutlet weak var eggName: UITextField!
    
    @IBOutlet weak var eggImg: UIImageView!
    
    @IBAction func but1(_ sender: Any) {
        eggImg.image = UIImage(named:  "다람쥐_1단계.png")
        selectName = "다람쥐"
    }
    
    @IBAction func but2(_ sender: Any) {
        eggImg.image = UIImage(named:  "사자_1단계.png")
        selectName = "사자"
    }
    
    @IBAction func but3(_ sender: Any) {
        eggImg.image = UIImage(named:  "수달_1단계.png")
        selectName = "수달"
    }
    
    @IBAction func but4(_ sender: Any) {
        eggImg.image = UIImage(named:  "코알라_1단계.png")
        selectName = "코알라"
    }
    
    @IBAction func save(_ sender: Any) {
        
        let newEgg = egg(name: eggName.text ?? "", kind: selectName ?? "",  state: "1단계", eggState: false, favoritestate: false)
        
        let mainView = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar")
            mainView?.modalPresentationStyle = .fullScreen
        
        if eggName.text!.count == 0 {
            let alert = UIAlertController(title:"경고",message: "이름을 입력하세요.",preferredStyle: UIAlertController.Style.alert)
            //확인 버튼 만들기
            let ok = UIAlertAction(title: "확인", style: .destructive, handler: nil)
            //확인 버튼 경고창에 추가하기
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        } else if selectName == nil {
            let alert = UIAlertController(title:"경고",message: "알 종류를 선택해주세요.",preferredStyle: UIAlertController.Style.alert)
            //확인 버튼 만들기
            let ok = UIAlertAction(title: "확인", style: .destructive, handler: nil)
            //확인 버튼 경고창에 추가하기
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        } else {
            let alert = UIAlertController(title:"알림",message: "내용을 저장하시겠습니까?",preferredStyle: UIAlertController.Style.alert)
            let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
            //확인 버튼 만들기
            let ok = UIAlertAction(title: "확인", style: .default, handler: {
                action in
                newEgg.save(); // 내용 저장
                self.present(mainView!, animated: true, completion: nil)
            })
            
            alert.addAction(ok)
            alert.addAction(cancle)
            //확인 버튼 경고창에 추가하기
            present(alert,animated: true,completion: nil)
            
        }
        

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
