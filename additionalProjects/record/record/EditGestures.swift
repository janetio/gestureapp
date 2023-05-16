//
//  EditGestures.swift
//  record
//
//  Created by Jane Tio on 5/15/23.
//

import SwiftUI

struct Success: View {
    var body: some View {
        Text("SUCCESS")
    }
}

struct EditGestures: View {
    
    @State var upDown = ""
    @State var wave = ""
    @State var changed = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Success(), isActive: $changed) { EmptyView() }
                Form {
                    Section {
                        TextField("UpDown", text:
                        $upDown)
                        TextField("Wave", text:
                        $wave)
                    }
                }
                Button("Save Changes", action: change)
                
            }
        }
    }
    
    func change() {
        Gestures.upDown = upDown
        Gestures.wave = wave
        self.changed = true
    }
}

