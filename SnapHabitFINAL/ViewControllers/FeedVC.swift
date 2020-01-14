//
//  FeedVC.swift
//  SnapHabitFINAL
//
//  Created by Kent Bara on 2020/01/14.
//  Copyright © 2020 Kent Bara. All rights reserved.
//

import UIKit
import Firebase
class FeedVC: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    let fireStoreDatabase = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserInfo()
    }
    func makeAlert(title: String, message: String){
           let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
           let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
           alert.addAction(okButton)
           self.present(alert, animated: true, completion: nil)
       }
    
    func getUserInfo(){
        fireStoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (snapshot, error) in
            if error != nil{
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            } else{
                if snapshot?.isEmpty == false && snapshot != nil{
                    for document in snapshot!.documents{
                        if let username = document.get("username") as? String{
                            UserSingleton.sharedUserInfo.email = Auth.auth().currentUser!.email!
                            UserSingleton.sharedUserInfo.username = username
                        }
                    }
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
