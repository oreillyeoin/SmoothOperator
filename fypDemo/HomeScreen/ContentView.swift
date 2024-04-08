//
//  ContentView.swift
//  fypDemo
//
//  Created by Eoin O’Reilly on 24/10/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userModel: AuthViewModel
    
    var body: some View {
        
        NavigationView {
            ZStack{
                Color.yellow.ignoresSafeArea()

                NavigationLink(destination: ProfileView()){
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                }
                .position(x: UIScreen.main.bounds.width - 40, y: 40)
                .opacity(userModel.userSession == nil ? 0 : 1)
                
                VStack(spacing: 20) {
                    
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                     
                    
                    if userModel.userSession == nil {
                        NavigationLink(destination: LogIn()) {
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.black)
                                Text("LOGIN")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.yellow)
                            }
                        }
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        
                        NavigationLink(destination: CreateAccount()) {
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.black)
                                Text("CREATE ACCOUNT")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.yellow)
                            }
                        }
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        
                        
                    } else{
                        NavigationLink(destination: MainView()) {
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.black)
                                Text("NEW JOURNEY")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.yellow)
                            }
                        }
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)

                        
                        NavigationLink(destination: History().navigationBarBackButtonHidden(true)) {
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.black)
                                Text("TRIP HISTORY")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.yellow)
                            }
                        }
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
