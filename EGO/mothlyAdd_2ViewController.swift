//
//  mothlyAdd_2ViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit

class mothlyAdd_2ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func backBut(_ sender: Any) {
        let backAlert = UIAlertController(title:"알림",message: "작성한 내용이 사라집니다. 뒤로 가시겠습니까?",preferredStyle: UIAlertController.Style.alert)
        let bCancle = UIAlertAction(title: "취소", style: .default, handler: nil)
        
        let bOk = UIAlertAction(title: "확인", style: .default, handler: {
            action in self.dismiss(animated: true); })
        
        backAlert.addAction(bOk)
        backAlert.addAction(bCancle)
        present(backAlert,animated: true,completion: nil)
    }
    
    @IBAction func saveBut(_ sender: Any) {
        
        let mothlyList = self.storyboard?.instantiateViewController(withIdentifier: "diaryList")
            mothlyList?.modalPresentationStyle = .fullScreen
        
        let newDiary = diary(description: textView.text)
        
        if textView.text.count == 0 {
            let alert = UIAlertController(title:"경고",message: "내용을 입력하세요.",preferredStyle: UIAlertController.Style.alert)
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
                newDiary.save(); // 내용 저장
                
                self.present(mothlyList!, animated: true, completion: nil)
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
