//
//  messageViewController.swift
//  EGO
//
//  Created by 축신 MAC on 2023/01/31.
//

import UIKit

class messageViewController: UIViewController {

    @IBAction func messageBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        // completion 닫은 후 하고 싶은 거
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
