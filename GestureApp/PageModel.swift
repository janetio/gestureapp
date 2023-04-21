//
//  PageModel.swift
//  GestureApp
//
//  Created by Jane Tio on 4/21/23.
//

import Foundation

struct Page: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var description: String
    var imageUrl: String
    var tag: Int
    
    static var samplePage = Page(name: "Title Exzmple", description: "example meow", imageUrl: "first", tag: 0)
    
    static var samplePages: [Page] = [
    Page(name: "welcome", description: "best app", imageUrl: "first", tag: 0),
    Page(name: "welcome", description: "sec", imageUrl: "sec", tag: 1),
    Page(name: "welcome", description: "third app", imageUrl: "third", tag: 2)
    ]
}
