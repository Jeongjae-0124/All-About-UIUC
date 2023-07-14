//
//  MyComment.swift
//  allAboutCollege2
//
//  Created by Jeongjae Park on 6/7/23.
//

import Foundation


class MyComment{
    let selectedPost:Post
    let commmentTextTitle:String
    let commentContent:String
    let commentId: String
    init(selectedPost:Post, commmentTextTitle:String, commentContent:String, commentId:String) {
        self.selectedPost = selectedPost
        self.commmentTextTitle = commmentTextTitle
        self.commentContent = commentContent
        self.commentId = commentId
   
    }
}
