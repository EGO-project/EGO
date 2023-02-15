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

import UIKit

class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var socialTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socialTable.delegate = self
        socialTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! SocialTableViewCell
        cell.friendName.text = "\(friendsName[indexPath.row])"
        cell.friendMainEgg.image = UIImage(named: "\(friendsEgg[indexPath.row])")
        
        // 셀 선택시 색변경 없앰
        cell.selectionStyle = .none
                
        return cell
        
    }
    
    // 셀 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    
    
    
    
    // 데이터 전달 메소드로 segue가 실행되기 전에 실행되는 메서드
    // 여럽다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" { // if문으로 segue의 id를 확인함
            let cell = sender as! UITableViewCell
            let indexPath = self.socialTable.indexPath(for: cell)
            let detailView = segue.destination as! SocialDetailViewController
            detailView.receiveName(friendsName[(indexPath?.row)!])
        }
    }
}
