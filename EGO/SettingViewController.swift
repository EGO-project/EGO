//
//  SettingViewController.swift
//  EGO
//
//  Created by 박기태 on 2023/04/02.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var setAlarmSwitch: UISwitch!
    @IBOutlet weak var lavel: UILabel!
    
    @IBAction func switchChange(_ sender: Any) {
        if self.alarmSwitch.isOn { return } // 1
             
             self.alarmSwitch.setOn(true, animated: true) // 2
             let alert = UIAlertController(title: "해당 기능을 끄시겠습니까?", message: "지정하신 알람도 꺼지게 됩니다.", preferredStyle: .alert)
          
             alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                 // self.mySwitch.setOn(true, animated: true) // 3
             }))
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                 self.alarmSwitch.setOn(false, animated: true) // 4
             }))
          
             self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmSwitch.setOn(true, animated: true)
        // Do any additional setup after loading the view.
    }

}
