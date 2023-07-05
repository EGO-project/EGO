//
//  detailViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/28.
//

import UIKit

class detailViewController: UIViewController {
    
    @IBOutlet weak var detailDate: UILabel!
    @IBOutlet weak var detailText: UILabel!
    @IBOutlet weak var detailCategory: UIImageView!
    
    var selectDiary : diary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectDiary {
            
            detailText.text = selectDiary.description
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: selectDiary.date)
            detailDate.text = dateString
            
            let img = UIImage(named: selectDiary.category)
            detailCategory.image = img
        }
        else {print("nil")}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "change" { // segue 식별자에 따라 분기 처리
                if let changeVC = segue.destination as? changeDiaryViewController {
                    changeVC.changeDiary = selectDiary // 데이터 전달
                } else {
                    print("데이터 전달 실패")
                }
            }
        }
    }
