//
//  LogIn.swift
//  fypDemo
//
//  Created by Eoin O’Reilly on 27/01/2024.
//

import SwiftUI

struct LogIn: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var showPassword: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack{
            Color.yellow.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                Text("Welcome Back")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.black)
                
                TextField("Email",
                          text: $email,
                          prompt: Text("Email").foregroundColor(.black))
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 2)
                }
                .padding(.horizontal)
                .autocapitalization(. none)
                
                HStack {
                    Group {
                        if showPassword { // when this changes, you show either TextField or SecureField
                            TextField("Password",
                                      text: $password,
                                      prompt: Text("Password").foregroundColor(.black)) .autocapitalization(. none)
                                           
                        } else {
                            SecureField("Password", // how to create a secure text field
                                        text: $password,
                                        prompt: Text("Password").foregroundColor(.black)) // How to change the color of the TextField Placeholder
                        }
                    }
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.black, lineWidth: 2) // How to add rounded corner to a TextField and change it colour
                    }
                    
                    Button { // add this new button
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.black)
                    }
                    
                }.padding(.horizontal)
                
                Spacer()
                
                // sign-in button
                
                Button {
                    Task{
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                    
                } label: {
                    Text("Sign In")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity) // how to make a button fill all the space available horizontaly
//                .background(
//                    isSignInButtonDisabled ? Color(.gray) : Color(.black)
//                )
                .background(Color(.black))
                .cornerRadius(20)
                .disabled(!formIsValid) 
                .opacity(formIsValid ? 1.0 : 0.5)
                .padding()
                
            }
        }
        .alert(isPresented: $viewModel.showError, content: {
            Alert(title: Text(viewModel.errorMessage))
        })
    }
        
}

extension LogIn: AuthenticationFormProtocol{
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}


#Preview {
    LogIn()
}
