//
//  MainView.swift
//  fypDemo
//
//  Created by Eoin O’Reilly on 17/02/2024.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var userModel: AuthViewModel
    @State private var summary = false
    
    var body: some View {
        
        ZStack{
            Color.yellow.ignoresSafeArea()
            
                VStack(spacing: 20) {
                    if(!summary){
                        Text("SCORE")
                            .font(.system(size: 40))
                            .fontWeight(.heavy)
                        
                        if viewModel.initialised{
                            Text(String(format: "%.1f", viewModel.activeScore))
                                .font(.system(size: 100))
                                .bold()
                                .padding(.horizontal, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 7)
                                        .foregroundColor(Color.black)
                                        .background(viewModel.penWarning ? Color.red : Color(red: 0.8, green: 0.8, blue: 0.8))
                                )
                                .foregroundColor(Color.black)
                            
                            Rectangle()
                                .frame(height: 20)
                                .foregroundColor(Color.clear)
                                .padding(.horizontal)
                        }
                        else{
                            Text(String(" - - - "))
                                .font(.system(size: 100))
                                .bold()
                                .padding(.horizontal, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 7)
                                        .foregroundColor(Color.black)
                                        .background(Color(red: 0.8, green: 0.8, blue: 0.8))
                                )
                                .foregroundColor(Color.black)
                            
                            
                            Text("Initialising...")
                                .foregroundColor(Color.black)
                                .frame(alignment: .center)
                            
                            
                        }
                    
                        HStack(spacing: 20) {
                            Text("PENALTIES:")
                                .font(.title2)
                                .bold()
                            
                            Text(String(format: "%d", viewModel.activePenalty.count))
                                .font(.title2)
                                .italic()
                        }
                        
                        Divider()
                            .background(Color.black)
                            .frame(width: 325)
                        
                        HStack(spacing: 20) {
                            Text("ACCELERATION: ")
                                .font(.title2)
                                .bold()
                            Text(String(format: "%.2fm/s\u{00B2}", viewModel.acceleration))
                                .font(.title2)
                                .italic()
                        }
                        
                        Divider()
                            .background(Color.black)
                            .frame(width: 325)
                        
                        HStack(spacing: 20) {
                            Text("SPEED: ")
                                .font(.title2)
                                .bold()
                            Text(String(format: "%.2fkm/h", viewModel.initialised ? (viewModel.activeSpeed*3.6) : 0))
                                .font(.title2)
                                .italic()
                        }
                        
                        Divider()
                            .background(Color.black)
                            .frame(width: 325)
                        
                        HStack(spacing: 20) {
                            Text("DISTANCE: ")
                                .font(.title2)
                                .bold()
                            Text(String(format: "%.2fkm", viewModel.activeDistance/1000))
                                .font(.title2)
                                .italic()
                        }
                        
                        Rectangle()
                            .frame(height: 0)
                            .foregroundColor(Color.clear)
                            .padding(.horizontal)
                    
                        Button(action: {
                            viewModel.endTrip()
                            summary = true
                        }) {
                            Text("END TRIP")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.yellow)
                        }
                        .frame(width: 300, height: 50)
                        .padding(.horizontal)
                        .background(.black)
                        .cornerRadius(25)
                        
                    }
                    else {
                        ScrollView(showsIndicators: false) {
                            Text("Trip Summary")
                                .font(.title)
                                .bold()
                            
                            VStack(alignment: .center, spacing: 5){
                                Text("Score:")
                                    .font(.title2)
                                    .bold()
                                    .frame(alignment: .center)
                                
                                Text(String(format: "%.1f", viewModel.fscore))
                                    .font(.system(size: 90))
                                    .bold()
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 7)
                                            .foregroundColor(Color.black)
                                            .background(viewModel.penWarning ? Color.red : Color(red: 0.8, green: 0.8, blue: 0.8))
                                    )
                                    .foregroundColor(Color.black)
                                
                                Rectangle()
                                    .frame(height: 0)
                                    .foregroundColor(Color.clear)
                                    .padding(.horizontal)
                                
                                Rectangle()
                                    .frame(height: 10)
                                    .foregroundColor(Color.clear)
                                    .padding(.horizontal)
                                
                                HStack{
                                    Text("Distance:")
                                        .font(.title2)
                                        .italic()
                                        .frame(alignment: .trailing)
                                    Text(String(format: "%.2fkm", viewModel.fdistance/1000))
                                        .font(.title2)
                                        .bold()
                                        .frame(alignment: .trailing)
                                }
                                
                                
                                HStack{
                                    Text("Penalties: ")
                                        .font(.title2)
                                        .italic()
                                        .frame(alignment: .trailing)
                                    Text("\(viewModel.activePenalty.count)")
                                        .font(.title2)
                                        .bold()
                                        .frame(alignment: .trailing)
                                }
                                
                                ForEach(viewModel.activePenalty.indices, id: \.self) { index in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.activePenalty[index])
                                    HStack{
                                        Text("\(index+1): ")
                                            .bold()
                                        
                                        Text(String(format: "\(viewModel.penDesc[index]) @ %02d:%02d", (components.hour ?? 0), components.minute ?? 0))
                                            .italic()                                        
                                    }
                                }
                                
                                Rectangle()
                                    .frame(height: 20)
                                    .foregroundColor(Color.clear)
                                    .padding(.horizontal)
                                
                            }
                            .frame(maxWidth: 300)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(radius: 5)
                            
                            Rectangle()
                                .frame(height: 0)
                                .foregroundColor(Color.clear)
                                .padding(.horizontal)
                            
                            NavigationLink {
                                ContentView().navigationBarBackButtonHidden(true)
                            } label: {
                                Text("DONE")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.yellow)
                            }
                            .frame(width: 300, height: 50)
                            .padding(.horizontal)
                            .background(.black)
                            .cornerRadius(25)
                            
                            NavigationLink(destination: History().navigationBarBackButtonHidden(true)) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(.black)
                                        .cornerRadius(30)
                                    Text("TRIP HISTORY")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.yellow)
                                }
                            }
                            .frame(width: 300, height: 50)
                            .padding(.horizontal)
                            .background(.black)
                            .cornerRadius(25)
                        }
                    }
            }
        }
    }
}

#Preview {
    MainView()
}
