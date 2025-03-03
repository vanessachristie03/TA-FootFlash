import SwiftUI
import WatchConnectivity


class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func sendMessage(_ message: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let command = message["command"] as? String {
            DispatchQueue.main.async {
                if command == "startRecording" {
                    NotificationCenter.default.post(name: .startRecording, object: nil)
                } else if command == "stopRecording" {
                    NotificationCenter.default.post(name: .stopRecording, object: nil)
                }
            }
        }
    }
}

extension Notification.Name {
    static let startRecording = Notification.Name("startRecording")
    static let stopRecording = Notification.Name("stopRecording")
}

import SwiftUI
import WatchConnectivity

struct TrainClassifierView: View {
    @ObservedObject var predictionVM = PredictionViewModel()
    @State private var isShowingRecordedVideos = false
    @State private var isRecording = false
    @State private var navigateToSavePredictedResult = false
    @State var recordedExercise: Exercise = Exercise()
    
    var watchConnector = WatchSessionManager.shared
    @State private var isPortrait = true // State to track orientation
    @Environment(\.modelContext) var modelContext

    var predictionLabels: some View {
        VStack {
            Spacer()
            Text("Prediction: \(predictionVM.predicted)").foregroundStyle(Color.white).fontWeight(.bold)
            Text("Confidence: \(predictionVM.confidence)").foregroundStyle(Color.white).fontWeight(.bold)
        }
        .padding(.bottom, 32)
    }
    
    var calibrationMessage: some View {
        VStack {
            Spacer()
            Text(predictionVM.calibrationMessage).foregroundStyle(Color.white).fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 32)
    }
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                    Image(uiImage: predictionVM.currentFrame ?? UIImage())
                        .resizable()
                        .frame(width: gr.size.width, height: gr.size.height)
                        .padding(.zero)
                        .scaledToFit()
                    
                    !isRecording  && !isPortrait ? Rectangle()
                        .frame(width: gr.size.width * 0.25, height: gr.size.height)
                        .border(predictionVM.isCentered ? Color.green : Color.red, width: 3)
                        .foregroundStyle(Color.white.opacity(0))
                        .backgroundStyle(Color.white.opacity(0)) : nil
                    
                    ((predictionVM.isCentered && !isRecording) || isRecording) ? Button {
                        isRecording = !isRecording
                        
                        if isRecording {
                            predictionVM.startRecording()
                        } else {
                            Task {
                                recordedExercise = await predictionVM.stopRecording()
                                predictionVM.videoCapture.isEnabled = false
                                 
                                // only saves exercise when duration is 10s or above
                                if recordedExercise.duration >= 10 && (predictionVM.actionFrameCounts["benar"] ?? 0 > 0 || predictionVM.actionFrameCounts["salah"] ?? 0 > 0) {
                                    modelContext.insert(recordedExercise)
                                }
                                
                                isShowingRecordedVideos = true
                            }
                        }
                    } label: {
                        Image(systemName: isRecording ? "stop.fill" : "play.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.white)
                    } : nil
                    
//                    Button {
//                        isRecording = !isRecording
//
//                        if isRecording {
//                            predictionVM.startRecording()
//                        } else {
//                            Task {
//                                recordedExercise = await predictionVM.stopRecording()
//                                predictionVM.videoCapture.isEnabled = false
//                                 
//                                // only saves exercise when duration is 10s or above
//                                if recordedExercise.duration >= 10 && (predictionVM.actionFrameCounts["benar"] ?? 0 > 0 || predictionVM.actionFrameCounts["salah"] ?? 0 > 0) {
//                                    modelContext.insert(recordedExercise)
//                                }
//                                
//                                isShowingRecordedVideos = true
//                            }
//                        }
//                    } label: {
//                        Image(systemName: isRecording ? "stop.fill" : "play.fill")
//                            .resizable()
//                            .frame(width: 50, height: 50)
//                            .foregroundStyle(Color.white)
//                    }
                    
                    if isRecording {
                        predictionLabels
                    }
                    else {
                        calibrationMessage
                    }
                    
                    // Overlay for rotation prompt
                    if isPortrait {
                        Rectangle()
                            .fill(Color.black.opacity(0.7))
                            .edgesIgnoringSafeArea(.all)
                            .overlay(
                                Text("Please rotate your phone")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding()
                            )
                    }
                }
                .onAppear {
                    predictionVM.updateUILabels(with: .startingPrediction)
                    setupNotificationObservers()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    let orientation = UIDevice.current.orientation
                    isPortrait = orientation.isPortrait
                    predictionVM.videoCapture.updateDeviceOrientation()
                }
                .navigationDestination(isPresented: $isShowingRecordedVideos) {
                        ExerciseDetailView(exercise: recordedExercise)
                }
                .onDisappear{
                    predictionVM.videoCapture.isEnabled = false
                }
            }
            .ignoresSafeArea(.all)
        }
        .onReceive(predictionVM.$predicted) { predicted in
            let message = ["predicted": predicted]
            watchConnector.sendMessage(message)
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(isRecording ? true : false)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(forName: .startRecording, object: nil, queue: .main) { _ in
            if !isRecording {
                isRecording = true
                predictionVM.startRecording()
            }
        }
        NotificationCenter.default.addObserver(forName: .stopRecording, object: nil, queue: .main) { _ in
            if isRecording {
                isRecording = false
                Task {
                    recordedExercise = await predictionVM.stopRecording()
                    predictionVM.videoCapture.isEnabled = false
                     
                    // only saves exercise when duration is 10s or above
                    if recordedExercise.duration >= 10 && (predictionVM.actionFrameCounts["benar"] ?? 0 > 0 || predictionVM.actionFrameCounts["salah"] ?? 0 > 0) {
                        modelContext.insert(recordedExercise)
                    }
                    
                    isShowingRecordedVideos = true
                }
            }
        }
    }
}

#Preview {
    TrainClassifierView()
}
