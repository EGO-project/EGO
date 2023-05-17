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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 친구코드 친구 추가 버튼
    @IBAction func addFriendCode(_ sender: Any) {
        
        // 1번 기능 : friend > 현재 사용자 id > @00000 추가
        var friendCode: String = "" // 친구의 친구코드 저장할 프로퍼티

        guard let code = codeBox.text else { print("친구코드 없음"); return }
        friendCode = code // 추가할 친구코드
        
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
        
        // 2번 기능 : friend > 현재 사용자 id > memberId : 23dfjkeaowef 추가
        // 하윗값으로 상윗값 가져오기 : 친구 이름 알아내서
        self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: "\(friendCode)").observeSingleEvent(of: .value) { snapshot in
            guard let friendNode = snapshot.value as? [String: Any],
                  let friendId = friendNode.keys.first,
                  let friendData = friendNode[friendId] as? [String: Any],
                  let friendnickname = friendData["nickname"] as? String else { return print("상위값 가져오기 실패")}
            self.firebaseData = FirebaseData()
            self.firebaseData?.friendId = friendId
            self.firebaseData?.friendNickname = friendnickname
            print("Friend Node: \(friendNode)")
            print("Friend ID: \(friendId)")
            print("Friend Nickname: \(friendnickname)")
        }
        
        // 파이어베이스에 친구코드 추가
        guard let mykakaoId = kakaoData?.kakaoId,
              let friendkakaoId = firebaseData?.friendId
        else {return}
        self.ref.child("friend").child("\(mykakaoId)").child("\(friendCode)").child("favoriteState").setValue("빔");
        self.ref.child("friend").child("\(mykakaoId)").child("\(friendCode)").child("publicState").setValue("빔");
        self.ref.child("friend").child("\(mykakaoId)").child("\(friendCode)").child("state").setValue("빔");
        self.ref.child("friend").child("\(mykakaoId)").child("\(friendCode)").child("memberId").setValue(friendkakaoId)
        { (error, reference) in
            guard error == nil else { return }
        }

    }

}
