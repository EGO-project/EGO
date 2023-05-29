import UIKit
import Firebase
import FirebaseDatabase

class MoreViewController: UIViewController {
    
    let ref = Database.database().reference()
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileCode: UILabel!
    @IBOutlet weak var logOut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myNameFB()
        myCodeFB()
        
        // 파이어베이스 데이터 변경 감지
        observeFirebaseChanges()
    }
    
    func observeFirebaseChanges() {
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        
        // "member" 경로의 변경 사항을 감시하고 실시간으로 업데이트된 데이터를 받아옴
        self.ref.child("member").child(safeEmail).observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let value = snapshot.value as? [String: Any] {
                // nickname 값이 변경되었을 경우 Label에 업데이트
                if let nickname = value["nickname"] as? String {
                    DispatchQueue.main.async {
                        self.profileName.text = nickname
                    }
                }
                
                // friendCode 값이 변경되었을 경우 Label에 업데이트
                if let friendCode = value["friendCode"] as? String {
                    DispatchQueue.main.async {
                        self.profileCode.text = friendCode
                    }
                }
            }
        }
    }
    
    // 기존 코드와 동일하게 구현
    func myNameFB() {
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        self.ref.child("member").child(safeEmail).child("nickname").observeSingleEvent(of: .value) { [weak self] snapshot  in
            guard let self = self else { return }
            
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.profileName.text = value
            }
        }
    }
    
    // 기존 코드와 동일하게 구현
    func myCodeFB() {
        let safeEmail = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "-")
        self.ref.child("member").child(safeEmail).child("friendCode").observeSingleEvent(of: .value) { [weak self] snapshot  in
            guard let self = self else { return }
            
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.profileCode.text = value
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController: ProfileViewController = segue.destination as? ProfileViewController else {return}
        nextViewController.pNameLbl = profileName?.text
        nextViewController.pCodeLbl = profileCode.text
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.presentingViewController?.dismiss(animated: true){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "Login")
                self.present(loginVC, animated: true, completion: nil)
            }
        
        } catch let error {
            print("로그아웃 에러", error)
        }
    }
}
