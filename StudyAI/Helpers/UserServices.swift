//
//  UserServices.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/16/23.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

let UserService = _UserService()


protocol reloadUserDelegate{
    func reload()
}

final class _UserService {
    //variables
    var user = User()
    let auth = Auth.auth()
    let db = Firestore.firestore()
    var userListener : ListenerRegistration? = nil
    let myGroup = DispatchGroup()
    var currentUser = Auth.auth().currentUser
    
    var delegate: reloadUserDelegate?

    
    func getCurrentUser(){
        guard let authUser = auth.currentUser else {return}
                
        let userRef = db.collection("users").document(authUser.uid)
        let indicator = Indicator()
        indicator.showIndicator()
        userListener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                indicator.hideIndicator(completion: nil)
                return
            }
            indicator.hideIndicator(completion: nil)
            guard let data = snap?.data() else {return}
            self.user = User.init(data: data)
            self.currentUser = authUser
            
            if !self.user.isVerifiable {
                authUser.reload { error in
                    if let error = error {
                        print("error here?????")
                        self.delegate?.reload()
                    }
                    else {
                        print("error here?")
                        self.delegate?.reload()
                    }
                }
            }
            else {
                self.delegate?.reload()
            }
            
        })
    }
    
    
    func showImageView() {

    }
    
    func getCurrentUserSetRoot(x: CGFloat, y:CGFloat){
        let image = UIImageView(frame: CGRect(x:x, y: y, width: 250, height: 250))
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemChromeMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        image.image = UIImage(named: "appicon")
        print("do i even enter")
        if let keyWindow = UIWindow.key  {
            blurEffectView.frame = keyWindow.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            keyWindow.addSubview(blurEffectView)
            keyWindow.addSubview(image)

        }
        
        let group = DispatchGroup()
        let indicator = Indicator()
        group.enter()
        indicator.showIndicator()
                        
        guard let authUser = auth.currentUser else {
            indicator.hideIndicator {
                blurEffectView.removeFromSuperview()
                group.leave()
            }
            
            return
        }
        let userRef = db.collection("users").document(authUser.uid)

        showImageView()
        print("begining")

        userListener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error {

                
                return
            }
            guard let data = snap?.data() else {
                group.leave()
                return
            }
            self.user = User.init(data: data)
            if !self.user.isVerifiable {
                print("am i here")
                authUser.reload { error in
                    if let error = error {
                        group.leave()
                        print("error here?")

                    }
                    else {
                        group.leave()
                        print("error here?")
                    }
                }
            }
            else {
                print("here")
                group.leave()
            }
        })
        
        group.notify(queue: .main){
            self.userListener?.remove()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                //image.removeFromSuperview()
                blurEffectView.removeFromSuperview()
                if self.user.id != "" {
                    print("I entered here")
                    let story = UIStoryboard(name: "Main", bundle:nil)
                    let vc = story.instantiateViewController(withIdentifier: "MainVC")
                    indicator.hideIndicator(completion: nil)
                    UIApplication.shared.windows.first?.rootViewController = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
                else {
                    indicator.hideIndicator(completion: nil)
                }
            }
        }
    }
}

