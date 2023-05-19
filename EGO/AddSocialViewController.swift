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
        nowUser()
    }
    
    // 새로운친구 추천 테이블뷰
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = listCnt else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddSocialTableViewCell
        
        
        cell.newName.text = friendRequestNickname[indexPath.row]
        
        return cell
    }
    
    
    
    // 파이어 베이스에서 친구코드 추출
    func nowUser() {
        UserApi.shared.me { user, error in
            guard error == nil else {
                print("카카오톡 정보 가져오지 못함")
                print(error!)
                return
            }
            
            guard let id = user?.id else {
                return
            }
            
            // 현재 사용자 친구코드 가져오기
            self.ref.child("member").child("\(id)").child("friendCode").observeSingleEvent(of: .value) { snapshot  in
                print("\(snapshot)")
                let value = snapshot.value as? String ?? ""
                DispatchQueue.main.async {
                    self.myCode = value
                }
            }
            
            
            
            // 새로운 친구요청 갯수와 목록 친구 코드 가져오기 : 테이블뷰에 사용
            self.ref.child("friendRequested").child("\(id)").observeSingleEvent(of: .value) { snapshot  in
                guard let value = snapshot.value else {
                    print("값을 가져올 수 없음")
                    return
                }
                
                guard let newfriends = value as? [String] else { return }
                
                print("친구요청 리스트 : \(newfriends), \(newfriends.count)")
                
                // 친구 요청 리스트를 저장한 후, 테이블 뷰를 새로고침합니다.
                self.friendRequests = newfriends
                
                // for 루프
                var updatedFriendNickname: [String] = [] // 업데이트된 친구 닉네임 배열
                
                for code in newfriends {
                    self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: code).observeSingleEvent(of: .value) { snapshot in
                        guard let friendNode = snapshot.value as? [String: Any],
                              let friendId = friendNode.keys.first,
                              let friendData = friendNode[friendId] as? [String: Any],
                              let nickname = friendData["nickname"] as? String
                        else {
                            print("상위값 가져오기 실패")
                            return
                        }
                        
                        print("개발중1 : \(friendNode)")
                        print("개발중2 : \(friendId)")
                        print("개발중3 : \(friendData)")
                        print("개발중4 : \(nickname)")
                        
                        updatedFriendNickname.append(nickname) // 업데이트된 친구 닉네임 배열에 추가
                        print(updatedFriendNickname)
                        self.friendRequestNickname.append(nickname) // nickname을 friendNickname 배열에 추가합니다.
                        
                        // 행 갯수 지정
                        let listCnt = updatedFriendNickname.count
                        self.listCnt = Int(listCnt)
                        
                        DispatchQueue.main.async {
                            self.friendRequests = newfriends
                            self.friendRequestNickname = updatedFriendNickname
                            self.newFriendsTable.reloadData()
                        }
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
    
    // 친구추가버튼
    @IBAction func addFriendBtn(_ sender: Any) {
    }
    
}

