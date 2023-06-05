//
//  mothlyAdd_1ViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit

class mothlyAdd_1ViewController: UIViewController {
    
    
    @IBOutlet weak var todayLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    var diaryCategory: String = ""
    
    
    @IBAction func but1(_ sender: Any) {
        diaryCategory = "일상"
        categoryLabel.text = diaryCategory
    }
    
    @IBAction func but2(_ sender: Any) {
        diaryCategory = "식당"
        categoryLabel.text = diaryCategory
    }
    
    @IBAction func but3(_ sender: Any) {
        diaryCategory = "디저트"
        categoryLabel.text = diaryCategory
    }
    
    @IBAction func but4(_ sender: Any) {
        diaryCategory = "문화생활"
        categoryLabel.text = diaryCategory
    }
    
    @IBAction func but5(_ sender: Any) {
        diaryCategory = "쇼핑"
        categoryLabel.text = diaryCategory
    }
    
    @IBAction func but6(_ sender: Any) {
        diaryCategory = "운동"
        categoryLabel.text = diaryCategory
    }
    
    @IBAction func but7(_ sender: Any) {
        diaryCategory = "여행"
        categoryLabel.text = diaryCategory
    }
    
    @IBAction func but8(_ sender: Any) {
        diaryCategory = "공부"
        categoryLabel.text = diaryCategory
    }
    
    
    @IBAction func backBut(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func next(_ sender: Any) {
        
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "add_2")
        nextView?.modalPresentationStyle = .fullScreen
        
        if diaryCategory == "" {
            let alert = UIAlertController(title:"경고",message: "카테고리를 선택하세요.",preferredStyle: UIAlertController.Style.alert)
            
            let ok = UIAlertAction(title: "확인", style: .destructive, handler: nil)
            
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        } else {
            guard let nextVC = nextView as? mothlyAdd_2ViewController else { return }
            nextVC.selectCategory = diaryCategory
                self.present(nextVC, animated: true, completion: nil)
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        // 현재 날짜 가져오기
        let currentDate = Date()
                        
        // 날짜를 원하는 형식으로 포맷
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = dateFormatter.string(from: currentDate)
                        
        //Label에 날짜 표시
        todayLabel.text = formattedDate
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
