//
//  AddFriendViewController.swift
//  EGO
//
//  Created by 황재하 on 5/15/23.
//

import UIKit
import Firebase
import FirebaseDatabase

import KakaoSDKAuth
import KakaoSDKUser

class AddFriendViewController: UIViewController {
    
    // 파이어베이스 주소
    let ref = Database.database().reference()
    
    // 파이어베이스 구조체
    struct FirebaseData{
        var friendId: String?
        var friendNickname: String?
    }
    
    // 파이어베이스 구조체 멤버 변수
    var firebaseData: FirebaseData?
    
    // 카카오톡 로그인시 현재 사용자 정보 저장 구조체
    struct KakaoData{
        var kakaoId: Int64 // 카카오톡 아이디
    }
    
    // KakaoData 구조체 멤버 변수
    var kakaoData: KakaoData?
    
    // 추가할 친구코드 처리 프로퍼티
    @IBOutlet weak var codeBox: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeBox.layer.cornerRadius = 10
        addBtn.layer.cornerRadius = 5
        
    }
    
    // 친구코드 친구 추가 버튼
    @IBAction func addFriendCode(_ sender: Any) {
        
        // 1번 기능 : friend > 현재 사용자 id > @00000 추가
        
        // 추가할 친구코드
        guard let code = codeBox.text else { print("친구코드 없음"); addFail(); return }
        
        // 현재 사용자 카카오톡 id가져오기
        func kakaoUser() {
            UserApi.shared.me { user, error in
                guard error == nil else {
                    print("카카오톡 정보 가져오지 못함")
                    print(error!)
                    return
                }
                guard let id = user?.id else { return }
                // 구조체 KakaoData에 사용자 카카오톡 id 저장
                self.kakaoData = KakaoData(kakaoId: id)
                // print(String(describing: self.kakaoData?.kakaoId))
            }
        }
        kakaoUser()
        
        
        // 개발중
        guard let myKakaoId = self.kakaoData?.kakaoId else { return }
        
        // 이전에 저장된 friendCodes 배열을 가져옵니다.
        self.ref.child("friendRequested").child("\(myKakaoId)").observeSingleEvent(of: .value) { snapshot in
            var friendCodes: [String] = []
            
            if let existingFriendCodes = snapshot.value as? [String] {
                friendCodes = existingFriendCodes
            }
            
            // 중복된 코드와 공백을 제외한 문자열만 friendCodes 배열에 추가합니다.
            let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedCode.isEmpty && !friendCodes.contains(trimmedCode) {
                friendCodes.append(trimmedCode)
            }
            
            // 업데이트된 friendCodes 배열을 다시 저장합니다.
            self.ref.child("friendRequested").child("\(myKakaoId)").setValue(friendCodes)
        }






        
        // 2번 기능 : friend > 현재 사용자 id > memberId : 23dfjkeaowef 추가
        // 하윗값으로 상윗값 가져오기 : 친구 이름 알아내서
        self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: "\(code)").observeSingleEvent(of: .value) { snapshot in
            guard let friendNode = snapshot.value as? [String: Any],
                  let friendId = friendNode.keys.first,
                  let friendData = friendNode[friendId] as? [String: Any],
                  let friendnickname = friendData["nickname"] as? String else {
                // 친구 추가 실패 경고창
                return addFail()
            }
            self.firebaseData = FirebaseData()
            self.firebaseData?.friendId = friendId
            self.firebaseData?.friendNickname = friendnickname
            print("Friend Node: \(friendNode)")
            print("Friend ID: \(friendId)")
            print("Friend Nickname: \(friendnickname)")
            
            // 파이어베이스에 친구코드 추가
            guard let mykakaoId = self.kakaoData?.kakaoId,
                  let friendkakaoId = self.firebaseData?.friendId
            else {return}
            self.ref.child("friend").child("\(mykakaoId)").child("\(code)").setValue([
                "favoriteState": "빔",
                "memberId": friendkakaoId,
                "publicState": "빔",
                "state": "빔"
            ])
            // 친구 추가 성공 경고창
            addSuccess()
        }
        
        
        
        
        // 친구 추가 성공 경고창
        func addSuccess() {
            let alertController = UIAlertController(title: "알림", message: "친구가 추가되었습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                self.codeBox.text = "" // 텍스트 필드 초기화
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // 친구 추가 실패 경고창
        func addFail() {
            let alertController = UIAlertController(title: "알림", message: "친구 코드가 올바르지 않습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                self.codeBox.text = "" // 텍스트 필드 초기화
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return print("상위값 가져오기 실패")
            
        }
    }
}


