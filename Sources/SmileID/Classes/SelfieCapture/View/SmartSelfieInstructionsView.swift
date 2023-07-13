import SwiftUI

public struct SmartSelfieInstructionsView: View {
    @Environment(\.presentationMode) var presentationMode
    private weak var selfieCaptureDelegate: SmartSelfieResultDelegate?
    @State private var goesToDetail: Bool = false
    @State var viewModel: SelfieCaptureViewModel

    init(viewModel: SelfieCaptureViewModel, delegate: SmartSelfieResultDelegate) {
        self.selfieCaptureDelegate = delegate
        _viewModel = State(initialValue: viewModel)

    }

    public var body: some View {
        if let processingState = viewModel.processingState, processingState == .endFlow {
            let _ = DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        }
        CaptureInstructionView<SelfieCaptureView>(
            image: SmileIDResourcesHelper.InstructionsHeaderIcon,
            title: SmileIDResourcesHelper.localizedString(for: "Instructions.Header"),
            callOut: SmileIDResourcesHelper.localizedString(for: "Instructions.Callout"),
            instructions: [
                CaptureInstruction(title: SmileIDResourcesHelper.localizedString(
                    for: "Instructions.GoodLight"),
                                   instruction: SmileIDResourcesHelper.localizedString(
                                    for: "Instructions.GoodLightBody"),
                                   image: Constants.ImageName.light),
                CaptureInstruction(title: SmileIDResourcesHelper.localizedString(
                    for: "Instructions.ClearImage"),
                                   instruction: SmileIDResourcesHelper.localizedString(
                                    for: "Instructions.ClearImageBody"),
                                   image: Constants.ImageName.clearImage),
                CaptureInstruction(title: SmileIDResourcesHelper.localizedString(
                    for: "Instructions.RemoveObstructions"),
                                   instruction: SmileIDResourcesHelper.localizedString(
                                    for: "Instructions.RemoveObstructionsBody"),
                                   image: Constants.ImageName.face)
            ],
            detailView: SelfieCaptureView(
                viewModel: viewModel,
                delegate: selfieCaptureDelegate ??
                    DummyDelegate()
            )
        )
    }
}