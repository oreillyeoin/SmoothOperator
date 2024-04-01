//
//  fypDemoApp.swift
//  fypDemo
//
//  Created by Eoin O’Reilly on 24/10/2023.
//

import SwiftUI
import Firebase

@main
struct fypDemoApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
