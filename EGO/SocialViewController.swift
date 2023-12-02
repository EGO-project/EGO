//
//  SocialViewController.swift
//  EGO
//
//  Created by 김민석 on 2/14/23.
//
import UIKit
import Firebase
import FirebaseDatabase

var egoList : [String] = ["egg_다람쥐.png", "egg_사자.png", "egg_수달.png", "egg_코알라.png"]

// 카카오톡 로그인시 현재 사용자 정보 저장 구조체
class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // 파이어베이스 주소
    let ref = Database.database().reference()
    
    var userId: String?
    
    // 테이블뷰 프로퍼티
    var rowCount: Int?  // 행 갯수
    var friendList: [Friend] = []
    var userEggs: [egg] = []
    
    let LoginManager = FirebaseManager.shared
    
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
        super.viewWillAppear(animated)
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
        return friendList.count
    }
    
    // 셀 생성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! SocialTableViewCell
        
        if indexPath.row < friendList.count {
            let currentFriend = friendList[indexPath.row]
            
            fetchMemberData(for: currentFriend.id ?? "") { member in
                cell.friendName = member.nickname
            }
            
            FirebaseManager.shared.fetchProfileImageFromFirebase(id: currentFriend.id ?? "") { image in
                guard image != nil else {
                    cell.friendProfileImg = UIImage(named: "Profile")
                    return
                }
                cell.friendProfileImg = image
            }
            
            // 친구의 알 데이터도 가져옵니다.
            fetchEggData(for: currentFriend.id ?? "") { eggs in
                cell.friendEggs = eggs
            }
        }
        
        cell.eggTapHandler = { [weak self] selectedEgg in
            let friendInfo = (id: self?.friendList[indexPath.row].id, selectedEgg: selectedEgg)
            self?.performSegue(withIdentifier: "showDetail", sender: friendInfo)
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
            let friendToDelete = friendList[indexPath.row]
            deleteFriend(withId: friendToDelete.id) { success in
                if success {
                    self.friendList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    // TODO: 실패한 경우 사용자에게 알림
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "친구삭제"
    }
    
    func deleteFriend(withId friendId: String?, completion: @escaping (Bool) -> Void) {
        guard let friendId = friendId else {
            completion(false)
            return
        }
        
        guard let currentUserId = userId else {
            print("User ID not available.")
            completion(false)
            return
        }
        
        // Remove friend from Firebase
        self.ref.child("friend").child(currentUserId).child(friendId).removeValue { error, _ in
            if let error = error {
                print("Error deleting friend: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Remove user from friend's friend list
            self.ref.child("friend").child(friendId).child(currentUserId).removeValue { error, _ in
                if let error = error {
                    print("Error deleting user from friend's list: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    //  segue 연결 후 뷰간 값 전달 하는 법
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀 인스턴스를 가져옵니다.
            if let cell = tableView.cellForRow(at: indexPath) as? SocialTableViewCell {
                // 친구의 egg 데이터가 있다면, 세그웨이 실행
                if cell.hasEggs {
                    // sender가 기존에는 nil이지만, 셀의 ndex의 값을 받아와야 하므로 sender의 값을 indexPath.row로 변경
                    performSegue(withIdentifier: "showDetail", sender: indexPath.row)
                }
            }
    }
    
    // performSegue()가 실행되기 전에 수행되는 함수, 실질적으로 다음 뷰로 값을 전달해준다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let friendInfo = sender as? (id: String?, selectedEgg: egg) {
                let vc = segue.destination as? FriendViewController
                
                fetchEggData(for: friendInfo.id ?? "") { eggs in
                    vc?.allEggs = eggs
                    vc?.selectedEgg = friendInfo.selectedEgg
                    
                    DispatchQueue.main.async {
                        vc?.setupEggData()
                        vc?.setupPageControl()
                    }
                    
                    print(eggs)
                    print(friendInfo.selectedEgg)
                    // 만약 FriendViewController에서 UI 업데이트가 필요하다면,
                    // 해당 ViewController에 메서드를 추가하여 호출할 수 있습니다.
                    // 이 경우, viewDidLoad를 직접 호출하는 것을 피하십시오.
                }
            }
        }
    }


    
    func configureUserData() {
        // Check if the user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            return
        }
        
        userId = currentUserId // 사용자 ID 저장
        
        fetchMemberData(for: userId!){ member in
            DispatchQueue.main.async {
                self.myTopName.text = member.nickname
                self.myTopCode.text = member.friendCode
            }
        }
        
        // Fetch user's eggs
        fetchEggData(for: userId!) { eggs in
            self.userEggs = eggs
            
            // Update user's top egg (if it exists)
            if let topEgg = eggs.first {
                DispatchQueue.main.async {
                    // Assuming that the kind and state together make the image name
                    self.myTopEgg.image = UIImage(named: topEgg.kind + "_" + topEgg.state)
                    // You might also want to update other properties if needed
                }
            }
        }
        
        // Fetch user's friend list
        fetchFriendData(for: userId!) { friends in
            self.friendList = friends
            print(self.friendList)
            DispatchQueue.main.async {
                self.socialTable.reloadData()
            }
        }
    }
    
    func fetchEggData(for userId: String, completion: @escaping ([egg]) -> Void) {
        let userEggRef = ref.child("egg").child(userId)
        userEggRef.observeSingleEvent(of: .value) { snapshot in
            var eggs: [egg] = []
            for childSnapshot in snapshot.children {
                if let child = childSnapshot as? DataSnapshot {
                    let eggData = egg(snapshot: child)
                    if eggData.eggState {
                        eggs.append(eggData)
                    }
                }
            }
            completion(eggs)
            
        }
    }
    
    
    func fetchFriendData(for userId: String, completion: @escaping ([Friend]) -> Void) {
        let userFriendRef = ref.child("friend").child(userId)
        userFriendRef.observeSingleEvent(of: .value) { snapshot in
            var friends: [Friend] = []
            for childSnapshot in snapshot.children {
                if let child = childSnapshot as? DataSnapshot,
                   let friendDict = child.value as? [String: Any] {
                    let idValue = child.key
                    let friendData = Friend(id: idValue,
                                            code: friendDict["code"] as? String,
                                            favoriteState: friendDict["favoriteState"] as? String,
                                            publicState: friendDict["publicState"] as? String,
                                            state: friendDict["state"] as? String)
                    friends.append(friendData)
                }
            }
            completion(friends)
        }
    }
    
    func fetchMemberData(for userId: String, completion: @escaping (Member) -> Void) {
        let memberRef = ref.child("member").child(userId)
        memberRef.observeSingleEvent(of: .value) { snapshot in
            let memberData = Member(snapshot: snapshot)
            completion(memberData)
        }
    }
}
