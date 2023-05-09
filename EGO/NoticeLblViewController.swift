import UIKit
import Firebase
import FirebaseCore

class NoticeLblViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    @IBOutlet weak var notceLbl: UILabel!
    
    let ref = Database.database().reference()
    var announcementKey: String?

    func fetchData() {
        if let key = announcementKey {
            ref.child("announcement/\(key)").observeSingleEvent(of: .value, with: { snapshot in
                if let description = snapshot.childSnapshot(forPath: "description").value as? String {
                    self.notceLbl.text = description
                }
            }) { error in
                print(error.localizedDescription)
            }
        }
    }

    }
