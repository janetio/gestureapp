//
//  ContentView.swift
//  GestureApp
//
//  Created by Jane Tio on 4/20/23.
//

import SwiftUI

extension UserDefaults {
    
    var tutorialShown: Bool {
        get {
            return(UserDefaults.standard.value(forKey: "tutorialShown") as? Bool) ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "tutorialShown")
        }
    }
}

struct ContentView: View {
    
    var body: some View {
        if UserDefaults.standard.tutorialShown {
            HomeScreen()
        } else {
            Tutorial()
        }
    }
    
}

struct Tutorial: View {
    
    @AppStorage("tutorialShown")
    var tutorialShown: Bool = false
    
    @State private var pageIndex = 0
    private let pages: [Page] = Page.samplePages
    private let dotAppearance = UIPageControl.appearance()
    
    var body: some View {
        TabView(selection: $pageIndex) {
            ForEach(pages) { page in
                VStack {
                    Spacer()
                    PageView(page: page)
                    Spacer()
                    if page == pages.last {
                        Button("Let's go!", action: goToZero)
                            .buttonStyle(.bordered)
                    } else {
                        Button("next", action:
                            incrementPage)
                    }
                }
                .tag(page.tag)
            }
        }
        .animation(.easeInOut, value: pageIndex)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode:
                .interactive))
        .onAppear {
            dotAppearance.currentPageIndicatorTintColor
                = .black
            dotAppearance.pageIndicatorTintColor = .gray
        }
        .onAppear(perform: {
            UserDefaults.standard.tutorialShown = true
        })
    }
    
    func incrementPage() {
        pageIndex += 1
    }
        
    func goToZero() {
        pageIndex = 0
    }
}

struct HomeScreen: View {
    
    var body: some View {
        Text("hello")
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
