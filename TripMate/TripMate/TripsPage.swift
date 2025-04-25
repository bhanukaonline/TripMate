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
    @EnvironmentObject var tripStore: TripStore // Add this
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                if let imageName = trip.imageName, let image = tripStore.loadImageFromDocuments(imageName: imageName) {
                    Image(uiImage: image)
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
        @State private var showDeleteConfirmation = false
        @State private var tripToDelete: Trip?

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
                                                    selectedTrip = trip
                                                    tripStore.selectedTripId = trip.id
                                                    showTripDetails = true
                                                }
                                                .contextMenu {
                                                    Button(role: .destructive) {
                                                        tripToDelete = trip
                                                        showDeleteConfirmation = true
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
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
        .alert("Delete Trip", isPresented: $showDeleteConfirmation, presenting: tripToDelete) { trip in
                    Button("Delete", role: .destructive) {
                        deleteTrip(trip)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: { trip in
                    Text("Are you sure you want to delete \(trip.name)?")
                }
            }
            
            private func deleteTrip(_ trip: Trip) {
                if let index = tripStore.trips.firstIndex(where: { $0.id == trip.id }) {
                    // Delete associated image if it exists
                    if let imageName = trip.imageName {
                        let url = tripStore.getDocumentsDirectory().appendingPathComponent(imageName)
                        try? FileManager.default.removeItem(at: url)
                    }
                    
                    // Remove from trips array
                    tripStore.trips.remove(at: index)
                    
                    // Save the updated trips
                    tripStore.saveTrips()
                }
        
    }
}

// Trip Details Page
struct TripDetailsPage: View {
    @State var trip: Trip
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var router: TabRouter
    @State private var showEditTrip = false
    
    @State private var activeTab = 0
    @State private var showAddAccommodation = false
    
    var body: some View {
          NavigationView {
              ScrollView {
                  VStack(alignment: .leading, spacing: 0) {
                      // Updated Header Image section
                      ZStack(alignment: .bottomLeading) {
                          if let imageName = trip.imageName, let image = tripStore.loadImageFromDocuments(imageName: imageName) {
                              Image(uiImage: image)
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
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showEditTrip = true
                        }) {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .sheet(isPresented: $showEditTrip) {
                    EditTripPage(trip: $trip)
                        .environmentObject(tripStore)
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

struct EditTripPage: View {
    @Binding var trip: Trip
    @EnvironmentObject var tripStore: TripStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var tripName: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var budgetText: String
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    init(trip: Binding<Trip>) {
        self._trip = trip
        _tripName = State(initialValue: trip.wrappedValue.name)
        _startDate = State(initialValue: trip.wrappedValue.startDate)
        _endDate = State(initialValue: trip.wrappedValue.endDate)
        _budgetText = State(initialValue: String(format: "%.2f", trip.wrappedValue.budget))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Information")) {
                    TextField("Trip Name", text: $tripName)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                    TextField("Budget", text: $budgetText)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Trip Image")) {
                    Button(action: { showImagePicker = true }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        } else if let imageName = trip.imageName,
                                  let image = tripStore.loadImageFromDocuments(imageName: imageName) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        } else {
                            Text("Select Image")
                        }
                    }
                }
            }
            .navigationTitle("Edit Trip")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func saveChanges() {
        guard let budget = Double(budgetText) else { return }
        
        var imageName: String? = trip.imageName
        
        // Handle image changes
        if let selectedImage = selectedImage {
            // Delete old image if it exists
            if let oldImageName = trip.imageName {
                let url = tripStore.getDocumentsDirectory().appendingPathComponent(oldImageName)
                try? FileManager.default.removeItem(at: url)
            }
            
            // Save new image
            imageName = UUID().uuidString + ".jpg"
            tripStore.saveImageToDocuments(image: selectedImage, imageName: imageName!)
        }
        
        // Update trip
        trip.name = tripName
        trip.startDate = startDate
        trip.endDate = endDate
        trip.budget = budget
        trip.imageName = imageName
        
        // Update in trip store
        if let index = tripStore.trips.firstIndex(where: { $0.id == trip.id }) {
            tripStore.trips[index] = trip
            tripStore.saveTrips()
        }
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
            Map {
                            Marker(accommodation.name, coordinate: accommodation.coordinate.coordinate)
                        }
                        .frame(height: 120)
                        .cornerRadius(10)
                        .padding(.top, 8)
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


