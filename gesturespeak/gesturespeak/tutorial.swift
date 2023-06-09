
import SwiftUI
import AVKit

struct Tutorial: View {
    
    @State private var pageIndex = 0
    private let pages: [Page] = Page.samplePages
    private let dotAppearance = UIPageControl.appearance()
    
    
    var body: some View {
            TabView(selection: $pageIndex) {
                ForEach(pages) { page in
                    VStack {
                        Spacer()
                        PageView(page: page)
                        Group{
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        if page == pages.last {
                            Button("Back to Start", action:
                                    goToZero)
                            .buttonStyle(.bordered)
                            .offset(x:0, y:-70)
                        } else {
                            Group {
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                            }
                            Button("next", action:
                                    incrementPage)
                            .offset(x:0, y:-90)
                        }
                        Spacer()
                    }
                    .tag(page.tag)
                }
            }
            .animation(.easeInOut, value: pageIndex)
            .tabViewStyle(.page)
            .onAppear {
                dotAppearance.currentPageIndicatorTintColor
                = .black
                dotAppearance.pageIndicatorTintColor = .gray
            }
    }
    
    func incrementPage() {
        pageIndex += 1
    }
        
    func goToZero() {
        pageIndex = 0
    }
}
