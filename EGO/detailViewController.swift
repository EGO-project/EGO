//
//  detailViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/28.
//

import UIKit

class detailViewController: UIViewController {
    
    @IBOutlet weak var detailDate: UILabel!
    
    @IBOutlet weak var detailText: UITextView!
    
   
    @IBAction func deBackBut(_ sender: Any) {
        self.dismiss(animated: true)
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
