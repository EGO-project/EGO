import UIKit
import Firebase
import FirebaseDatabase

class AddSocialTableViewCell: UITableViewCell {
    
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var newName: UILabel!
    
    // Firebase reference
    let ref = Database.database().reference()
    
    // Firebase data structure
    struct FirebaseData {
        var friendId: String?
        var friendNickname: String?
    }
    
    // Firebase data struct member variable
    var firebaseData: FirebaseData?
    
    // Accept button action closure
    var acceptButtonAction: (() -> Void)?
    
    var refreshTableView: (() -> Void)?
    
    @IBAction func acceptBtn(_ sender: UIButton) {
        // Friend code to be added
        guard let code = newName.text else {
            print("Friend code not found")
            return
        }
        print("New friend code: \(code)")
        
        let userCode = self.ref.child("member").child(Auth.auth().currentUser!.uid).child("friendCode").description()
        
        // Retrieve friend's friend code using their name: querying child values
        self.ref.child("member").queryOrdered(byChild: "friendCode").queryEqual(toValue: "\(code)").observeSingleEvent(of: .value) { snapshot in
            guard let friendNode = snapshot.value as? [String: Any],
                  let friendId = friendNode.keys.first,
                  let friendData = friendNode[friendId] as? [String: Any],
                  let friendcode = friendData["friendCode"] as? String else {
                // Show failure alert for friend addition
                print("Failed to retrieve friend's friend code")
                return
            }
            
            self.firebaseData = FirebaseData()
            self.firebaseData?.friendId = friendId
            self.firebaseData?.friendNickname = friendcode
            
            // Add friend code to Firebase
            guard let friendId = self.firebaseData?.friendId else {
                print("Friend ID is nil")
                return
            }
            
            guard let userId = Auth.auth().currentUser?.uid else {
                // User is not logged in
                print("User is not logged in.")
                return
            }
            self.ref.child("friend").child(userId).child("\(friendId)").setValue([
               "favoriteState": "0",
               "code": friendcode,
               "publicState": "0",
               "state": "0"
           ])
            
            // Add user to friend's friend list
            self.ref.child("friend").child(friendId).child("\(userId)").setValue([
               "favoriteState": "0",
               "code": userCode,
               "publicState": "0",
               "state": "0"
           ])
            
            // Show friend added alert
            self.showFriendAddedAlert()
            
            // Remove added friend from Firebase
            self.firebaseUpdate()
            
            // Refresh the table view
            self.refreshTableView?()
        }
    }
    
    private func showFriendAddedAlert() {
        let alertController = UIAlertController(title: "Friend Added", message: "The friend has been added.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.acceptButtonAction?()
        }
        
        alertController.addAction(okAction)
        
        guard let viewController = self.parentViewController() else {
            print("Could not find the view controller to display the alert.")
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
    
    // Function to remove the added friend data from Firebase
    func firebaseUpdate() {
        // Friend code to be removed
        guard let code = newName.text else {
            print("Friend code not found")
            return
        }
        print("Friend code to be removed: \(code)")
        
        // Retrieve friend's unique friend code using the friend code: querying child values
        self.ref.child("friendRequested").queryOrdered(byChild: "frCode").queryEqual(toValue: "\(code)").observeSingleEvent(of: .value) { snapshot in
            
            snapshot.ref.removeValue() { error, _ in
                if let error = error {
                    print("Failed to remove data: \(error.localizedDescription)")
                } else {
                    print("Data removed successfully")
                    self.refreshTableView?()
                }
            }
        }
    }
}
