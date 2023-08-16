//
//  SocialViewController.swift
//  EGO
//
//  Created by 황재하 on 2/14/23.
//
import UIKit
import Firebase
import FirebaseDatabase

import KakaoSDKAuth
import KakaoSDKUser

var egoList : [String] = ["egg_다람쥐.png", "egg_사자.png", "egg_수달.png", "egg_코알라.png"]

// 카카오톡 로그인시 현재 사용자 정보 저장 구조체
class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // 파이어베이스 주소
    let ref = Database.database().reference()

    
    // 테이블뷰 프로퍼티
    var rowCount: Int?  // 행 갯수
    var friendName: [String] = []
    var friendCode: [String] = []
    var friendNickname: [String] = []
    var userEggs: [egg] = []
    
    
    @IBOutlet weak var socialTable: UITableView!
    
    @IBOutlet weak var myTopEgg: UIImageView!
    @IBOutlet weak var myTopName: UILabel!
    @IBOutlet weak var myTopCode: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socialTable.delegate = self
        socialTable.dataSource = self
        
        setupRefreshControl() // UIRefreshControl 설정
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureUserData()
    }
    
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        socialTable.refreshControl = refreshControl
    }
    
    @objc private func refreshTableView() {
        configureUserData()
    }
    
    // 섹션 내 행 갯수 지정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendNickname.count
    }

    
    // 셀 생성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! SocialTableViewCell

        // Use the friend property of the cell to automatically update the cell's UI
        if indexPath.row < friendNickname.count {
            cell.friend = friendNickname[indexPath.row]
        }

        return cell
    }




    // 셀 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 + 10
    }
    
    // 친구 삭제 버튼, 스와이프
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 데이터 소스 배열에서 해당 친구를 삭제합니다.
            friendNickname.remove(at: indexPath.row)
            
            // 테이블 뷰에서 셀을 삭제하기 전에 먼저 행 수를 업데이트합니다.
            rowCount = friendNickname.count
            
            // 파이어베이스에서 해당 친구 데이터를 삭제합니다.
            deleteFriend()
                    
            // 테이블 뷰에서 해당 셀을 삭제합니다.
            socialTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "친구삭제"
    }
    
    func deleteFriend() {
        // Friend code to be removed
        let code = self.friendCode
        print("Friend code to be removed: \(code)")
        
        // Retrieve friend's unique friend code using the friend code: querying child values
        self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: "\(code)").observeSingleEvent(of: .value) { snapshot in
            guard let friendNode = snapshot.value as? [String: Any],
                  let friendId = friendNode.keys.first else {
                // Show failure alert for friend removal
                print("Failed to retrieve friend's friend code")
                return
            }
            
            guard let userId = Auth.auth().currentUser?.uid else {
                // User is not logged in
                print("User is not logged in.")
                return
            }
            
            // Remove friend from Firebase
            self.ref.child("friend").child(userId).child(friendId).removeValue()
            
            // Remove user from friend's friend list
            self.ref.child("friend").child(friendId).child(userId).removeValue()
        }
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
                vc?.ego = egoList[row]
            }
        }
    }
    
    func configureUserData() {
        // Retrieve data from Firebase instead of Kakao login
        
        guard let userId = Auth.auth().currentUser?.uid else {
            // User is not logged in
            print("User is not logged in.")
            return
        }
        
        // Retrieve egg data for the user
        
        fetchEggData(for: userId) { eggs in
            self.userEggs = eggs
            // 여기서 필요한 UI 업데이트를 수행할 수 있습니다.
            // 예: 사용자의 top egg 이미지 및 정보 업데이트
            if let topEgg = eggs.first {
                DispatchQueue.main.async {
                    self.myTopEgg.image = UIImage(named:"수달_1단계")  // 예제 코드, 실제 이미지 이름이 다를 수 있습니다.
                    // 기타 필요한 UI 업데이트 코드를 여기에 추가합니다.
                }
            }
        }
        
        // Retrieve user data from Firebase
        ref.child("member").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            // Parse user data
            let userData = snapshot.value as? [String: Any]
            let nickname = userData?["nickname"] as? String ?? ""
            let friendCode = userData?["friendCode"] as? String ?? ""
            
            // Update UI with retrieved data
            DispatchQueue.main.async {
                self.myTopName.text = nickname
                self.myTopCode.text = friendCode
            }
            
            
            // Retrieve friend data from Firebase
            self.ref.child("friend").child(userId).observeSingleEvent(of: .value) { snapshot in
                guard let friendData = snapshot.value as? [String: Any] else {
                    print("No friend data found.")
                    return
                }
                
                let friendUId = Array(friendData.keys)
                
                // Retrieve friend names using friend codes
                var updatedFriendNickname: [String] = []
                let dispatchGroup = DispatchGroup()
                
                for uId in friendUId {
                    dispatchGroup.enter()
                    print("friendUID: \(uId)")
                    
                    
                    self.ref.child("member").child(uId).observeSingleEvent(of: .value) { snapshot in
                        guard let friendData = snapshot.value as? [String: Any],
                              let nickname = friendData["nickname"] as? String
                        else {
                            print("Failed to retrieve friend data")
                            dispatchGroup.leave()
                            return
                        }
                    
                        
                        
                        updatedFriendNickname.append(nickname)
                        dispatchGroup.leave()
                        self.friendNickname = []

                        self.friendNickname.append(nickname)
                        
                        DispatchQueue.main.async {
                            self.socialTable.reloadData()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.friendNickname = updatedFriendNickname.sorted { (name1, name2) -> Bool in
                        if name1.localizedCompare(name2) == .orderedSame {
                            return name1 < name2
                        } else {
                            return name1.localizedCompare(name2) == .orderedAscending
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.socialTable.reloadData()
                        self.socialTable.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }
    
    func fetchEggData(for userId: String, completion: @escaping ([egg]) -> Void) {
        let databaseRef = Database.database().reference()
        let userEggRef = databaseRef.child("egg").child(userId)
        
        userEggRef.observeSingleEvent(of: .value) { snapshot in
            var eggArray: [egg] = []
            
            // 각 알의 스냅샷을 반복하면서 'egg' 객체로 변환
            for childSnapshot in snapshot.children {
                if let childSnapshot = childSnapshot as? DataSnapshot {
                    let eggData = egg(snapshot: childSnapshot)
                    eggArray.append(eggData)
                }
            }
            
            // 모든 알 데이터를 가져온 후 완료 핸들러를 호출
            completion(eggArray)
        }
    }
}
