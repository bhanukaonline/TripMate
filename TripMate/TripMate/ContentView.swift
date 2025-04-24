//
//  ContentView.swift
//  TripMate
//
//  Created by Bhanuka on 4/22/25.
//

import SwiftUI





struct HomePage: View {
    @EnvironmentObject var router: TabRouter

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Welcome",
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
                Text("Welcome to TripMate!")
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

struct MainView: View {
    @StateObject private var router = TabRouter()

    var body: some View {
        ZStack {
            switch router.currentTab {
            case .home:
                HomePage()
            case .trips:
                TripsPage()
            case .addtrip:
                AddTripPage()
            case .map:
                MapPage()
            case .discover:
                DiscoverPage()
            }
        }
        .environmentObject(router)
    }
}

#Preview {
    MainView()
}
