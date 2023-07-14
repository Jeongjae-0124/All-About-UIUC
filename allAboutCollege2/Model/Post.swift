//
//  Post.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 4/3/23.
//

import Foundation

class Post{
    let bodyText: String
    var like :Int
    let titleText: String
    let image: String
    let boardType: String
    let postId: String
    var likePressed: Bool = false
    let date: Date
    let uid:String
    let diffDate: String
    init(bodyText: String, like: Int, titleText: String, image: String, boardType: String, postId: String, likePressed: Bool, date:Date, uid:String, diffDate:String) {
        self.bodyText = bodyText
        self.like = like
        self.titleText = titleText
        self.image = image
        self.boardType = boardType
        self.postId = postId
        self.likePressed = likePressed
        self.date = date
        self.diffDate = diffDate
        self.uid = uid
    }
    
}

