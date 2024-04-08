//
//  AuthViewModel.swift
//  fypDemo
//
//  Created by Eoin O’Reilly on 20/02/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol{
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    @Published var showError = false
    var errorMessage = ""

    init(){
        self.userSession = Auth.auth().currentUser
        
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch{
            showError = true
            if error.localizedDescription == "The supplied auth credential is malformed or has expired."{
                errorMessage = "Incorrect email/ password. Try again."
            }
            else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws{
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
            
        } catch{
            showError = true
            if error.localizedDescription == "The email address is badly formatted."{
                errorMessage = "The email address is incorrectly formatted."
            }
            else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch{
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        self.currentUser = try? snapshot?.data(as: User.self)
        
    }
}
