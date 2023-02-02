//
//  mothlyAdd_2ViewController.swift
//  EGO
//
//  Created by 축신 MAC on 2023/02/02.
//

import UIKit

class mothlyAdd_2ViewController: UIViewController {
    
    @IBAction func mothlyBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        // completion 닫은 후 하고 싶은 거
    }
    
    @IBOutlet var mothlyText: UITextView!
    
    @IBAction func mothlySave(_ sender: Any) {
        guard let letter = mothlyText.text, letter.count > 0 else{
            // alert(message: "내용을 입력하세요.")
            return
        }
        /*
        // 새로운 instance 생성 & 배열에 저장
         let newLetter = mothly(content: letter)
         mothly.dummymothlyList.append(newLetter)
         */
        
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
