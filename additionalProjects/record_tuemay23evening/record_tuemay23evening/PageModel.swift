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
    var videoUrl: String
    var tag: Int
    
    
    static var samplePage = Page(name: "Title Example", description: "example", imageUrl: "first", videoUrl: "", tag: 0)
    
    static var samplePages: [Page] = [
    Page(name: "Welcome to Gesture Signaller. This app will allow you to transform gestures into words.", description: "", imageUrl: "first", videoUrl: "",tag: 0),
    Page(name: "To perform gestures, please press the 'Hold during gesture' button when performing gesture and stop after gesture is done.", description: "", imageUrl: "sec", videoUrl: "",tag: 1),
    Page(name: "After performing gesture, corresponding sound will be made.", description: "There are 2 preprogrammed gestures (wave/updown). Any unrecognized gestures will be classified 'Other'. Each preprogrammed gesture will say what they are three times eg. wave wave wave for a wave.", imageUrl: "third", videoUrl: "",tag: 2),
    Page(name: "Wave Demo", description: "Please press on center of video to play", imageUrl: "", videoUrl: "wave",tag: 3),
    Page(name: "UpDown Demo", description: "Please press on center of video to play", imageUrl: "", videoUrl: "updown",tag: 4),
    Page(name: "Editing Gestures", description: "To edit gestures, please press edit gestures button on home page, enter new sound to be made, and press save changes.", imageUrl: "four", videoUrl: "punch",tag: 5),
    ]
}
