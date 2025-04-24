//
//  TripsPage.swift
//  TripMate
//
//  Created by Bhanuka on 4/24/25.
//

import SwiftUI

struct TripsPage: View {
    @EnvironmentObject var router: TabRouter
    @EnvironmentObject var tripStore: TripStore

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Trips",
                       leading: {
                           Button(action: {
                               print("Menu tapped")
                           }) { }
                       },
                       trailing: {
                           Button(action: {
                               router.currentTab = .addtrip
                           }) {
                               Image(systemName: "plus")
                               Text("Add Trip")
                           }
                       })

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(tripStore.trips) { trip in
                        TripCardView(trip: trip)
                    }
                }
                .padding()
            }
            .background(Color(hex: "#383838"))
            .clipShape(RoundedCorner(radius: 25, corners: [.topLeft, .topRight]))

            CustomTabBar()
        }
        .background(Color(hex: "#00485C"))
        .edgesIgnoringSafeArea(.bottom)
    }
}
