
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

struct Tutorial: View {
    
    @AppStorage("tutorialShown")
    var tutorialShown: Bool = false
    
    @State private var pageIndex = 0
    @State var finishedTutorial = false
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
                            Button("Let's go!", action:{ self.finishedTutorial = true})
                                .buttonStyle(.bordered)
                                .offset(x:0, y:-70)
                        } else {
                            Button("next", action:
                                incrementPage)
                            .offset(x:0, y:-90)
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
