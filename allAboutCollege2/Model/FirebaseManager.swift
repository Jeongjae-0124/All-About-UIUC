//
//  FirebaseManager.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 3/18/23.
//

import Foundation
import Firebase
import FirebaseFirestore
class FirebaseManager: NSObject {
    
    
    let firestore :Firestore
    static let shared = FirebaseManager()
    override init(){
        self.firestore = Firestore.firestore()
    }
    
    
    
    
    
    
}
