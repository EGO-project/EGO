import Foundation
import UIKit
class SetSecondPasswordViewController: UIViewController {

    @IBOutlet var blanks: [UIImageView]!
    var passwordEntry: [Int] = []
    var firstPasswordInput: [Int]?
    @IBOutlet weak var lblCheck: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBlanks()
    }
    
    @IBAction func numberButtonPressed(_ sender: UIButton) {
        guard let number = sender.titleLabel?.text, let num = Int(number) else { return }
        
        if passwordEntry.count < 4 {
            passwordEntry.append(num)
            updateBlanks()
        }
        
        if passwordEntry.count == 4 {
            if firstPasswordInput == nil {
                firstPasswordInput = passwordEntry
                passwordEntry.removeAll()
                updateBlanks()
                // 첫 번째 입력이 끝났으니 사용자에게 다시 한 번 입력하라는 메시지를 표시합니다.
                lblCheck.text = "다시 한 번 입력해주세요."
            } else {
                if firstPasswordInput == passwordEntry {
                    // 비밀번호가 일치하면 UserDefaults에 저장합니다.
                    let passwordString = passwordEntry.map { String($0) }.joined()
                    UserDefaults.standard.set(passwordString, forKey: "SecondPassword")
                    dismiss(animated: true, completion: nil)
                } else {
                    // 비밀번호가 일치하지 않으면 경고 메시지를 표시하고 처음부터 다시 입력합니다.
                    lblCheck.text = "비밀번호가 일치하지 않습니다. 다시 입력해주세요."
                    firstPasswordInput = nil
                    passwordEntry.removeAll()
                    updateBlanks()
                }
            }
        }
    }
    
    func updateBlanks() {
        for (index, blank) in blanks.enumerated() {
            if index < passwordEntry.count {
                blank.image = UIImage(named: "filledImage") // '*'로 채워진 이미지
            } else {
                blank.image = UIImage(named: "Ellipse 8")  // 빈 이미지
            }
        }
    }

    @IBAction func backspacePressed(_ sender: Any) {
        if !passwordEntry.isEmpty {
            passwordEntry.removeLast()
            updateBlanks()
        }
    }
}
