//
//  ContentView.swift
//  TripMate
//
//  Created by Bhanuka on 4/22/25.
//

import SwiftUI

//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("TripMate( hi nee")
//        }
//        .padding()
//    }
//}
struct HomePage: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Welcome",
                       leading: {
                           Button(action: {
                               print("Menu tapped")
                           }) {
//                               Image(systemName: "line.horizontal.3")
                           }
                       },
                       trailing: {
                           Button(action: {
                               print("Search tapped")
                           }) {
                               Image(systemName: "bell.badge")
                           }
                       })

           
            VStack {
                Spacer()
                Text("Welcome to TripMate!")
                    .padding()
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#383838"))
            .clipShape(RoundedCorner(radius: 25, corners: [.topLeft, .topRight])) // Clip the shape itself


            

            

            CustomTabBar(selectedIndex: $selectedTab)
        }
        .background(Color(hex: "#00485C"))
        .edgesIgnoringSafeArea(.bottom)
    }
}



#Preview {
    HomePage()
}
