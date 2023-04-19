//
//  mothlyAdd_1ViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit

class mothlyAdd_1ViewController: UIViewController {

    @IBAction func backBut(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    
    @IBOutlet weak var dateLbl: UILabel!
    
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
