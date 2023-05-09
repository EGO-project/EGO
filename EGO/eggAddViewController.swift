//
//  eggAddViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit

class eggAddViewController: UIViewController {
    
    @IBAction func backBut(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    var selectName: String?
    
    @IBOutlet weak var eggName: UITextField!
    
    @IBOutlet weak var eggImg: UIImageView!
    
    @IBAction func but1(_ sender: Any) {
        eggImg.image = UIImage(named:  "egg_다람쥐.png")
        selectName = "다람쥐"
    }
    
    @IBAction func but2(_ sender: Any) {
        eggImg.image = UIImage(named:  "egg_사자.png")
        selectName = "사자"
    }
    
    @IBAction func but3(_ sender: Any) {
        eggImg.image = UIImage(named:  "egg_수달.png")
        selectName = "수달"
    }
    
    @IBAction func but4(_ sender: Any) {
        eggImg.image = UIImage(named:  "egg_코알라.png")
        selectName = "코알라"
    }
    
    @IBAction func save(_ sender: Any) {
        
        let newEgg = egg(name: eggName.text ?? "", kind: selectName ?? "",  state: "1단계", favoritestate: false)
        
        let mainView = self.storyboard?.instantiateViewController(withIdentifier: "MainNC")
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
        
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
