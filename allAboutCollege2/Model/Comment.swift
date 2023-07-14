//
//  Comment.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 4/10/23.
//

import Foundation

class Comment{
    let commentId: String
    let content : String
    var like: Int
    let uid: String
    var likePressed: Bool
    let diffDate: String
    let date: Date
    init(commentId:String, content:String, like:Int, uid:String,date:Date, likePressed:Bool,diffDate:String) {
        self.commentId = commentId
        self.content = content
        self.like = like
        self.uid = uid
        self.likePressed = likePressed
        self.date = date
        self.diffDate = diffDate
    }
}


