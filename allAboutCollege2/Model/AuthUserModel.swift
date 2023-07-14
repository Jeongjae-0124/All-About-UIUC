//
//  UserModel.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 3/19/23.
//

import Foundation
import Firebase
import FirebaseAuth
class AuthUserModel:ObservableObject{
    
    @Published var userSession:FirebaseAuth.User?
    @Published var appUser:AppUser?
    init() {
        userSession = Auth.auth().currentUser
        fetchInitialUser()
    }

    func fetchInitialUser(){
        guard let uid = self.userSession?.uid else {return }
        Firestore.firestore().collection("users").document(uid ?? "").getDocument { snapshot, _ in
            guard let dictionary = snapshot?.data() else{ return }
            guard let username = dictionary["username"] as? String else{ return}
            guard let email = dictionary["email"] as? String else { return }
            self.appUser = AppUser(uid: uid, email: email, username: username)
        }
    }
    
}
