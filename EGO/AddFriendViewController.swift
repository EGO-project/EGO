import UIKit
import Firebase
import FirebaseDatabase
import KakaoSDKAuth
import KakaoSDKUser

class AddFriendViewController: UIViewController {
    let ref = Database.database().reference()
    
    struct FirebaseData {
        var friendId: String?
        var friendNickname: String?
        var myFriendCode: String?
    }
    
    var firebaseData: FirebaseData?
    
    struct KakaoData {
        var kakaoId: Int64
    }
    
    var kakaoData: KakaoData?
    
    @IBOutlet weak var codeBox: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeBox.layer.cornerRadius = 10
        addBtn.layer.cornerRadius = 5
    }
    
    @IBAction func addFriendCode(_ sender: Any) {
        guard let code = codeBox.text else {
            addFail()
            return
        }
        
        UserApi.shared.me { [weak self] user, error in
            guard let self = self, error == nil, let id = user?.id else {
                self?.addFail()
                return
            }
            
            self.kakaoData = KakaoData(kakaoId: id)
            
            self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: code).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self,
                      let friendNode = snapshot.value as? [String: Any],
                      let friendId = friendNode.keys.first,
                      let friendData = friendNode[friendId] as? [String: Any],
                      let friendNickname = friendData["nickname"] as? String else {
                    self?.addFail()
                    return
                }
                
                self.firebaseData = FirebaseData()
                self.firebaseData?.friendId = friendId
                self.firebaseData?.friendNickname = friendNickname
                
                self.ref.child("friendRequested").child(friendId).observeSingleEvent(of: .value) { [weak self] snapshot in
                    guard let self = self else { return }
                    
                    var friendCodes: [String] = []
                    if let existingFriendCodes = snapshot.value as? [String] {
                        friendCodes = existingFriendCodes
                    }
                    
                    let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !trimmedCode.isEmpty && !friendCodes.contains(trimmedCode) {
                        let friendRequestId = UUID().uuidString
                        
                        guard let myKakaoId = self.kakaoData?.kakaoId else {
                            self.addFail()
                            return
                        }
                        
                        self.ref.child("member").child("\(myKakaoId)").child("friendCode").observeSingleEvent(of: .value) { [weak self] snapshot in
                            guard let self = self, let value = snapshot.value as? String else {
                                self?.addFail()
                                return
                            }
                            
                            let friendData: [String: Any] = [
                                "frCode": value,
                                "frId": myKakaoId,
                                "frOnlyCode" : friendRequestId
                                // 다른 필드들도 추가 가능
                            ]
                            
                            self.ref.child("friendRequested").child(friendId).child(friendRequestId).setValue(friendData)
                            self.addSuccess()
                        }
                    } else {
                        self.addFail()
                    }
                }
            }
        }
    }
    
    func addSuccess() {
        let alertController = UIAlertController(title: "알림", message: "친구가 추가되었습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.codeBox.text = ""
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addFail() {
        let alertController = UIAlertController(title: "알림", message: "친구 코드가 올바르지 않습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.codeBox.text = ""
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
