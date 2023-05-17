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

    @IBOutlet weak var socialTable: UITableView!
    
    @IBOutlet weak var myTopEgg: UIImageView!
    @IBOutlet weak var myTopName: UILabel!
    @IBOutlet weak var myTopCode: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socialTable.delegate = self
        socialTable.dataSource = self

        kakaoUser()
    }
    
    // 섹션 내 행 갯수 지정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let row = rowCount else {return 10}
        return row
    }
    
    // 셀 생성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! SocialTableViewCell

        if indexPath.row < friendCode.count {
            let friendCode = friendCode[indexPath.row]
            cell.friendsName.text = friendCode
            // 이 외에 다른 셀 구성 요소에 friendCode를 활용할 수 있습니다.
        }

        return cell
    }
    
    // 셀 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
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
                print("친구코드 목록 배열: \(codes)")
                
                self.friendCode = codes
                print(self.friendCode)
                
                DispatchQueue.main.async {
                    self.socialTable.reloadData()
                }
                // 친구코드 통해서 친구 이름 가져와 배열에 저장
                
            }
            }
        }
    }
    

