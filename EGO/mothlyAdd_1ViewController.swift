//
//  mothlyAdd_1ViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit

class mothlyAdd_1ViewController: UIViewController {
    
    
    @IBOutlet weak var todayLabel: UILabel!
    
    var idName : String = ""
    var diaryCategory: String = ""
    
    @IBOutlet weak var but1: UIButton!
    @IBOutlet weak var but2: UIButton!
    @IBOutlet weak var but3: UIButton!
    @IBOutlet weak var but4: UIButton!
    @IBOutlet weak var but5: UIButton!
    @IBOutlet weak var but6: UIButton!
    @IBOutlet weak var but7: UIButton!
    @IBOutlet weak var but8: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 현재 날짜 가져오기
        let currentDate = Date()
        
        // 날짜를 원하는 형식으로 포맷
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        //Label에 날짜 표시
        todayLabel.text = formattedDate
        
        print("add1 \(idName)")
        barStyle()
        tabBarController?.tabBar.isHidden = true
        navigationController?.isNavigationBarHidden = false
    }
    
    func barStyle(){
        if let leftImage = UIImage(named: "뒤로") {
            let buttonImage = leftImage.withRenderingMode(.alwaysOriginal)
            let leftItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(leftButAction))
            navigationItem.leftBarButtonItem = leftItem
        }
        
        if let rightImage = UIImage(named: "확인") {
            let buttonImage = rightImage.withRenderingMode(.alwaysOriginal)
            let rightItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(nextAction))
            navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    @objc private func leftButAction(){
        navigationController?.popViewController(animated: true)
        tabBarController?.tabBar.isHidden = false
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc private func nextAction(_ sender: Any) {
        if diaryCategory == "" {
            let alert = UIAlertController(title:"경고",message: "카테고리를 선택하세요.",preferredStyle: UIAlertController.Style.alert)
            
            let ok = UIAlertAction(title: "확인", style: .destructive, handler: nil)
            
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        } else {
            if let nextVC = storyboard?.instantiateViewController(withIdentifier: "add_2") as? mothlyAdd_2ViewController {
                nextVC.selectCategory = diaryCategory
                nextVC.saveId = idName
                navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    // 버튼 탭 이벤트 핸들러
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        // 선택된 카테고리에만 테두리 생성
        for button in [but1, but2, but3, but4, but5, but6, but7, but8] {
            button?.layer.backgroundColor = UIColor.clear.cgColor
        }

        sender.layer.cornerRadius = 50
        sender.layer.borderWidth = 11
        sender.layer.borderColor = UIColor.white.cgColor
        sender.layer.backgroundColor = UIColor(hexCode: "FFC965").cgColor
        
        switch sender {
        case but1:
            diaryCategory = "일상"
        case but2:
            diaryCategory = "식당"
        case but3:
            diaryCategory = "디저트"
        case but4:
            diaryCategory = "취미"
        case but5:
            diaryCategory = "쇼핑"
        case but6:
            diaryCategory = "운동"
        case but7:
            diaryCategory = "여행"
        case but8:
            diaryCategory = "자기계발"
        default:
            break
        }
        
    }
    
}
