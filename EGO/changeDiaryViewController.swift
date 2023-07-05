//
//  changeDiaryViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/05/26.
//

import UIKit

class changeDiaryViewController: UIViewController {
    
    @IBOutlet weak var changeText: UITextView!
    @IBOutlet weak var cDate: UILabel!
    
    var changeDiary : diary!
    
    
    @IBAction func changeOk(_ sender: Any) {
        
        guard let detail = self.storyboard?.instantiateViewController(identifier: "detail") as? detailViewController else { return }
        
        let changeDiary = diary(description: changeText.text ?? "", category: changeDiary.category)
        
        if changeText.text.count == 0 {
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
                self.changeDiary.description = self.changeText.text // 내용 수정
                self.changeDiary.update() // 내용 저장
                detail.selectDiary = changeDiary // 데이터 전달
                self.navigationController?.popViewController(animated: true) // 이전 화면으로 돌아가기
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
        
        print(changeDiary)
        
        changeText.text = changeDiary.description
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: changeDiary.date)
        cDate.text = dateString
    }
        
}
