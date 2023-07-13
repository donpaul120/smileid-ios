import Foundation
import AVFoundation
import SwiftUI

protocol CameraManageable: AnyObject {
    func switchCamera(to position: AVCaptureDevice.Position)
    func pauseSession()
    func resumeSession()
    var sampleBufferPublisher: Published<CVPixelBuffer?>.Publisher {get}
    var session: AVCaptureSession { get }
    var cameraPositon: AVCaptureDevice.Position? {get}
}

class CameraManager: NSObject, ObservableObject, CameraManageable {

    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }

    @Published var error: CameraError?
    @Environment(\.isPreview) var isPreview
    @Published var sampleBuffer: CVPixelBuffer?
    var sampleBufferPublisher: Published<CVPixelBuffer?>.Publisher { $sampleBuffer }
    let videoOutputQueue = DispatchQueue(label: "com.smileid.videooutput",
                                         qos: .userInitiated,
                                         attributes: [],
                                         autoreleaseFrequency: .workItem)

    var session = AVCaptureSession()
    var cameraPositon: AVCaptureDevice.Position? {
        if let currentInput = self.session.inputs.first as? AVCaptureDeviceInput {
            return currentInput.device.position
        }
        return nil
    }

    private let sessionQueue = DispatchQueue(label: "com.smileid.ios")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var status = Status.unconfigured

    override init() {
        super.init()
        set(self, queue: videoOutputQueue)
    }

    private func set(error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }

    private func set(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
                     queue: DispatchQueue) {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }

    private func checkPermissions() {
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .notDetermined:
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { authorized in
          if !authorized {
            self.status = .unauthorized
            self.set(error: .deniedAuthorization)
          }
          self.sessionQueue.resume()
        }
      case .restricted:
        status = .unauthorized
        set(error: .restrictedAuthorization)
      case .denied:
        status = .unauthorized
        set(error: .deniedAuthorization)
      case .authorized:
        break
      @unknown default:
        status = .unauthorized
        set(error: .unknownAuthorization)
      }
    }

    private func configureCaptureSession() {
        guard status == .unconfigured else {
            return
        }
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }

        addCameraInput(position: .front)
        configureVideoOutput()
    }

    private func addCameraInput(position: AVCaptureDevice.Position) {
        guard let camera = getCameraForPosition(position) else {
            set(error: .cameraUnavailable)
            status = .failed
            return
        }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                set(error: .cannotAddInput)
                status = .failed
            }
        } catch {
            set(error: .createCaptureInput(error))
            status = .failed
        }
    }

    private func getCameraForPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        switch position {
        case .front:
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        case .back:
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        default:
            return nil
        }
    }

    private func configureVideoOutput() {
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

            let videoConnection = videoOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
            videoConnection?.isVideoMirrored = true
        } else {
            set(error: .cannotAddOutput)
            status = .failed
        }
    }

    func switchCamera(to position: AVCaptureDevice.Position) {
        self.checkPermissions()
        sessionQueue.async { [self] in
            if !self.session.isRunning {
                self.session.startRunning()
            }
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            if let currentInput = self.session.inputs.first as? AVCaptureDeviceInput {
                self.session.removeInput(currentInput)
            }
            self.configureVideoOutput()
            self.addCameraInput(position: position)
        }
    }

    func pauseSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }

    func resumeSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        if let buffer = sampleBuffer.imageBuffer {
            self.sampleBuffer = buffer
        }
    }
}
