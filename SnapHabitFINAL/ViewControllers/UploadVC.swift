//
//  UploadVC.swift
//  SnapHabitFINAL
//
//  Created by Kent Bara on 2020/01/14.
//  Copyright © 2020 Kent Bara. All rights reserved.
//

import UIKit
import Firebase
class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uploadImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        uploadImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture))
        uploadImageView.addGestureRecognizer(gestureRecognizer)
        
    }
    @objc func choosePicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        uploadImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    func makeAlert(title: String, message: String){
           let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
           let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
           alert.addAction(okButton)
           self.present(alert, animated: true, completion: nil)
       }
    
    @IBAction func uploadClicked(_ sender: Any) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5){
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                if error != nil{
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }else {
                    imageReference.downloadURL { (url, error) in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            let fireStore = Firestore.firestore()
                            fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { (snapshot, error) in
                                if error != nil{
                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                }else{
                                    if snapshot?.isEmpty == false && snapshot != nil{
                                        for document in snapshot!.documents{
                                            let documentID = document.documentID
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String]{
                                                imageUrlArray.append(imageUrl!)
                                                
                                                let additionalDictionary = ["imageUrlArray" : imageUrlArray] as [String : Any]
                                                fireStore.collection("Snaps").document(documentID).setData(additionalDictionary, merge: true) { (error) in
                                                    if error == nil {
                                                        self.tabBarController?.selectedIndex = 0
                                                        self.uploadImageView.image = UIImage(named: "untitled (3).png")
                                                    }
                                                }
                                            }
                                        }
                                    }else{
                                        let snapDictionary = ["imageUrlArray" : [imageUrl!], "snapOwner" : UserSingleton.sharedUserInfo.username, "date" : FieldValue.serverTimestamp()] as [String : Any]
                                        fireStore.collection("Snaps").addDocument(data: snapDictionary) { (error) in
                                            if error != nil {
                                                
                                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                            }else{
                                                self.tabBarController?.selectedIndex = 0
                                                self.uploadImageView.image = UIImage(named: "untitled (3).png")
                                            }
                                    }
                                }
                            }
                        
                            }
                        }
                    }
                }
            }
        }
    }
    

}
