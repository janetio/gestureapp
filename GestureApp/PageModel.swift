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
    
    static var samplePage = Page(name: "Title Example", description: "example", imageUrl: "first", tag: 0)
    
    static var samplePages: [Page] = [
    Page(name: "Welcome to Gesture Signaller. This app will allow you to transform gestures into words.", description: "", imageUrl: "first", tag: 0),
    Page(name: "To perform gestures, please press the record button when running while performing the gesture.", description: "", imageUrl: "sec", tag: 1),
    Page(name: "After performing gesture, corresponding sound will be made.", description: "", imageUrl: "third", tag: 2)
    ]
}
