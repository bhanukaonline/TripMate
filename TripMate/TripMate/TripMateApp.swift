//
//  TripMateApp.swift
//  TripMate
//
//  Created by Bhanuka on 4/22/25.
//

import SwiftUI

@main
struct TripMateApp: App {
    @StateObject private var tripStore = TripStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(tripStore)
        }
    }
}
