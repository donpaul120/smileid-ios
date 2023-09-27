import SwiftUI

struct NavigationBar: View {
    var backButtonHandler: (() -> Void)
    var body: some View {
        HStack {
            Button {
                backButtonHandler()
            } label: {
                Image(uiImage: SmileIDResourcesHelper.ArrowLeft)
            }.padding(.leading)
            Spacer()
        }.frame(height: 50)
            .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(backButtonHandler: {})
    }
}
