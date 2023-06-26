import UIKit
import Firebase
import FirebaseDatabase
import KakaoSDKAuth
import KakaoSDKUser


class AddSocialTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var newName: UILabel!
    
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
    
    // 현재 사용자 카카오톡 id가져오기
    func kakaoUser() {
        UserApi.shared.me { user, error in
            guard error == nil else {
                print("카카오톡 정보 가져오지 못함")
                print(error!)
                return
            }
            guard let id = user?.id else {
                print("사용자 카카오톡 id 없음")
                return
            }
            
            // 구조체 KakaoData에 사용자 카카오톡 id 저장
            self.kakaoData = KakaoData(kakaoId: id)
            print("사용자 카카오톡 id: \(self.kakaoData?.kakaoId ?? 0)")
        }
    }
    
    
    
    
    
    
    // 새로운 친구리스트의 친구 수락 버튼
    var acceptButtonAction: (() -> Void)?
    
    @IBAction func acceptBtn(_ sender: UIButton) {
        // 사용자 카카오 데이터 가져오기
        self.kakaoUser()
        
        // 추가할 친구 코드
        guard let code = newName.text else {
            print("친구코드 없음")
            return
        }
        print("새로운 친구 코드: \(code)")
        
        // 친구 이름으로 친구의 친구 코드 알아오기 : 하위값으로 상윗값 가져오기
        self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: "\(code)").observeSingleEvent(of: .value) { snapshot in
            guard let friendNode = snapshot.value as? [String: Any],
                  let friendId = friendNode.keys.first,
                  let friendData = friendNode[friendId] as? [String: Any],
                  let friendcode = friendData["friendCode"] as? String else {
                // 친구 추가 실패 경고창
                print("상윗값 가져오기 실패")
                return
            }
            
            self.firebaseData = FirebaseData()
            self.firebaseData?.friendId = friendId
            self.firebaseData?.friendNickname = friendcode
            
            // 파이어베이스에 친구코드 추가
            guard let mykakaoId = self.kakaoData?.kakaoId,
                  let friendkakaoId = self.firebaseData?.friendId else {
                print("카카오 데이터 또는 Firebase 데이터가 nil입니다.")
                return
            }
            self.ref.child("friend").child("\(mykakaoId)").child("\(code)").setValue([
                "favoriteState": "빔",
                "memberId": friendkakaoId,
                "publicState": "빔",
                "state": "빔"
            ])
            
            // 친구 추가 완료 처리
            self.showFriendAddedAlert()
            
            // 추가된 친구 파이어베이스에서 삭제
            self.firebaseUpdate()

        }
    }
    
    private func showFriendAddedAlert() {
        let alertController = UIAlertController(title: "친구 추가 완료", message: "친구가 추가되었습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.acceptButtonAction?()
        }
        
        alertController.addAction(okAction)
        
        guard let viewController = self.parentViewController() else {
            print("경고창을 표시할 뷰 컨트롤러를 찾을 수 없습니다.")
            return
        }
        
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            parentResponder = responder.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    // 추가된 친구 데이테 파이어베이스에서 삭제 함수
    func firebaseUpdate() {
        kakaoUser()
        guard let id = kakaoData?.kakaoId else { print("카카오 id값을 가져오는데 실패하였습니다."); return }
        
        // 삭제할 친구 코드
        guard let code = newName.text else { print("친구코드 없음"); return }
        print("삭제될 친구 코드: \(code)")
        
        // 친구 코드로 친구의 친구고유코드 알아오기 : 하위값으로 상윗값 가져오기
        self.ref.child("friendRequested").child("\(id)").queryOrdered(byChild: "frCode").queryEqual(toValue: "\(code)").observeSingleEvent(of: .value) { snapshot in
            guard let friendNode = snapshot.value as? [String: Any],
                  let friendId = friendNode.keys.first,
                  let friendData = friendNode[friendId] as? [String: Any],
                  let friendOnlycode = friendData["frOnlyCode"] as? String else { print("상윗값 가져오기 실패"); return } // 친구 추가 실패 경고창
            
            self.ref.child("friendRequested").child("\(id)").child("\(friendOnlycode)").removeValue(){ error, _ in
                guard error != nil else {
                    print("데이터 삭제 실패: \(String(describing: error?.localizedDescription))")
                    return
                }
                print("데이터 삭제 성공")
            }
            
        }
    }
}
