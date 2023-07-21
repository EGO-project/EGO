//
//  AddSocialViewController.swift
//  EGO
//
//  Created by 황재하 on 5/4/23.
//

import UIKit
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKCommon
import SafariServices

import KakaoSDKAuth
import KakaoSDKUser
import Firebase
import FirebaseDatabase

class AddSocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    let ref = Database.database().reference()
    
    @IBOutlet weak var newFriendsTable: UITableView!
    
    
    // 파베친구코드 저장
    var myCode: String = ""
    
    // 새로운 친구요청 리스트 저장
    var listCnt: Int?
    var friendRequests: [String] = []
    var friendRequestNickname: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newFriendsTable.dataSource = self
        newFriendsTable.delegate = self
        
        setupRefreshControl() // UIRefreshControl 설정
        nowUser()
    }
    
    // 새로운 친구 테이블 새로고침 기능
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        newFriendsTable.refreshControl = refreshControl
    }
    
    @objc private func refreshTableView() {
        nowUser()
    }
    
    
    // 새로운친구 추천 테이블뷰
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = listCnt else { return 0 }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddSocialTableViewCell
        
        cell.refreshTableView = {
            tableView.reloadData()
        }
        
        if friendRequests.isEmpty {
            cell.newName.text = "새친구가 없습니다."
        } else {
            cell.newName.text = friendRequests[indexPath.row] // 친구 코드를 표시하도록 수정
        }
        
        return cell
    }
    
    
    
    // 파이어 베이스에서 친구코드 추출
    func nowUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            // User is not logged in
            print("User is not logged in.")
            return
        }
        
        // Retrieve user data from Firebase
        ref.child("member").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            // Parse user data
            let userData = snapshot.value as? [String: Any]
            let friendCode = userData?["friendCode"] as? String ?? ""
            
            // Update UI with retrieved data
            DispatchQueue.main.async {
                self.myCode = friendCode
            }
            
            // Retrieve friend requests data from Firebase
            self.ref.child("friendRequested").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else { return }
                
                guard let friendData = snapshot.value as? [String: Any] else {
                    print("No friend requests found.")
                    self.friendRequestNickname = ["새친구가 없습니다."]
                    self.friendRequests = []
                    self.listCnt = 1
                    
                    DispatchQueue.main.async {
                        self.newFriendsTable.reloadData()
                    }
                    
                    return
                }
                
                let friendRequests = Array(friendData.values)
                var updatedFriendRequests: [String] = []
                let dispatchGroup = DispatchGroup()
                
                for friendRequest in friendRequests {
                    guard let friendRequestData = friendRequest as? [String: Any],
                          let friendCode = friendRequestData["frCode"] as? String else {
                        continue
                    }
                    
                    dispatchGroup.enter()
                    
                    self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: friendCode).observeSingleEvent(of: .value) { snapshot in
                        guard let friendNode = snapshot.value as? [String: Any],
                              let friendId = friendNode.keys.first,
                              let friendData = friendNode[friendId] as? [String: Any],
                              let nickname = friendData["nickname"] as? String
                        else {
                            dispatchGroup.leave()
                            return
                        }
                        
                        updatedFriendRequests.append(friendCode)
                        self.friendRequestNickname.append(nickname)
                        
                        let listCnt = updatedFriendRequests.count
                        self.listCnt = Int(listCnt)
                        
                        DispatchQueue.main.async {
                            self.newFriendsTable.reloadData()
                        }
                        
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.friendRequests = updatedFriendRequests
                    
                    DispatchQueue.main.async {
                        self.newFriendsTable.reloadData()
                        self.newFriendsTable.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }

    
    // 친구코드 공유버튼
    @IBAction func linkBtn(_ sender: Any) {
        copyMSG()
    }
    
    // 카카오톡 공유버튼
    @IBAction func kakaoBtn(_ sender: Any) {
        let templateId = 93508
        let templateArgs = ["frCode": "\(String(describing: myCode))"]
        
        if ShareApi.isKakaoTalkSharingAvailable() {
            // 카카오톡으로 카카오톡 공유 가능
            ShareApi.shared.shareCustom(templateId: Int64(templateId), templateArgs: templateArgs) {(sharingResult, error) in
                if error != nil {
                    // 카카오톡이 설치되어 있지 않은 경우, 사용자에게 알림을 표시합니다.
                    self.errorMSG(appName: "카카오톡")
                }
                else {
                    print("shareCustom() success.")
                    if let sharingResult = sharingResult {
                        // 카카오톡 오픈
                        self.copyMSG()
                        UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    // 인스타그램 공유버튼
    @IBAction func instaBtn(_ sender: Any) {
        let instagramURL = URL(string: "instagram://direct_message")!
        
        if UIApplication.shared.canOpenURL(instagramURL) {
            // 인스타그램이 설치되어 있는 경우, DM으로 이동
            copyMSG()
            UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
        } else {
            // 인스타그램이 설치되어 있지 않은 경우, 사용자에게 알림을 표시합니다.
            errorMSG(appName: "인스타그램")
        }
    }
    
    // 친구코드 복사 성공메세지
    func copyMSG() {
        UIPasteboard.general.string = "\(String(describing: myCode))"
        guard let mycode = UIPasteboard.general.string else {
            return print("값 없음")
        }
        let alert = UIAlertController(title: "친구코드 복사됨", message: "\(mycode)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            print("수행 할 동작")
        }
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
    
    // 친구코드 복사 오류메세지
    func errorMSG(appName: String) {
        let alert = UIAlertController(title: "\(appName)이 설치되어 있지 않습니다.", message: "\(appName)을 설치하고 다시 시도해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
