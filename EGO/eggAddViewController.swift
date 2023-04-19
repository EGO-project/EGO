//
//  eggAddViewController.swift
//  EGO
//
//  Created by 축신효상 on 2023/03/21.
//

import UIKit

class eggAddViewController: UIViewController {

    @IBAction func backBut(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveBut(_ sender: Any) {
       // let newEgg = egg(name: eggName.text, type: )
        
    }
    
    @IBOutlet weak var eggName: UITextField!
    
    @IBOutlet weak var eggImg: UIImageView!
    
    
    @IBAction func but1(_ sender: Any) {
        eggImg.image = UIImage(named:  "egg_다람쥐.png")

    }
    
    @IBAction func but2(_ sender: Any) {
        eggImg.image = UIImage(named:  "egg_사자.png")
    }
    
    @IBAction func but3(_ sender: Any) {
        eggImg.image = UIImage(named:  "egg_수달.png")
    }
    
    @IBAction func but4(_ sender: Any) {
        eggImg.image = UIImage(named:  "egg_코알라.png")
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
