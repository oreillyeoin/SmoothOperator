//
//  CreateAccount.swift
//  fypDemo
//
//  Created by Eoin O’Reilly on 27/01/2024.
//

import SwiftUI

struct CreateAccount: View {
    @State var fullname: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var email: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
// field validation! look at bottom
    
    var body: some View {
        ZStack{
            Color.yellow.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                Text("Create Account")
                    .font(.largeTitle)
                    .padding(.horizontal)
                    .foregroundColor(.black)
                
                Text("Begin tracking your driving behaviour today! Cut back on fuel costs and make improvments to your saftey.")
                    .font(.headline)
                    .padding([.horizontal, .bottom])
                    .foregroundColor(.black)
                
                TextField("Full Name",
                          text: $fullname,
                          prompt: Text("Full Name").foregroundColor(.black))
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 2)
                }
                .padding(.horizontal)
                
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
                
                SecureField("Password",
                          text: $password,
                          prompt: Text("Password").foregroundColor(.black)) // How to change the color of the TextField Placeholder
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 2) // How to add rounded corner to a TextField and change it colour
                }
                .padding(.horizontal)
                .autocapitalization(. none)
                
                ZStack(alignment: .trailing){
                    SecureField("Repeat Password",
                              text: $confirmPassword,
                              prompt: Text("Repeat Password").foregroundColor(.black)) // How to change the color of the TextField Placeholder
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.black, lineWidth: 2) // How to add rounded corner to a TextField and change it colour
                    }
                    .padding(.horizontal)
                    .autocapitalization(. none)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark")
                                .imageScale(.large)
                                .font(Font.title3.weight(.bold))
                                .foregroundColor(Color(.systemGreen))
                                .padding(.trailing, 25)
                        } else{
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .font(Font.title3.weight(.bold))
                                .foregroundColor(Color(.systemRed))
                                .padding(.trailing, 25)
                        }
                    }
                }
                
                
                Button {
                    Task{
                        try await viewModel.createUser(withEmail: email,
                                                       password: password,
                                                       fullname: fullname)
                    }
                } label: {
                    Text("Create Account")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.yellow)
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity) // how to make a button fill all the space available horizontaly
                .background(.black)
                .cornerRadius(20)
                .padding()
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
            }
        }
        .alert(isPresented: $viewModel.showError, content: {
            Alert(title: Text(viewModel.errorMessage))
        })
    }
}

extension CreateAccount: AuthenticationFormProtocol{
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
    }
}

#Preview {
    CreateAccount()
}


//    @Published var hasEightChar = false
//    @Published var hasSpacialChar = false
//    @Published var hasOneDigit = false
//    @Published var hasOneUpperCaseChar = false
//    @Published var confirmationMatch = false
//    @Published var areAllFieldsValid = false
//     validate no bad characters like ' '
