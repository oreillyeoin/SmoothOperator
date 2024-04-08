import Foundation
import FirebaseFirestore
import FirebaseAuth

extension History {
    @MainActor class ViewModel: ObservableObject {
        @Published var journeys: [Journey] = []
        @Published var avgScore = -1.0
        
        struct Journey {
            var score: Double
            var distance: Double
            var penalty: Int
            var date: Date
        }
        
        
        func fetchJourneys() {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not logged in.")
                return
            }
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            userRef.getDocument { document, error in
                if let error = error {
                    print("Error fetching document: \(error.localizedDescription)")
                    return
                }
                
                guard let document = document, document.exists else {
                    print("Document does not exist")
                    return
                }
                
                var fetchedJourneys: [Journey] = []
                if let journeysData = document.data()?["journeys"] as? [[String: Any]] {
                    for journeyData in journeysData {
                        if let fscore = journeyData["score"] as? Double, let fDistance = journeyData["distance"] as? Double, let fpenalty = journeyData["penalty"] as? Int, let timestamp = journeyData["date"] as? Timestamp {
                            
                            let date = timestamp.dateValue()
                            fetchedJourneys.append(Journey(score: fscore, distance: fDistance, penalty: fpenalty, date: date))
                        }
                    }
                }
                
                if let averageScore = document.data()?["averageScore"] as? Double {
                    DispatchQueue.main.async {
                        self.avgScore = averageScore
                    }
                }
                
                DispatchQueue.main.async {
                    self.journeys = fetchedJourneys
                }
            }
        }
        
        func deleteJourney(at index: Int) {
                    guard let userID = Auth.auth().currentUser?.uid else {
                        print("User not logged in.")
                        return
                    }

                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(userID)

                    // Assuming journeys is already fetched
                    var updatedJourneys = journeys
                    updatedJourneys.remove(at: index)

                    let journeysData = updatedJourneys.map { journey -> [String: Any] in
                        return [
                            "score": journey.score,
                            "distance": journey.distance,
                            "penalty": journey.penalty,
                            "date": Timestamp(date: journey.date)
                        ]
                    }
            
                    let newAvgScore = updatedJourneys.reduce(0.0, { $0 + $1.score }) / Double(updatedJourneys.count)

                    // Update Firestore
                    userRef.updateData([
                            "journeys": journeysData,
                            "averageScore": newAvgScore
                    ]) { error in
                        if let error = error {
                            print("Error updating document: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                self.journeys = updatedJourneys
                                self.avgScore = newAvgScore
                            }
                        }
                    }
                }
    }
}
