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
    
    var nameList: [String] = ["친구1","친구2","친구3", "친구4"]
    var egoList : [String] = ["egg_다람쥐.png", "egg_사자.png", "egg_수달.png", "egg_코알라.png"]
    
    // 파이어베이스 주소
    let ref = Database.database().reference()
    
    @IBOutlet weak var socialTable: UITableView!
    
    @IBOutlet weak var myTopEgg: UIImageView!
    @IBOutlet weak var myTopName: UILabel!
    @IBOutlet weak var myTopCode: UILabel!
    

    
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
        cell.friendsEgo1.image = UIImage(named: egoList[indexPath.row])
        cell.friendsEgo2.image = UIImage(named: egoList[indexPath.row])
        cell.friendsEgo3.image = UIImage(named: egoList[indexPath.row])
        cell.friendsEgo4.image = UIImage(named: egoList[indexPath.row])
        
        return cell
    }
    


    //  segue 연결 후 뷰간 값 전달 하는 법
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // sender가 기존에는 nil이지만, 셀의 ndex의 값을 받아와야 하므로 sender의 값을 indexPath.row로 변경
        performSegue(withIdentifier: "showDetail", sender: indexPath.row)
    }
    
    // performSegue()가 실행되기 전에 수행되는 함수, 실질적으로 다음 뷰로 값을 전달해준다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" { // segue가 showDetail이면 실행
            
            // vc를 FriendViewController로 다운캐스팅하여 프로퍼티에 접근
            let vc = segue.destination as? FriendViewController
            if let row = sender as? Int {
                vc?.name = nameList[row]
                vc?.ego = egoList[row]
            }
        }
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
