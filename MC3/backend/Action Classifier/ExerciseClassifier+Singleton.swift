/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Creates a common instance of the Exercise Classifier.
 The app only uses one instance anyway and using a static property initializes
 the model at launch instead of when the the main view loads.
*/

import CoreML

extension FootworkClassifier_1_105f_Iteration_90 {
    /// Creates a shared Exercise Classifier instance for the app at launch.
    static let shared: FootworkClassifier_1_105f_Iteration_90 = {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()

        // Create an Exercise Classifier instance.
        guard let FootworkClassifier_1_105f_Iteration_90 = try? FootworkClassifier_1_105f_Iteration_90(configuration: defaultConfig) else {
            // The app requires the action classifier to function.
            fatalError("Exercise Classifier failed to initialize.")
        }

        // Ensure the Exercise Classifier.Label cases match the model's classes.
        FootworkClassifier_1_105f_Iteration_90.checkLabels()

        return FootworkClassifier_1_105f_Iteration_90
    }()
}
