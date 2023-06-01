import SwiftUI
import SmileID

struct HomeView: View {
    var userID = ""
    @ObservedObject var viewModel: HomeViewModel
    init() {
        viewModel = HomeViewModel()
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Test Our Products")
                    .font(SmileID.theme.header2)
                HStack(spacing: 15) {
                    Button(action: {self.viewModel.handleSmartSelfieEnrolmentTap()}) {
                        ProductCell(productImage: "userauth", productName: "SmartSelfie™ \nEnrolment")
                    }

                    .sheet(isPresented: $viewModel.presentSmartSelfieAuth, content: {SmileID.smartSelfieRegistrationScreen(userId: "", delegate: viewModel)})
                    Button(action: {self.viewModel.handleSmartSelfieAuthTap()}) {
                        ProductCell(productImage: "userauth", productName: "SmartSelfie™ \nAuthentication")
                    }
                    .sheet(isPresented: $viewModel.presentSmartSelfieAuth, content: {SmileID.smartSelfieRegistrationScreen(userId: "", delegate: viewModel)})
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle(Text("Smile ID").font(SmileID.theme.header1), displayMode: .inline)
            .background(offWhite.edgesIgnoringSafeArea(.all))
        }
    }

    mutating func generateUUID() {
        self.userID = UUID().uuidString
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct NavigationBarModifier: ViewModifier {

    var backgroundColor: Color = .clear

    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .clear
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .white

    }

    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    self.backgroundColor
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {

    func navigationBarColor(_ backgroundColor: Color) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }

}
