import UIKit
import Firebase
import FirebaseDatabase

class AddFriendViewController: UIViewController {
    let ref = Database.database().reference()
    
    struct FirebaseData {
        var friendId: String?
        var friendNickname: String?
        var myFriendCode: String?
    }
    
    var firebaseData: FirebaseData?
    
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
        
        guard let currentUser = Auth.auth().currentUser else {
            addFail()
            return
        }
        
        let myUserId = currentUser.uid
        
        self.ref.child("member").child(myUserId).child("friendCode").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let myUserCode = snapshot.value as? String else {
                self?.addFail()
                return
            }
            
            self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: code).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self,
                      let friendNode = snapshot.value as? [String: Any],
                      let friendId = friendNode.keys.first,
                      let friendData = friendNode[friendId] as? [String: Any],
                      let friendNickname = friendData["nickname"] as? String else {
                    self?.addFail()
                    return
                }
                
                // Check if friend is already added
                self.ref.child("friend").child(myUserId).observeSingleEvent(of: .value) { snapshot in
                    print(myUserId)
                    print(friendId)
                    print(snapshot)
                    
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        if snap.key == friendId {
                            self.friendAlreadyAdded()
                            return
                        }
                    
                        
                    }
                    
                    // Continue with friend request
                    self.firebaseData = FirebaseData()
                    self.firebaseData?.friendId = friendId
                    self.firebaseData?.friendNickname = friendNickname
                    
                    self.ref.child("friendRequested").child(friendId).observeSingleEvent(of: .value) { [weak self] snapshot, _ in
                        guard let self = self else { return }
                        
                        var friendRequestData: [String: Any] = [:]
                        if let existingFriendRequestData = snapshot.value as? [String: Any] {
                            friendRequestData = existingFriendRequestData
                        }
                        
                        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !trimmedCode.isEmpty && friendRequestData[myUserId] == nil {
                            let friendRequestId = UUID().uuidString
                            
                            friendRequestData[friendRequestId] = [
                                "frCode": myUserCode,
                                "frId": myUserId,
                                "frOnlyCode": friendRequestId
                                // 다른 필드들도 추가 가능
                            ]
                            
                            self.ref.child("friendRequested").child(friendId).setValue(friendRequestData)
                            self.addSuccess()
                        } else {
                            self.addFail()
                        }
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
    
    func friendAlreadyAdded() {
        let alertController = UIAlertController(title: "알림", message: "이미 친구로 추가된 사용자입니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.codeBox.text = ""
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}
