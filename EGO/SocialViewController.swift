//
//  SocialViewController.swift
//  EGO
//
//  Created by 황재하 on 2/14/23.
//

let myEgg = ["myEgg.png"]
let myName = ["황재하"]
let myCode = ["#1234"]

let friendsName = ["친구1", "친구2", "친구3"]
let friendsEgg = ["egg1.png", "egg2.png", "egg3.png"]

// case 문에 따라 알들의 이미지를 가져오기위해 빈 배열 생성
var friendsubEgg1: [String] = []
var friendsubEgg2: [String] = []
var friendsubEgg3: [String] = []

import UIKit

class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var socialTable: UITableView!
    
    @IBOutlet weak var myTopEgg: UIImageView!
    @IBOutlet weak var myTopName: UILabel!
    @IBOutlet weak var myTopCode: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socialTable.delegate = self
        socialTable.dataSource = self
        
        myTopEgg.image = UIImage(named: "\(myEgg[0])")
        myTopName.text = "\(myName[0])"
        myTopCode.text = "\(myCode[0])"
    }
    
    // 섹션 내 행 갯수 지정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsName.count
    }
    
    // 셀 생성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! SocialTableViewCell
        cell.friendName.text = "\(friendsName[indexPath.row])"
        cell.friendMainEgg.image = UIImage(named: "\(friendsEgg[indexPath.row])")
        
        subEggList(cell.friendName.text!)
        
        cell.friendSubEgg1.image = UIImage(named: "\(friendsubEgg1[0])")
        cell.friendSubEgg2.image = UIImage(named: "\(friendsubEgg2[0])")
        cell.friendSubEgg3.image = UIImage(named: "\(friendsubEgg3[0])")
        
        // 셀 선택시 색변경 없앰
        cell.selectionStyle = .none
        
        return cell
    }
    
    // 셀 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    // 서브에그리스트 지정
    func subEggList(_ userName: String){
        switch userName {
        case "친구1":
            friendsubEgg1 = ["egg2.png"]
            friendsubEgg2 = ["egg3.png"]
            friendsubEgg3 = ["egg1.png"]
        case "친구2":
            friendsubEgg1 = ["egg3.png"]
            friendsubEgg2 = [""]
            friendsubEgg3 = [""]
        case "친구3":
            friendsubEgg1 = ["egg1.png"]
            friendsubEgg2 = ["egg2.png"]
            friendsubEgg3 = [""]
        default: break
        }
    }
    
    // 데이터 전달 메소드로 segue가 실행되기 전에 실행되는 메서드
    // 여럽다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" { // if문으로 segue의 id를 확인함
            let cell = sender as! UITableViewCell
            let indexPath = self.socialTable.indexPath(for: cell)
            let detailView = segue.destination as! SocialDetailViewController
            detailView.receiveName(friendsName[(indexPath?.row)!])
            detailView.receiveImage(friendsEgg[(indexPath?.row)!])
        }
    }
    
}
