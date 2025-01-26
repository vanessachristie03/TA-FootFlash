import SwiftUI
import AVFoundation
import WatchConnectivity

class PredictionViewModel: ObservableObject {
    @Published var currentFrame: UIImage?
    @Published var predicted: String = ""
    @Published var confidence: String = ""
    @Published var savedPrediction: String = ""
    @Published var isCentered: Bool = false {
        didSet {
            sendCalibrationStatusToWatch()
        }
    }
    @Published var calibrationMessage: String = ""
    
    var videoCapture: VideoCapture!
    var videoProcessingChain: VideoProcessingChain!
    var actionFrameCounts = [String: Int]()
    
    var fullVideoWriter: VideoWriter?
    var videoWriters = [VideoWriter?]()
    var currentVideoWriter: VideoWriter?
    var currentLabel: String = ""
    var isRecording: Bool = false
    
    init() {
        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.delegate = self
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        
        // Ensure WatchSessionManager is initialized
        _ = WatchSessionManager.shared
    }
    
    func updateUILabels(with prediction: ActionPrediction) {
        DispatchQueue.main.async {
            self.predicted = prediction.label
            self.confidence = prediction.confidenceString ?? "Observing..."
            self.manageVideoWriter(for: prediction.label)
        }
    }
    
    func savePrediction() {
        savedPrediction = predicted
    }
    
    func sendPredictionToWatch() {
        if WCSession.default.isReachable {
            let message = ["predicted": predicted]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending message to Watch: \(error.localizedDescription)")
            })
        }
    }
    
    func getSavedVideoURLs() -> [URL] {
        var videos = videoWriters.compactMap { $0?.outputURL }
        
        guard let fullVideoURL = fullVideoWriter else { return videos }
        videos.append(fullVideoURL.outputURL)
        
        return videos
    }
    
    private func manageVideoWriter(for label: String = "") {
        if (label != currentLabel && isRecording) || (currentLabel == "" && label == "salah" && isRecording) {
            currentLabel = label
            
            // end current video recording
            currentVideoWriter?.finishWriting {
                print("Finished writing video for \(self.currentLabel)")
            }
            
//            print("frame count :\(currentVideoWriter?.frameCount)")
            
            // discard recorded video duration is less than 1s
            if currentVideoWriter?.frameCount ?? 0 >= 30 && !videoWriters.compactMap({ $0?.outputURL }).contains(currentVideoWriter?.outputURL) {
                print("video not discarded")
                videoWriters.append(currentVideoWriter)
            }
            
            // record new video
            if label == "salah" {
                let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Mistakes_\(Date().timeIntervalSince1970).mov")
                let clippedVideo = VideoWriter(outputURL: outputURL, frameSize: CGSize(width: 1280, height: 720))
                clippedVideo?.startWriting()
                currentVideoWriter = clippedVideo
            }
        }
    }
    
    func startRecording() {
        isRecording = true
        
        // start full exercise recording
        fullVideoWriter = VideoWriter(outputURL:  getDocumentsDirectory().appendingPathComponent("full_\(Date().timeIntervalSince1970).mov"), frameSize: CGSize(width: 1280, height: 720))
        fullVideoWriter?.startWriting()
        
        manageVideoWriter()
    }
    
    func stopRecording() async -> Exercise{
        isRecording = false
        
        // finish all recording
        fullVideoWriter?.finishWriting {
            print("Finalized full video recording at \(String(describing: self.fullVideoWriter?.outputURL.lastPathComponent))")
        }
        for writer in videoWriters {
            writer?.finishWriting {
                print("Finalized video for \(String(describing: writer?.outputURL.lastPathComponent))")
            }
        }
        
        let fullVideo = AVAsset(url: fullVideoWriter?.outputURL ?? URL(fileReferenceLiteralResourceName: ""))
        
        var duration: Double = 0
        do {
            duration = try await fullVideo.load(.duration).seconds
        }
        catch {
            print("error getting video duration")
        }

        let accuracy = Double(actionFrameCounts["benar"] ?? 0) / (Double(actionFrameCounts["salah"] ?? 0) + Double(actionFrameCounts["benar"] ?? 1))
        print(fullVideoWriter?.outputURL.absoluteString)
        let exercise = Exercise(id: UUID.init(), date: Date.now, duration: duration, accuracy: Double(accuracy), mistakes: videoWriters.map({ $0?.outputURL.relativeString ?? "" }), fullRecord: fullVideoWriter?.outputURL.absoluteString ?? "")
        
        return exercise
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func addFrameCount(_ frameCount: Int, to actionLabel: String) {
        let totalFrames = (actionFrameCounts[actionLabel] ?? 0) + frameCount
        actionFrameCounts[actionLabel] = totalFrames
    }
    
    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
        let renderFormat = UIGraphicsImageRendererFormat()
        renderFormat.scale = 1.0
        
        let frameSize = CGSize(width: frame.width, height: frame.height)
        let poseRenderer = UIGraphicsImageRenderer(size: frameSize, format: renderFormat)
        
        let frameWithPosesRendering = poseRenderer.image { rendererContext in
            let cgContext = rendererContext.cgContext
            let inverse = cgContext.ctm.inverted()
            cgContext.concatenate(inverse)
            let imageRectangle = CGRect(origin: .zero, size: frameSize)
            cgContext.draw(frame, in: imageRectangle)
            
            let pointTransform = CGAffineTransform(scaleX: frameSize.width, y: frameSize.height)
            guard let poses = poses else { return }
            
            for pose in poses {
                pose.drawWireframeToContext(cgContext, applying: pointTransform)
            }
        }
        
        DispatchQueue.main.async {
            self.currentFrame = frameWithPosesRendering
            self.fullVideoWriter?.addFrame(frameWithPosesRendering)
            self.currentVideoWriter?.addFrame(frameWithPosesRendering)
        }
    }
    
    private func calibrate(_ poses : [Pose]?) {
        let largestPose = self.videoProcessingChain.isolateLargestPose(poses)
        let landmarks = largestPose?.landmarks
        
        if let leftHip = landmarks?.first(where: {$0.name == .leftHip}), let rightHip = landmarks?.first(where: {$0.name == .rightHip}),
           let leftShoulder = landmarks?.first(where: {$0.name == .leftShoulder}), let rightShoulder = landmarks?.first(where: {$0.name == .rightShoulder}) {
            
            // Calculate the center of the bounding box
            let centerX = (leftHip.location.x + rightHip.location.x + leftShoulder.location.x + rightShoulder.location.x) / 4.0
            let centerY = (leftHip.location.y + rightHip.location.y + leftShoulder.location.y + rightShoulder.location.y) / 4.0
            
            DispatchQueue.main.async {
                self.isPersonInCenter(centerX: centerX, centerY: centerY)
            }
        } else {
            calibrationMessage = "Not yet calibrated \n Please make sure the person's full body is inside the box"
            isCentered = false // Update calibration status
        }
    }
    
    private func isPersonInCenter(centerX: CGFloat, centerY: CGFloat) {
        let screenCenterX = 0.5
        let screenCenterY = 0.5
        
        let offsetX = centerX - screenCenterX
        let offsetY = centerY - screenCenterY
        
        if abs(offsetX) < 0.15 && abs(offsetY) < 0.35 {
            isCentered = true
            calibrationMessage = "Calibrated successfully \n Press play to start training"
        } else {
            isCentered = false
            calibrationMessage = "Not yet calibrated \n Please make sure the person's full body is inside the box"
        }
    }
    
    private func sendCalibrationStatusToWatch() {
        let message = ["calibrationStatus": isCentered]
        WatchSessionManager.shared.sendMessage(message)
    }
}

extension PredictionViewModel: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCreate framePublisher: FramePublisher) {
        updateUILabels(with: .startingPrediction)
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

extension PredictionViewModel: VideoProcessingChainDelegate {
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didPredict actionPrediction: ActionPrediction,
                              for frames: Int) {
        if actionPrediction.isModelLabel {
            addFrameCount(frames, to: actionPrediction.label)
        }
        DispatchQueue.main.async { self.updateUILabels(with: actionPrediction) }
    }
    
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [Pose]?,
                              in frame: CGImage) {
        self.drawPoses(poses, onto: frame)
        
        if (!isRecording) {
            calibrate(poses)
        }
    }
}
