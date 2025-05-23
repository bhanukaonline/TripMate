//
//  MapPage.swift
//  TripMate
//
//  Created by Bhanuka on 4/24/25.
//
import SwiftUI

struct MapPage: View {
    @EnvironmentObject var router: TabRouter

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Map",
                       leading: {
                           Button(action: {
                               print("Menu tapped")
                           }) { }
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
                Text("Map here")
                    .padding()
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#383838"))
            .clipShape(RoundedCorner(radius: 25, corners: [.topLeft, .topRight]))

            CustomTabBar()
        }
        .background(Color(hex: "#00485C"))
        .edgesIgnoringSafeArea(.bottom)
    }
}
