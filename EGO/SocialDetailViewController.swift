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
        detailImage.image = UIImage(named: clickedImage)
        
        // 부모 클래스에서 인스턴스 생성후 subEggList()가져옴
        let eggSubList = SocialViewController()
        eggSubList.subEggList(detailNameLabel.text!)
    }
    
    // receiveName함수 선언
    func receiveName(_ name : String) {
        clickedName = name
    }
    
    // receiveImage함수 선언
    func receiveImage(_ image : String) {
        clickedImage = image
    }

    // 가운데 동그라미 버튼 3개
    @IBAction func firstEggBtn(_ sender: Any) {
        detailImage.image = UIImage(named: "\(clickedImage)")
    }
    
    @IBAction func secondEggBtn(_ sender: Any) {
        detailImage.image = UIImage(named: "\(friendsubEgg1[0])")
    }
    
    @IBAction func thirdEggBtn(_ sender: Any) {
        detailImage.image = UIImage(named: "\(friendsubEgg2[0])")
    }
    
    // 양쪽 화살표 버튼 2개
    var btnCount = 0
    
    @IBAction func leftBtn(_ sender: Any) {
        btnCount -= 1
        arrowBtn()
    }
    
    @IBAction func rightBtn(_ sender: Any) {
        btnCount += 1
        arrowBtn()
    }
    
    // 화살표 버튼 클릭시 이미지 변경 함수
    func arrowBtn() {
        switch btnCount{
        case 0:
            detailImage.image = UIImage(named: "\(clickedImage)")
        case 1:
            detailImage.image = UIImage(named: "\(friendsubEgg1[0])")
        case 2:
            detailImage.image = UIImage(named: "\(friendsubEgg2[0])")
        case 3:
            detailImage.image = UIImage(named: "\(friendsubEgg3[0])")
            
        case  -100..<0:
            btnCount = 3
            detailImage.image = UIImage(named: "\(friendsubEgg3[0])")
        case 4...100:
            btnCount = 0
            detailImage.image = UIImage(named: "\(clickedImage)")
        default:
            break
        }
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
