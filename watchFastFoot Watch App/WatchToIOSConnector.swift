
//
//  watchToIOSConnector.swift
//  watchFastFoot Watch App
//
//  Created by Vanessa on 16/07/24.
//

import Foundation
import WatchConnectivity
import SwiftUI
import HealthKit

class WatchToIOSConnector: NSObject, ObservableObject, WCSessionDelegate, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    
    @Published var text: String = "Waiting for calibration..."
    @Published var isCalibrated: Bool = false
    @Published var isPlaying: Bool = false
    @Published var burnedCalories: Double = 0.0
    private var initialCalories: Double = 0.0


    private var healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?

    override init() {
        super.init()
        requestHealthKitAuthorization()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func requestHealthKitAuthorization() {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let workoutType = HKObjectType.workoutType()
        let typesToRead: Set = [energyType, workoutType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("✅ HealthKit permission granted")
            } else {
                print("❌ HealthKit permission denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    func fetchCurrentCalories(completion: @escaping (Double) -> Void) {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let sum = result?.sumQuantity() else {
                print("❌ Error fetching calories: \(error?.localizedDescription ?? "Unknown error")")
                completion(0.0)
                return
            }
            let totalCalories = sum.doubleValue(for: HKUnit.kilocalorie())
            completion(totalCalories)
        }

        healthStore.execute(query)
    }


    func startWorkout() {
        let config = HKWorkoutConfiguration()
        config.activityType = .badminton
        config.locationType = .indoor

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()

            workoutSession?.delegate = self
            workoutBuilder?.delegate = self
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

            // Ambil jumlah kalori awal sebelum workout dimulai
            fetchCurrentCalories { initialCalories in
                self.initialCalories = initialCalories
                print("🔥 Initial Calories: \(initialCalories) kcal")
            }

            workoutSession?.startActivity(with: Date())
            workoutBuilder?.beginCollection(withStart: Date()) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.burnedCalories = 0.0 // Reset kalori saat mulai workout
                        self.isPlaying = true
                    }
                    print("🏃‍♂️ Workout session started")
                } else {
                    print("❌ Failed to start workout: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } catch {
            print("❌ Error creating workout session: \(error.localizedDescription)")
        }
    }


    func stopWorkout() {
        guard let session = workoutSession, let builder = workoutBuilder else { return }

        session.end()
        builder.endCollection(withEnd: Date()) { success, error in
            if success {
                builder.finishWorkout { [self] workout, error in
                    DispatchQueue.main.async {
                        self.isPlaying = false
                    }
                    if let error = error {
                        print("❌ Failed to finish workout: \(error.localizedDescription)")
                    } else {
                        // Ambil jumlah kalori akhir
                        self.fetchCurrentCalories { finalCalories in
                            let caloriesBurnedDuringWorkout = finalCalories - self.initialCalories
                            DispatchQueue.main.async {
                                self.burnedCalories = caloriesBurnedDuringWorkout
                                print("🔥 Calories burned during workout: \(caloriesBurnedDuringWorkout) kcal")
                            }
                        }
                        self.sendCaloriesToiPhone(burnedCalories: burnedCalories)
                        print("🏁 Workout finished: \(workout)")
                    }
                }
            } else {
                print("❌ Failed to end collection: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        if collectedTypes.contains(HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!) {
            if let burnedCalories = workoutBuilder.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) {
                DispatchQueue.main.async {
                    if self.isPlaying { // Hanya update jika workout aktif
                        self.burnedCalories = burnedCalories
                        print("🔥 Live Calories burned: \(burnedCalories) kcal")
                        self.sendCaloriesToiPhone(burnedCalories: burnedCalories)
                    }
                }
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("Workout event collected")
        
        // Kirim update terbaru ke iPhone
        if let burnedCalories = workoutBuilder.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) {
            DispatchQueue.main.async {
                if self.isPlaying {
                    self.burnedCalories = burnedCalories
                    print("🔥 Calories updated in event: \(burnedCalories) kcal")
                    self.sendCaloriesToiPhone(burnedCalories: burnedCalories)
                }
            }
        }
    }


    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("❌ Workout session error: \(error.localizedDescription)")
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("Workout session state changed: \(toState.rawValue)")
    }

    func sendCaloriesToiPhone(burnedCalories: Double) {
        
        if WCSession.default.isReachable {
            print("Sending calories: \(burnedCalories) to iPhone") // Debug log
            let message = ["burnedCalories": burnedCalories]
            print("Isi dari Message itu : \(message)")
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending calories to iPhone: \(error.localizedDescription)")
            }
        } else {
            print("iPhone is not reachable")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let predicted = message["predicted"] as? String {
            DispatchQueue.main.async {
                self.text = "Prediction: \(predicted)"
            }
        } else if let calibrationStatus = message["calibrationStatus"] as? Bool {
            DispatchQueue.main.async {
                self.isCalibrated = calibrationStatus
            }
        } else if let command = message["command"] as? String, command == "startRecording" {
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        }
        else if let calories = message["burnedCalories"] as? Double {
            DispatchQueue.main.async {
                self.burnedCalories = calories
            }
        }
    }

    private func handleStopRecording() {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }

    func sendMessage(_ message: [String: Any]) {
        if let command = message["command"] as? String {
            if command == "stopRecording" {
                handleStopRecording()
            } else {
                print("ga masuk if")
            }
        }
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}



    
    
   




