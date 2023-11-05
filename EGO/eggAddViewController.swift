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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.barStyle()
        
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    func barStyle(){
        if let leftImage = UIImage(named: "back") {
            let buttonImage = leftImage.withRenderingMode(.alwaysOriginal)
            let leftItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(leftButAction))
            navigationItem.leftBarButtonItem = leftItem
        }
        
        if let rightImage = UIImage(named: "ok") {
            let buttonImage = rightImage.withRenderingMode(.alwaysOriginal)
            let rightItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(save))
            navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    @objc private func leftButAction(){
        navigationController?.popViewController(animated: true)
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func but1(_ sender: Any) {
        eggImg.image = UIImage(named:  "squirrel_Level1.png")
        selectName = "squirrel"
    }
    
    @IBAction func but2(_ sender: Any) {
        eggImg.image = UIImage(named:  "lion_Level1.png")
        selectName = "lion"
    }
    
    @IBAction func but3(_ sender: Any) {
        eggImg.image = UIImage(named:  "otter_Level1.png")
        selectName = "otter"
    }
    
    @IBAction func but4(_ sender: Any) {
        eggImg.image = UIImage(named:  "koala_Level1.png")
        selectName = "koala"
    }
    
    @objc func save(_ sender: Any) {
        
        let newEgg = egg(name: eggName.text ?? "", kind: selectName ?? "",  state: "Level1", favoritestate: false, eggState: true, eggnote: 0)
        
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
}
