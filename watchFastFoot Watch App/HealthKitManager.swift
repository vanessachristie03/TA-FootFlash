//import HealthKit
//
//class HealthKitManager: NSObject, ObservableObject {
//    static let shared = HealthKitManager()
//     let healthStore = HKHealthStore()
//
//    @Published var activeEnergy: Double = 0.0
//    private var workoutSession: HKWorkoutSession?
//    private var workoutBuilder: HKLiveWorkoutBuilder?
//
//    private override init() {}
//
//    func requestAuthorization() {
//        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
//            print("Error: Unable to get activeEnergyBurned type")
//            return
//        }
//        
//        let typesToShare: Set = [HKObjectType.workoutType()]
//        let typesToRead: Set = [energyType]
//
//        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
//            if !success {
//                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
//            }
//        }
//    }
//
//    func startWorkout() {
//        let config = HKWorkoutConfiguration()
//        config.activityType = .badminton
//        config.locationType = .indoor
//
//        do {
//            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
//            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
//            
//            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
//            
//            workoutSession?.delegate = self
//            workoutBuilder?.delegate = self
//
//            workoutSession?.startActivity(with: Date())
//            workoutBuilder?.beginCollection(withStart: Date()) { success, error in
//                if !success {
//                    print("Failed to start workout: \(error?.localizedDescription ?? "Unknown error")")
//                }
//            }
//        } catch {
//            print("Error starting workout session: \(error.localizedDescription)")
//        }
//    }
//    
//
//    func stopWorkout(completion: @escaping (Double) -> Void) {
//        workoutBuilder?.endCollection(withEnd: Date()) { success, error in
//            self.workoutBuilder?.finishWorkout { workout, error in
//                guard let workout = workout else { return }
//                
//                if let totalEnergy = workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) {
//                    DispatchQueue.main.async {
//                        self.activeEnergy = totalEnergy
//                        completion(totalEnergy)
//                        
//                        // Kirim nilai kalori ke iPhone
//                        WatchToIOSConnector().sendCaloriesToiPhone(burnedCalories: totalEnergy)
//                    }
//                }
//            }
//        }
//        workoutSession?.end()
//    }
//
//}
//
//// MARK: - Delegates
//extension HealthKitManager: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
//    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
//
//    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
//        print("Workout session failed: \(error.localizedDescription)")
//    }
//
//    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
//
//    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
//        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
//
//        if collectedTypes.contains(energyType) {
//            let statistics = workoutBuilder.statistics(for: energyType)
//            let totalEnergy = statistics?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
//
//            DispatchQueue.main.async {
//                self.activeEnergy = totalEnergy
//            }
//        }
//    }
//}
