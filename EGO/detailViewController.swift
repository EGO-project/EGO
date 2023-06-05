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
    
   
    @IBAction func deBackBut(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func change(_ sender: Any) {
        
        performSegue(withIdentifier: "change", sender: nil)
    }
    
    // segue 실행 전 전달하려는 데이터 set
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is changeDiaryViewController {
            guard let vc = segue.destination as? changeDiaryViewController else { return }
            if let selectDiary{ vc.changeDiary = selectDiary} else { print("실패") }
        }
    }
    
    
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
