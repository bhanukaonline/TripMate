//
//  TripsPage.swift
//  TripMate
//
//  Created by Bhanuka on 4/24/25.
//

import SwiftUI
import MapKit

struct TripCardView: View {
    var trip: Trip
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                if let data = trip.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(Color(hex: "#00485C").opacity(0.5))
                        .frame(height: 160)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.7))
                        )
                        .cornerRadius(10)
                }

                Text(trip.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Text("\(formatted(trip.startDate)) - \(formatted(trip.endDate))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                HStack {
                    Label("Budget:", systemImage: "dollarsign.circle")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("LKR \(String(format: "%.2f", trip.budget))")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color(hex: "#222222"))
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TripsPage: View {
    @EnvironmentObject var router: TabRouter
    @EnvironmentObject var tripStore: TripStore
    @State private var selectedTrip: Trip?
    @State private var showTripDetails = false

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
                if tripStore.trips.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "airplane.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 60)
                        
                        Text("No trips added yet")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Add your first trip by tapping the + button")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            router.currentTab = .addtrip
                        }) {
                            Text("Add Trip")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "#00485C"))
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                } else {
                    VStack(spacing: 16) {
                        ForEach(tripStore.trips) { trip in
                            TripCardView(trip: trip) {
                                // Set the selected trip and show details
                                selectedTrip = trip
                                tripStore.selectedTripId = trip.id
                                showTripDetails = true
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(hex: "#383838"))
            .clipShape(RoundedCorner(radius: 25, corners: [.topLeft, .topRight]))

            CustomTabBar()
        }
        .background(Color(hex: "#00485C"))
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showTripDetails) {
            if let trip = selectedTrip {
                TripDetailsPage(trip: trip)
                    .environmentObject(tripStore)
                    .environmentObject(router)
            }
        }
    }
}

// Trip Details Page
struct TripDetailsPage: View {
    var trip: Trip
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var router: TabRouter
    
    @State private var activeTab = 0
    @State private var showAddAccommodation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Image
                    ZStack(alignment: .bottomLeading) {
                        if let data = trip.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color(hex: "#00485C"))
                                .frame(height: 220)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.7))
                                )
                        }
                        
                        // Trip name overlay
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trip.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("\(formatted(trip.startDate)) - \(formatted(trip.endDate))")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                Text("\(daysBetween(start: trip.startDate, end: trip.endDate)) days")
                                    .font(.headline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                    }
                    
                    // Trip Details Content
                    VStack(spacing: 20) {
                        // Summary Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trip Summary")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            // Trip Stats
                            HStack(spacing: 20) {
                                TripStatCard(
                                    title: "Budget",
                                    value: "LKR \(String(format: "%.2f", trip.budget))",
                                    icon: "dollarsign.circle.fill",
                                    color: Color(hex: "#4CAF50")
                                )
                                
                                TripStatCard(
                                    title: "Days",
                                    value: "\(daysBetween(start: trip.startDate, end: trip.endDate))",
                                    icon: "calendar",
                                    color: Color(hex: "#2196F3")
                                )
                                
                                TripStatCard(
                                    title: "Places",
                                    value: "\(trip.accommodations.count)",
                                    icon: "mappin.and.ellipse",
                                    color: Color(hex: "#FF9800")
                                )
                            }
                        }
                        .padding()
                        .background(Color(hex: "#222222"))
                        .cornerRadius(15)
                        
                        // Tab Selection
                        HStack {
                            TabButton(title: "Accommodations", isActive: activeTab == 0) {
                                activeTab = 0
                            }
                            
                            TabButton(title: "Activities", isActive: activeTab == 1) {
                                activeTab = 1
                            }
                            
                            TabButton(title: "Transport", isActive: activeTab == 2) {
                                activeTab = 2
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Tab Content
                        switch activeTab {
                        case 0:
                            accommodationsView
                        case 1:
                            activitiesView
                        case 2:
                            transportView
                        default:
                            accommodationsView
                        }
                    }
                    .padding()
                }
            }
            .background(Color(hex: "#383838"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Edit trip functionality could be added here
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showAddAccommodation) {
                AddAccommodationPage()
                    .environmentObject(tripStore)
                    .environmentObject(router)
            }
        }
    }
    
    // Accommodations Tab Content
    private var accommodationsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Accommodations")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    tripStore.selectedTripId = trip.id
                    showAddAccommodation = true
                }) {
                    Label("Add", systemImage: "plus")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#00485C"))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }
            }
            
            if trip.accommodations.isEmpty {
                EmptyStateView(
                    icon: "bed.double",
                    title: "No Accommodations",
                    message: "Add your first accommodation by tapping the + button"
                )
            } else {
                // Map showing all accommodations
                Map {
                    ForEach(trip.accommodations) { accommodation in
                        Marker(accommodation.name, coordinate: accommodation.coordinate.coordinate)
                            .tint(.red)
                    }
                }
                .frame(height: 200)
                .cornerRadius(15)
                .padding(.bottom, 10)
                
                // List of accommodations
                ForEach(trip.accommodations) { accommodation in
                    AccommodationCard(accommodation: accommodation)
                }
            }
        }
    }
    
    // Activities Tab Content
    private var activitiesView: some View {
        EmptyStateView(
            icon: "figure.walk",
            title: "No Activities Yet",
            message: "Plan your activities for this trip"
        )
    }
    
    // Transport Tab Content
    private var transportView: some View {
        EmptyStateView(
            icon: "airplane",
            title: "No Transport Info",
            message: "Add transport details for your trip"
        )
    }
    
    // Helper function to format dates
    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Helper function to calculate days between dates
    private func daysBetween(start: Date, end: Date) -> Int {
        Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
}

// Trip Stat Card Component
struct TripStatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(hex: "#333333"))
        .cornerRadius(12)
    }
}

// Tab Button Component
struct TabButton: View {
    var title: String
    var isActive: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isActive ? .bold : .regular)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .foregroundColor(isActive ? .white : .white.opacity(0.6))
                .background(isActive ? Color(hex: "#00485C") : Color.clear)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
}

// Accommodation Card Component
struct AccommodationCard: View {
    var accommodation: Accommodation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bed.double.fill")
                    .foregroundColor(Color(hex: "#FF9800"))
                    .font(.system(size: 24))
                
                VStack(alignment: .leading) {
                    Text(accommodation.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(formatted(accommodation.checkIn)) - \(formatted(accommodation.checkOut))")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text("\(stayDuration(checkIn: accommodation.checkIn, checkOut: accommodation.checkOut)) nights")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#00485C").opacity(0.5))
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("LKR \(String(format: "%.2f", accommodation.budget))")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if !accommodation.notes.isEmpty {
                    Button(action: {
                        // Show notes in a popup or detail view
                    }) {
                        Label("Notes", systemImage: "note.text")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "#222222"))
        .cornerRadius(15)
    }
    
    // Helper function to format dates
    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Helper function to calculate stay duration
    private func stayDuration(checkIn: Date, checkOut: Date) -> Int {
        Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 0
    }
}

// Empty State Component
struct EmptyStateView: View {
    var icon: String
    var title: String
    var message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 30)
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "#222222"))
        .cornerRadius(15)
    }
}


