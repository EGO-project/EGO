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
struct KakaoData{
    var kakaoId: Int64 // 카카오톡 아이디
    var kakaoName: String // 카카오톡 닉네임
}

class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // 파이어베이스 주소
    let ref = Database.database().reference()
    
    // KakaoData 구조체 멤버 변수
    var kakaoData: KakaoData?
    
    // 테이블뷰 프로퍼티
    var rowCount: Int?  // 행 갯수
    var friendName: [String] = []
    var friendCode: [String] = []
    var friendNickname: [String] = []
    
    
    @IBOutlet weak var socialTable: UITableView!
    
    @IBOutlet weak var myTopEgg: UIImageView!
    @IBOutlet weak var myTopName: UILabel!
    @IBOutlet weak var myTopCode: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socialTable.delegate = self
        socialTable.dataSource = self
        
        setupRefreshControl() // UIRefreshControl 설정
        
        // 카카오 로그인
        kakaoUser()

        // 개인 이메일 로그인
        updateUserInfo()
        
    }
    
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        socialTable.refreshControl = refreshControl
    }
    
    @objc private func refreshTableView() {
        kakaoUser()
    }
    
    // 섹션 내 행 갯수 지정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let row = rowCount else {return 0}
        return row
    }
    
    // 셀 생성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! SocialTableViewCell
        
        if indexPath.row < friendNickname.count {
            let friendName = friendNickname[indexPath.row]
            cell.friendsName.text = friendName
            // 이 외에 다른 셀 구성 요소에 friendName을 활용할 수 있습니다.
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
            guard let userId = kakaoData?.kakaoId else {
                return
            }
            let friendCode = friendCode[indexPath.row]
            ref.child("friend").child("\(userId)").child("\(friendCode)").removeValue()
                    
            // 테이블 뷰에서 해당 셀을 삭제합니다.
            socialTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "친구삭제"
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
    
    
    
    
    
 
    
    
    // 개인 이메일 로그인 사용자
    func updateUserInfo() {
        if let currentUser = Auth.auth().currentUser {
            let safeEmail = currentUser.email?.replacingOccurrences(of: ".", with: "-") ?? ""
            self.ref.child("member").child(safeEmail).observeSingleEvent(of: .value) { [weak self] snapshot  in
                guard let self = self else { return }

                let value = snapshot.value as? [String: Any] ?? [:]
                let nickname = value["nickname"] as? String ?? ""
                let friendCode = value["friendCode"] as? String ?? ""

                print("개인 이메일 로그인 개발중 : \(nickname), \(friendCode)")

                DispatchQueue.main.async {
                    self.myTopName.text = nickname
                    self.myTopCode.text = friendCode
                }
            }
        } else {
            // 사용자가 로그인되어 있지 않은 경우에 대한 처리
            print("사용자가 로그인되어 있지 않습니다.")
        }
    }
    

    
    // 현재 사용자 카카오톡 데이터
    func kakaoUser() {
        UserApi.shared.me { [self] user, error in
            guard error == nil else {
                print("카카오톡 정보 가져오지 못함")
                print(error!)
                return
            }
            
            guard let id = user?.id,
                  let nickname = user?.kakaoAccount?.profile?.nickname else {
                return
            }
            
            // 카카오톡 데이터 구조체에 저장
            self.kakaoData = KakaoData(kakaoId: id, kakaoName: nickname)
            
            // 현재 사용자 친구코드 파이어베이스에서 가져오기
            self.ref.child("member").child("\(id)").child("friendCode").observeSingleEvent(of: .value) { snapshot  in
                guard let frcode = snapshot.value as? String else {return}
                // 내 정보 설정
                print("현재 카카오톡 사용자 친구코드 : \(frcode)")
                self.myTopName.text = self.kakaoData?.kakaoName ?? "nil"
                self.myTopCode.text = frcode
                // 내 정보 설정
                DispatchQueue.main.async {
                    self.myTopName.text = self.kakaoData?.kakaoName ?? "nil"
                    self.myTopCode.text = frcode
                }
            }
            
            // 친구목록 테이블뷰 행갯수 지정하기
            self.ref.child("friend").child("\(String(describing: id))").observeSingleEvent(of: .value) { snapshot in
                let count = snapshot.childrenCount
                print("테이블뷰 행 갯수 : \(count)")
                self.rowCount = Int(count)
            }
            
            // 친구코드 목록 친구 이름 배열에 저장하기 ex) 친구코드 목록 배열 : ["@57178", "@19046"]
            self.ref.child("friend").child("\(String(describing: id))").observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let keyValues = snapshot.value as? [String: Any] else {
                    print("해당 키값을 찾을 수 없습니다.")
                    return
                }
                let codes = Array(keyValues.keys)
                self.friendCode = codes
                print("친구코드 목록 배열: \(self.friendCode)")
                
                // 친구코드 목록 배열로 하윗값으로 상위값 조회하여 친구 이름 가져오기
                var updatedFriendNickname: [String] = [] // 업데이트된 친구 닉네임 배열
                let dispatchGroup = DispatchGroup() // 디스패치 그룹 생성
                
                // for 루프
                for code in self.friendCode {
                    dispatchGroup.enter() // 디스패치 그룹 진입
                    
                    self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: code).observeSingleEvent(of: .value) { snapshot in
                        guard let friendNode = snapshot.value as? [String: Any],
                              let friendId = friendNode.keys.first,
                              let friendData = friendNode[friendId] as? [String: Any],
                              let nickname = friendData["nickname"] as? String
                        else {
                            print("상위값 가져오기 실패")
                            dispatchGroup.leave() // 디스패치 그룹 떠남
                            return
                        }
                        updatedFriendNickname.append(nickname) // 업데이트된 친구 닉네임 배열에 추가
                        dispatchGroup.leave() // 디스패치 그룹 떠남
                        
                        print("개발중1 : \(friendNode)")
                        print("개발중2 : \(friendId)")
                        print("개발중3 : \(friendData)")
                        print("개발중4 : \(nickname)")
                        
                        self.friendNickname.append(nickname) // nickname을 friendNickname 배열에 추가합니다.
                        print("개발중5 : \(self.friendNickname)")
                        
                        DispatchQueue.main.async {
                            self.socialTable.reloadData()
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        // 친구 닉네임 배열을 업데이트하고 테이블 뷰를 새로고침
                        self.friendNickname = updatedFriendNickname.sorted { (name1, name2) -> Bool in
                            if name1.localizedCompare(name2) == .orderedSame { // 가나다 순으로 정렬
                                return name1 < name2 // 영어는 사전적으로 더 뒤로 가게 함
                            } else {
                                return name1.localizedCompare(name2) == .orderedAscending
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.socialTable.reloadData()
                            self.socialTable.refreshControl?.endRefreshing() // 새로고침 종료
                        }
                    }
                }
            }
        }
    }
}
