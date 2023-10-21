//
//  DeleteViewController.swift
//  EGO
//
//  Created by 김민석 on 2023/06/05.
//

import UIKit

class DeleteViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func moveToWithdrawl(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "Withdrawl") as? UIViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnClick(_ sender: UIButton) {
        sender.isSelected.toggle()
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
