import SwiftUI
import SmileID
struct MainView: View {

    init() {
        UITabBar.appearance().barTintColor = offWhiteUIColor
        if #available(iOS 14.0, *) {
            UITabBar.appearance().tintColor = UIColor(SmileID.theme.accent)
        } else {
            // Fallback on earlier versions
            UITabBar.appearance().tintColor = .blue
        }
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "Georgia-Bold", size: 30)!]
    }

    var body: some View {

        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .edgesIgnoringSafeArea(.all)

//            AboutUsView()
//                .tabItem {
//                    Image(systemName: "info.circle")
//                    Text("Resources")
//                }

//            AboutUsView()
//                .tabItem {
//                    Image(systemName: "gearshape.fill")
//                    Text("About us")
//                }
        }
        .background(offWhite.edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.light)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}