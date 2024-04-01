//
//  ProfileView.swift
//  fypDemo
//
//  Created by Eoin O’Reilly on 20/02/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingSignOutAlert = false
    
    var body: some View {

        if let user = viewModel.currentUser{
            List{
                Section{
                    HStack{
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .accentColor(.gray)
                        }
                        
                    }
                }
                
                Section("Account"){
                    Button{
                        showingSignOutAlert = true
                    } label: {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert(isPresented: $showingSignOutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        viewModel.signOut() // Proceed with sign out
                    },
                    secondaryButton: .cancel() // Dismiss the alert without action
                )
            }
        
        }
    }
}

#Preview {
    ProfileView()
}
