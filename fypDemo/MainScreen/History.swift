//
//  History.swift
//  fypDemo
//
//  Created by Eoin O’Reilly on 13/03/2024.
//

import SwiftUI

struct History: View {
    @StateObject var viewModel = History.ViewModel()
    @State private var confirmDelete = false
    @State private var journeyToDelete: Int?
    @State private var dropdown: Int? = nil
    
    var body: some View {
        ZStack{
            Color.yellow.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    Spacer()
                    
                    Text("Trip History")
                        .font(.title)
                        .bold()
                    
                    if(viewModel.avgScore != -1){
                        HStack{
                            Text("Average Score: ")
                                .font(.title3)
                                .italic()
                                .bold()
                            
                            Text(String(format: "%0.2f%%", viewModel.avgScore))
                                .font(.title)
                                .bold()
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 4)
                                        .foregroundColor(Color.black)
                                        .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                )
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    if !viewModel.journeys.isEmpty {
                        ForEach(viewModel.journeys.indices, id: \.self) { index in
                            let journey = viewModel.journeys[index]
                            VStack(alignment: .center, spacing: 5) {
                                
                                Text("JOURNEY \(index + 1)")
                                    .font(.title3)
                                    .bold()
                                
                                Text("\(journey.date.formatted())")
                                    .font(.caption)
                                    .italic()
                                
                                Divider()
                                    .background(Color.black)
                                    .frame(width: 250)
                                    .padding(.maximum(5, 5))

                                HStack{
                                    Text("Score:")
                                        .font(.title)
                                        .italic()
                                        .frame(alignment: .trailing)
                                    Text(String(format: "%.2f", journey.score))
                                        .font(.title)
                                        .bold()
                                        .frame(alignment: .trailing)
                                }

                                if dropdown == index {
                                    VStack(spacing: 5) {
                                        HStack{
                                            Text("Distance:")
                                                .font(.title3)
                                                .italic()
                                            Text(String(format: "%.2fkm", journey.distance/1000))
                                                .font(.title3)
                                                .bold()
                                        }
                                        HStack{
                                            Text("Penalties:")
                                                .font(.title3)
                                                .italic()
                                            Text(String(format: "%d", journey.penalty))
                                                .font(.title3)
                                                .bold()
                                        }
                                    }
                                    .padding(.leading)
                                }
                                
                            }
                            .frame(maxWidth: 300)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(radius: 5)
                            .overlay(
                                Group{
                                    if dropdown == index {
                                        Button(action: {
                                            journeyToDelete = index
                                            confirmDelete = true
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .padding(5)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.top, 10)
                                        .padding(.trailing, 10)
                                        
                                    }
                                },
                                alignment: .topTrailing
                            )
                            .onTapGesture {
                                withAnimation {
                                    dropdown = (dropdown == index) ? nil : index
                                }
                            }
                            
                            
                        }
                    } else {
                        Text("No journeys available")
                    }
                    
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.black)
                            Text("DONE")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.yellow)
                        }
                    }
                    .frame(width: 300, height: 50)
                    .padding()
                }
                .padding(.horizontal, 10)
                
            }
            
        }
        .alert(isPresented: $confirmDelete) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this journey?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let index = journeyToDelete {
                        viewModel.deleteJourney(at: index)
                        journeyToDelete = nil
                        dropdown = nil
                    }
                },
                secondaryButton: .cancel {
                    journeyToDelete = nil
                }
            )
        }
        .onAppear {
            viewModel.fetchJourneys()
        }
    }
}

#Preview {
    History()
}
