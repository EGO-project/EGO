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
    
    
    // 친구 수락 버튼
    @IBAction func acceptBtn(_ sender: UIButton) {
        // 추가할 친구코드
        guard let code = newName.text else {
            print("친구코드 없음")
            return
        }
        print(code)
        
    }
}
        
        
        
        
    
