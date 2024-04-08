//
//  MainView-ViewModel.swift
//  fypDemo
//
//  Created by Eoin O’Reilly on 29/10/2023.
//

import CoreLocation
import Foundation
import Firebase
import FirebaseFirestoreSwift
import UserNotifications
import Foundation

extension MainView{
    @MainActor class ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
        @Published var acceleration = 0.0
        @Published var activeSpeed = 0.0
        @Published var activeDistance = 0.0
        @Published var activeScore = 100.0
        @Published var activePenalty: [Date] = []
        @Published var penDesc: [String] = []
        
        @Published var fspeed = 0.0
        @Published var fdistance = 0.0
        @Published var fscore = 0.0
        @Published var fpenalty = 0
        
        @Published var initialised = false
        @Published var penWarning = false
        var currentSpeed = 0.0
        var prevSpeed = 0.0
        var prevLocation: CLLocation!
        var lastTime: Date?
        var stop = false
        var updateCount = 0
        var accCount = 0
        var speedCount = 0

        struct Journey {
            var score: Double
            var distance: Double
            var penalty: Int
            var date: Date
        }
        
        
        let locationManager = CLLocationManager()
        
        override init(){
            super.init()
            
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            for currentLocation in locations{
                if stop {
                    locationManager.stopUpdatingLocation()
                }
                
                // set previous speed (for acceleration calculation) and update speed
                self.prevSpeed = activeSpeed
                self.activeSpeed = currentLocation.speed
                
                // Calibration (GPS Displays a speed of -1 when Uncalibration)
                if self.activeSpeed != -1{
                    self.initialised = true
                    
                    // update distance and acceleration
                    let now = Date()
                    self.activeDistance += currentLocation.distance(from: prevLocation ?? currentLocation)
                    self.acceleration = (activeSpeed - prevSpeed) / now.timeIntervalSince((lastTime ?? now) as Date)
                                        
                    // ALGORITHM
                    self.penWarning = false
                    
                    // detect invalid acceleration values
                    if self.acceleration > 10 || self.acceleration < -10{
                        self.acceleration = 0
                    }
                    
                    // detecting hard acceleration / braking
                    else if self.acceleration > 1.5 || self.acceleration < -2{
                        self.accCount += 1
                        
                        // every three updates apply an additional penalty
                        if self.accCount % 3 == 1{
                            if self.acceleration > 0{
                                applyPenalty(message: "Harsh Acceleration")
                            }
                            else{
                                applyPenalty(message: "Hard Braking")
                            }
                        }
                    }
                    else{
                        self.accCount = 0
                    }
                    
                    // detecting high speed
                    if self.activeSpeed*3.6 > 130{
                        self.speedCount += 1
                        
                        // every six updates apply an additional penalty
                        if self.speedCount % 6 == 1{
                            applyPenalty(message: "High Speed")
                        }
                    }
                    else{
                        self.speedCount = 0
                    }
                    
                    // Calculating Score
                    let distanceMetric = 1/Double(((self.activeDistance)+1000)/10000)
                    self.activeScore = 100 - (distanceMetric*2*Double(self.activePenalty.count))
                    
                    if self.activeScore < 0{
                        self.activeScore = 0
                    }
                
                    self.prevLocation = currentLocation
                    self.lastTime = now
                }
                
            }
        }
        
        func applyPenalty(message: String){
            self.activePenalty.append(Date())
            self.penDesc.append(message)
            self.penWarning = true
            self.sendNotification(message: message)
        }
        
        func endTrip(){
            stop = true
            
            fdistance = activeDistance
            fscore = activeScore
            fpenalty = activePenalty.count
                        
            let newJourney = Journey(score: fscore, distance: fdistance, penalty: fpenalty, date: Date())

            addJourney(newJourney: newJourney)
        }
        
        func addJourney(newJourney: Journey) {
            if let userID = Auth.auth().currentUser?.uid {
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(userID)
                
                userRef.getDocument { document, error in
                    if let document = document, document.exists {
                        var journeys = [Journey]()
                        if let journeysData = document.data()?["journeys"] as? [[String: Any]] {
                            for journeyData in journeysData {
                                if let fscore = journeyData["score"] as? Double, let fDistance = journeyData["distance"] as? Double, let fpenalty = journeyData["penalty"] as? Int, let timestamp = journeyData["date"] as? Timestamp  {
                                    
                                    let date = timestamp.dateValue()
                                    journeys.append(Journey(score: fscore, distance: fDistance, penalty: fpenalty, date: date))
                                }
                            }
                        }
                        
                        // Append new journey to the array
                        journeys.append(newJourney)
                        
                        let averageScore = journeys.reduce(0.0, { $0 + $1.score }) / Double(journeys.count)
                        
                        let updatedJourneysData = journeys.map { journey -> [String: Any] in
                            return [
                                "score": journey.score,
                                "distance": journey.distance,
                                "penalty": journey.penalty,
                                "date": Timestamp(date: journey.date)
                            ]
                        }
                        
                        // Update the array in Firestore
                        userRef.setData(["journeys": updatedJourneysData, "averageScore": averageScore], merge: true) { error in
                            if let error = error {
                                print("Error updating journeys and average score in Firestore: \(error.localizedDescription)")
                            } else {
                                print("Journey and average score added successfully!")
                            }
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            } else {
                print("User not logged in.")
            }
        }
        
        func sendNotification(message: String) {
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
                guard granted else { return }
                if let error = error {
                    print("Authorization error: \(error)")
                    return
                }
                
                let content = UNMutableNotificationContent()
                content.title = "WARNING: " + message
                content.body = "Be mindful of your fuel economy and safety!"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        }
    }
}


