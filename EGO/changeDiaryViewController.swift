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
        
        let detail = self.storyboard?.instantiateViewController(withIdentifier: "detail")
            detail?.modalPresentationStyle = .fullScreen
        
        //let changeDiary = diary(description: changeText.text ?? "", category: String)
        
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
                
                self.changeDiary.update(); // 내용 저장
                self.present(detail!, animated: true, completion: nil)
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
