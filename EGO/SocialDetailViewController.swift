//
//  SocialDetailViewController.swift
//  EGO
//
//  Created by 황재하 on 2/14/23.
//

import UIKit

class SocialDetailViewController: UIViewController {

    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    
    
    // 이전 뷰인 SocialViewController뷰에서 선택한 친구의 이름을 가져와 저장할 변수 선언
    var clickedName = ""
    var clickedImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이전 뷰에서 가져온 친구의 이름을 => detailNameLabel의 text에 저장
        detailNameLabel.text = clickedName
        
    }
    
    // receiveName함수 선언
    func receiveName(_ name : String) {
        clickedName = name
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
