//
//  HomePage.swift
//  TripMate
//
//  Created by Bhanuka on 4/26/25.
//


import SwiftUI
import MapKit

struct HomePage: View {
    @EnvironmentObject var router: TabRouter
    @EnvironmentObject var tripStore: TripStore
    @State private var selectedTrip: Trip?
    @State private var showTripDetails = false
    @State private var showUserAccountPage = false
    
    // User profile information
    let username = "Bhanuka Seneviratne"
    let avatarImage = "person.circle.fill" // Using system image as placeholder
    
    // Hardcoded discovery destinations
    let destinations = [
        DestinationItem(name: "Bali, Indonesia", image: "beach", description: "Tropical paradise with stunning beaches", color: "#FF7E5F"),
        DestinationItem(name: "Kyoto, Japan", image: "shrine", description: "Ancient temples and beautiful gardens", color: "#00B4D8"),
        DestinationItem(name: "Santorini, Greece", image: "island", description: "White-washed buildings with blue domes", color: "#5E60CE"),
        DestinationItem(name: "Marrakech, Morocco", image: "market", description: "Vibrant markets and rich culture", color: "#FFB703")
    ]
    
    var upcomingTrips: [Trip] {
        let today = Date()
        return tripStore.trips
            .filter { $0.startDate > today }
            .sorted { $0.startDate < $1.startDate }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView(title: "",
                       leading: {
                                                  // User profile section - updated with button
                                                  Button(action: {
                                                      showUserAccountPage = true
                                                  }) {
                                                      HStack {
                                                          Image(systemName: avatarImage)
                                                              .font(.system(size: 32))
                                                              .foregroundColor(.white)
                                                          
                                                          VStack(alignment: .leading) {
                                                              Text("Welcome back")
                                                                  .font(.subheadline)
                                                                  .foregroundColor(.white.opacity(0.8))
                                                              Text(username)
                                                                  .font(.headline)
                                                                  .foregroundColor(.white)
                                                          }
                                                      }
                                                  }
                                              },
                       trailing: {
                           Button(action: {
                               print("Notifications tapped")
                           }) {
                               Image(systemName: "bell.badge")
                                   .font(.system(size: 20))
                                   .foregroundColor(.white)
                           }
                       })
            
            ScrollView {
                VStack(spacing: 25) {
                    // Latest upcoming trip section
                    if let latestTrip = upcomingTrips.first {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("YOUR NEXT ADVENTURE")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.leading, 16)
                            
                            LatestTripCard(trip: latestTrip) {
                                selectedTrip = latestTrip
                                tripStore.selectedTripId = latestTrip.id
                                showTripDetails = true
                            }
                        }
                    } else {
                        NoTripsView()
                    }
                    
                    // Other upcoming trips section
                    if upcomingTrips.count > 1 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("UPCOMING TRIPS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 12) {
                                ForEach(upcomingTrips.dropFirst()) { trip in
                                    UpcomingTripRow(trip: trip) {
                                        selectedTrip = trip
                                        tripStore.selectedTripId = trip.id
                                        showTripDetails = true
                                    }
                                }
                            }
                        }
                    }
                    
                    // Discover section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("DISCOVER")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Button(action: {
                                print("See all destinations")
                            }) {
                                Text("See all")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "#00B4D8"))
                            }
                        }
                        .padding(.horizontal, 16)
                        
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 16) {
//                                ForEach(destinations) { destination in
//                                    DestinationCard(destination: destination)
//                                }
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.bottom, 8)
//                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 20)
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
        .sheet(isPresented: $showUserAccountPage) {
                    UserAccountPage()
                        .environmentObject(router)
                }
    }
}

// Component for the large featured trip card
struct LatestTripCard: View {
    var trip: Trip
    var onTap: () -> Void
    @EnvironmentObject var tripStore: TripStore
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    if let imageName = trip.imageName, let image = tripStore.loadImageFromDocuments(imageName: imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#00485C"), Color(hex: "#007090")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "airplane")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.7))
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(formattedDateRange(trip.startDate, trip.endDate))")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0)]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 16) {
                        TripInfoItem(icon: "dollarsign.circle", label: "Budget", value: "LKR \(String(format: "%.2f", trip.budget))")
                        
                        Divider()
                            .frame(height: 24)
                            .background(Color.white.opacity(0.2))
                        
                        TripInfoItem(icon: "clock", label: "Duration", value: "\(daysBetween(trip.startDate, trip.endDate)) days")
                    }
                    
                    Button(action: onTap) {
                        Text("View Details")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color(hex: "#00485C"))
                            .cornerRadius(8)
                    }
                }
                .padding(16)
                .background(Color(hex: "#2A2A2A"))
            }
            .background(Color(hex: "#2A2A2A"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
    
    private func formattedDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end)), \(Calendar.current.component(.year, from: start))"
    }
    
    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
}

// Component for trip info items within cards
struct TripInfoItem: View {
    var icon: String
    var label: String
    var value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
    }
}

// Component for upcoming trip rows
struct UpcomingTripRow: View {
    var trip: Trip
    var onTap: () -> Void
    @EnvironmentObject var tripStore: TripStore
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Trip image
                if let imageName = trip.imageName, let image = tripStore.loadImageFromDocuments(imageName: imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#00485C").opacity(0.6))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "airplane.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
                
                // Trip info
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                        Text(formatted(trip.startDate))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                        Text("LKR \(String(format: "%.2f", trip.budget))")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // View details button
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(12)
            .background(Color(hex: "#2A2A2A"))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
    
    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// Component for destination cards in the discover section
//struct DestinationCard: View {
//    var destination: DestinationItem
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            ZStack(alignment: .topTrailing) {
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color(hex: destination.color))
//                    .frame(width: 160, height: 120)
//                    .overlay(
//                        Image(systemName: destination.image)
//                            .font(.system(size: 40))
//                            .foregroundColor(.white.opacity(0.8))
//                    )
//                
//                Button(action: {
//                    print("Bookmarked \(destination.name)")
//                }) {
//                    Image(systemName: "bookmark")
//                        .foregroundColor(.white)
//                        .padding(8)
//                }
//            }
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(destination.name)
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .lineLimit(1)
//                
//                Text(destination.description)
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.7))
//                    .lineLimit(2)
//            }
//            .padding(.horizontal, 8)
//            .padding(.bottom, 8)
//        }
//        .background(Color(hex: "#2A2A2A"))
//        .cornerRadius(16)
//        .frame(width: 160)
//    }
//}

// Data model for destination items
struct DestinationItem: Identifiable {
    let id = UUID()
    let name: String
    let image: String // System image name
    let description: String
    let color: String // Hex color code
}

// No trips view
struct NoTripsView: View {
    @EnvironmentObject var router: TabRouter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 20)
            
            Text("No trips planned yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Add your first trip to start planning your adventures")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                router.currentTab = .addtrip
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Trip")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color(hex: "#00485C"))
                .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#2A2A2A"))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

// Helper extension for date formatting
extension DateFormatter {
    static let tripDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// Helper function for formatted dates
func formatted(_ date: Date) -> String {
    return DateFormatter.tripDateFormatter.string(from: date)
}
