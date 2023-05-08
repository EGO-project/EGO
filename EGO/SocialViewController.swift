//
//  SocialViewController.swift
//  EGO
//
//  Created by 황재하 on 2/14/23.
//
import UIKit
import Firebase
import FirebaseDatabase


class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // 파이어베이스 주소
    let ref = Database.database().reference()
    
    @IBOutlet weak var socialTable: UITableView!
    
    @IBOutlet weak var myTopEgg: UIImageView!
    @IBOutlet weak var myTopName: UILabel!
    @IBOutlet weak var myTopCode: UILabel!
    
    var nameList: [String] = ["친구1","친구2","친구3","친구4","친구5","친구6"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socialTable.delegate = self
        socialTable.dataSource = self
        
        myNameFB()
    }
    
    
    // 섹션 내 행 갯수 지정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameList.count
    }
    
    // 셀 생성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! SocialTableViewCell
       
        cell.friendsName.text = nameList[indexPath.row]
        return cell
    }
    
    // 셀 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 130
      }
    
    // 파베에서 내 이름 가져오기
    func myNameFB() {
        self.ref.child("member").child("2699328344").child("nickname").observeSingleEvent(of: .value) { snapshot  in
            print("\(snapshot)")
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.myTopName.text = value
            }
        }
    }
}

//    // 파이어베이스 이용
//    var ref : DatabaseReference! // ref에 파베주소 넣음
//    @IBOutlet weak var firebaseLbl: UILabel! // 가져온 값 확인 레이블
//    @IBAction func firebaseBtn(_ sender: UIButton) { // 값 보내기, 가져오기 버튼
//        self.ref = Database.database().reference()
//
//       // 파이어베이스에 값 넣기
//        let myNameRef = self.ref.child("myName")
//        let myCodeRef = self.ref.child("myCode")
//        myNameRef.setValue(self.myTopName.text)
//        myCodeRef.setValue(self.myTopCode.text)
//
//        // 키 값 설정
//        let announcement1 = self.ref.child("announcement").child("5").child("title")
//        let announcement2 = self.ref.child("announcement").child("5").child("description")
//
//        // 밸류 설정
//        announcement1.setValue("제목")
//        announcement2.setValue("내용")
//
//        // 38 ~ 44 한 줄 로
//        self.ref.child("announcement/7").updateChildValues(["title": "제목7", "description": "내용7"])
//
//        // 파이어베이스 값 가져오기
//        ref.child("announcement").child("7").child("title").observeSingleEvent(of: .value) { snapshot in
//            print("\(snapshot)")
//            let value = snapshot.value as? String ?? ""
//            DispatchQueue.main.async {
//                self.firebaseLbl.text = value
//            }
//        }
//    }
