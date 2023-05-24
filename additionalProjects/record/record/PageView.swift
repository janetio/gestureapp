//
//  PageView.swift
//  GestureApp
//
//  Created by Jane Tio on 4/21/23.
//

import SwiftUI
import AVKit
import AVFoundation

struct PageView: View {
    var page: Page
    @State var wave = AVPlayer(url:  Bundle.main.url(forResource: "wave", withExtension: "mov")!)
    @State var updown = AVPlayer(url:  Bundle.main.url(forResource: "updown", withExtension: "mov")!)
    var body: some View {
        VStack(spacing: 20) {
            if page.tag <= 2 || page.tag == 5  {
                Image("\(page.imageUrl)")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .cornerRadius(30)
                    .cornerRadius(10)
                    .padding()
            }
            if page.tag == 3 {
                VideoPlayer(player: wave)
            }
            if page.tag == 4 {
                VideoPlayer(player: updown)
            }
            Spacer()
            Spacer()
            Text(page.name)
                .font(.title)
            Spacer()
            
            Text(page.description)
                .font(.subheadline)
                .frame(width: 300)
            Spacer()
        }
    }
    
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(page: Page.samplePage)
    }
}
