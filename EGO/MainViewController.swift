//
//  MainViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/03/16.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var eggName: UILabel!
    @IBOutlet weak var eggImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseRef = Database.database().reference()
        let eggRef = databaseRef.child("egg")
        
        eggRef.observe(.value) { snapshot in
            if let value = snapshot.value as? [String: Any],
               let name = value["name"] as? String {
                // 가져온 name 값을 UILabel에 설정합니다.
                self.eggName.text = name
            }
        }

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
