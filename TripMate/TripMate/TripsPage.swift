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
    @State private var showAddActivity = false
    
    @State private var activeTab = 0
    @State private var showAddAccommodation = false
    @State private var showAddTransport = false
    
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
                .sheet(isPresented: $showAddAccommodation) {
                    AddAccommodationPage()
                        .environmentObject(tripStore)
                        .environmentObject(router)
                        // Reset the sheet state when dismissed
                        .onDisappear {
                            // Refresh the trip data after adding accommodation
                            if let index = tripStore.trips.firstIndex(where: { $0.id == trip.id }) {
                                trip = tripStore.trips[index]
                            }
                        }
                }
                .sheet(isPresented: $showAddTransport) {
                            AddTransportPage()
                                .environmentObject(tripStore)
                                .environmentObject(router)
                        }
                .sheet(isPresented: $showAddActivity) {
                    AddActivityPage()
                        .environmentObject(tripStore)
                        .environmentObject(router)
                        .onDisappear {
                            // Refresh the trip data after adding activity
                            if let index = tripStore.trips.firstIndex(where: { $0.id == trip.id }) {
                                trip = tripStore.trips[index]
                            }
                        }
                }
              
        }
          .onChange(of: tripStore.trips) { _ in
                      // Update the local trip state when the store changes
                      if let updatedTrip = tripStore.trips.first(where: { $0.id == trip.id }) {
                          trip = updatedTrip
                      }
                  }
        
    }
    private var transportView: some View {
           VStack(alignment: .leading, spacing: 16) {
               HStack {
                   Text("Transports")
                       .font(.title3)
                       .fontWeight(.bold)
                   
                   Spacer()
                   
                   Button(action: {
                       tripStore.selectedTripId = trip.id
                       showAddTransport = true
                   }) {
                       Label("Add", systemImage: "plus")
                           .font(.subheadline)
                           .padding(.horizontal, 12)
                           .padding(.vertical, 6)
                           .background(Color(hex: "#00485C"))
                           .cornerRadius(20)
                   }
               }
               
               if trip.transports.isEmpty {
                   EmptyStateView(
                       icon: "car",
                       title: "No Transports",
                       message: "Add your first transport by tapping the + button"
                   )
               } else {
                   ForEach(trip.transports) { transport in
                       TransportCard(transport: transport)
                   }
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
                    .foregroundColor(.white)
                
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
         VStack(alignment: .leading, spacing: 16) {
             HStack {
                 Text("Activities")
                     .font(.title3)
                     .fontWeight(.bold)
                     .foregroundColor(.white)
    
                 Spacer()
    
                 Button(action: {
                     tripStore.selectedTripId = trip.id
                     showAddActivity = true
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
    
             if trip.activities.isEmpty {
                 EmptyStateView(
                     icon: "figure.walk",
                     title: "No Activities Yet",
                     message: "Add your first activity by tapping the + button"
                 )
             } else {
                 // Map showing all activities
                 Map {
                     ForEach(trip.activities) { activity in
                         Marker(activity.name, coordinate: activity.coordinate.coordinate)
                             .tint(.green)
                     }
                 }
                 .frame(height: 200)
                 .cornerRadius(15)
                 .padding(.bottom, 10)
    
                 // List of activities
                 ForEach(trip.activities) { activity in
                     ActivityCard(activity: activity)
                 }
             }
         }
     }
    
    // Transport Tab Content
//    private var transportView: some View {
//        EmptyStateView(
//            icon: "airplane",
//            title: "No Transport Info",
//            message: "Add transport details for your trip"
//        )
//    }
    
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
        @EnvironmentObject var tripStore: TripStore
        @State private var showingDeleteAlert = false
    
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
                    
                    // Delete button
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
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
                .alert("Delete Accommodation", isPresented: $showingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        deleteAccommodation()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to delete \(accommodation.name)?")
                }
    }
    private func deleteAccommodation() {
            // Find the trip containing this accommodation
            if let tripIndex = tripStore.trips.firstIndex(where: { trip in
                trip.accommodations.contains(where: { $0.id == accommodation.id })
            }) {
                // Find the accommodation index in the trip's accommodations array
                if let accommodationIndex = tripStore.trips[tripIndex].accommodations.firstIndex(where: { $0.id == accommodation.id }) {
                    // Remove the accommodation
                    tripStore.trips[tripIndex].accommodations.remove(at: accommodationIndex)
                    
                    // Save the changes
                    tripStore.saveTrips()
                }
            }
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


enum TransportMode: String, CaseIterable, Codable {
    case bus = "bus"
    case train = "train"
    case taxi = "taxi"
    case airplane = "airplane"
}


struct AddTransportPage: View {
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var router: TabRouter
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var locationManager = LocationManager()
    
    @State private var mode: TransportMode = .bus
    @State private var dateTime = Date()
    @State private var budgetText = ""
    @State private var notes = ""
    
    // Start location search
    @State private var startSearchQuery = ""
    @State private var startSearchResults: [MKLocalSearchCompletion] = []
    @State private var startSelectedPlacemark: IdentifiablePlacemark?
    @State private var isStartSearching = false
    @State private var startRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // End location search
    @State private var endSearchQuery = ""
    @State private var endSearchResults: [MKLocalSearchCompletion] = []
    @State private var endSelectedPlacemark: IdentifiablePlacemark?
    @State private var isEndSearching = false
    @State private var endRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Completers
    @StateObject private var startCompleterDelegate = SearchCompleterDelegate()
    @StateObject private var endCompleterDelegate = SearchCompleterDelegate()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Transport mode
                    VStack(alignment: .leading) {
                                            Text("Transport Mode").font(.headline)
                                            
                                            // Make sure all transport modes are available
                                            Picker("Mode", selection: $mode) {
                                                ForEach(TransportMode.allCases, id: \.self) { mode in
                                                    HStack {
                                                        Image(systemName: iconForMode(mode))
//                                                        Text(mode.rawValue.capitalized)
                                                    }
                                                    .tag(mode)
                                                }
                                            }
                                            .pickerStyle(SegmentedPickerStyle())
                                        }
                                        .padding(.vertical, 8)
                    
                    // Date and time
                    DatePicker("Date & Time", selection: $dateTime)
                        .datePickerStyle(.compact)
                        .padding(.vertical, 8)
                    
                    // START LOCATION
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Location").font(.headline)
                        
                        TextField("Search start location", text: $startSearchQuery)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .onChange(of: startSearchQuery) { newValue in
                                if !newValue.isEmpty {
                                    isStartSearching = true
                                    startCompleterDelegate.completer.queryFragment = newValue
                                } else {
                                    isStartSearching = false
                                    startSearchResults = []
                                }
                            }
                        
                        if isStartSearching && !startSearchResults.isEmpty {
                            List {
                                ForEach(startSearchResults, id: \.self) { result in
                                    Button(action: {
                                        searchAndSelectStartPlacemark(result)
                                        isStartSearching = false
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(result.title)
                                                .font(.headline)
                                            Text(result.subtitle)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .frame(height: min(CGFloat(startSearchResults.count) * 60, 180))
                            .listStyle(PlainListStyle())
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                        
                        // Start location actions
                        HStack {
                            Button(action: useCurrentLocationForStart) {
                                Label("Current Location", systemImage: "location.fill")
                                    .padding(8)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            if startSelectedPlacemark != nil {
                                Button(action: {
                                    startSelectedPlacemark = nil
                                    startSearchQuery = ""
                                }) {
                                    Label("Clear", systemImage: "xmark.circle")
                                        .padding(8)
                                        .background(Color.red.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Start location map
                        MapViewContainer(
                            region: $startRegion,
                            selectedPlacemark: $startSelectedPlacemark,
                            searchQuery: $startSearchQuery
                        )
                        .frame(height: 150)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        if startSelectedPlacemark == nil {
                            Text("Tap on map to select start location")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // END LOCATION
                    VStack(alignment: .leading, spacing: 8) {
                        Text("End Location").font(.headline)
                        
                        TextField("Search end location", text: $endSearchQuery)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .onChange(of: endSearchQuery) { newValue in
                                if !newValue.isEmpty {
                                    isEndSearching = true
                                    endCompleterDelegate.completer.queryFragment = newValue
                                } else {
                                    isEndSearching = false
                                    endSearchResults = []
                                }
                            }
                        
                        if isEndSearching && !endSearchResults.isEmpty {
                            List {
                                ForEach(endSearchResults, id: \.self) { result in
                                    Button(action: {
                                        searchAndSelectEndPlacemark(result)
                                        isEndSearching = false
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(result.title)
                                                .font(.headline)
                                            Text(result.subtitle)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .frame(height: min(CGFloat(endSearchResults.count) * 60, 180))
                            .listStyle(PlainListStyle())
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                        
                        // End location actions
                        HStack {
                            Button(action: useCurrentLocationForEnd) {
                                Label("Current Location", systemImage: "location.fill")
                                    .padding(8)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            if endSelectedPlacemark != nil {
                                Button(action: {
                                    endSelectedPlacemark = nil
                                    endSearchQuery = ""
                                }) {
                                    Label("Clear", systemImage: "xmark.circle")
                                        .padding(8)
                                        .background(Color.red.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // End location map
                        MapViewContainer(
                            region: $endRegion,
                            selectedPlacemark: $endSelectedPlacemark,
                            searchQuery: $endSearchQuery
                        )
                        .frame(height: 150)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        if endSelectedPlacemark == nil {
                            Text("Tap on map to select end location")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Budget
                    TextField("Budget (LKR)", text: $budgetText)
                        .keyboardType(.decimalPad)
                        .padding().background(Color.white).cornerRadius(8)
                    
                    // Notes
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding()
            }
            .navigationTitle("Add Transport")
            .onAppear {
                // Configure completers
                startCompleterDelegate.completer.resultTypes = [.address, .pointOfInterest]
                startCompleterDelegate.onUpdate = { results in
                    self.startSearchResults = results
                }
                
                endCompleterDelegate.completer.resultTypes = [.address, .pointOfInterest]
                endCompleterDelegate.onUpdate = { results in
                    self.endSearchResults = results
                }
                
                // Initialize with user's location if available
                if let userLocation = locationManager.location?.coordinate {
                    startRegion = MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    endRegion = MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveTransport() }
                        .disabled(!isFormValid)
                }
            }
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        startSelectedPlacemark != nil && endSelectedPlacemark != nil && !budgetText.isEmpty
    }
    
    // Helper for mode icons
    private func iconForMode(_ mode: TransportMode) -> String {
        switch mode {
        case .bus: return "bus"
        case .taxi: return "car.fill"
        case .train: return "tram.fill"
        case .airplane: return "airplane"
        }
    }
    
    // Use current location for start
    private func useCurrentLocationForStart() {
        locationManager.requestLocation()
        
        if let userLocation = locationManager.location?.coordinate {
            let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    let mkPlacemark = MKPlacemark(
                        coordinate: userLocation,
                        addressDictionary: placemark.addressDictionary as? [String: Any]
                    )
                    startSelectedPlacemark = IdentifiablePlacemark(placemark: mkPlacemark)
                    
                    // Update region
                    startRegion = MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    
                    // Update search query
                    let locationName = [
                        placemark.name,
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea
                    ].compactMap { $0 }.joined(separator: ", ")
                    
                    startSearchQuery = locationName.isEmpty ?
                        "Location at \(userLocation.latitude), \(userLocation.longitude)" : locationName
                }
            }
        }
    }
    
    // Use current location for end
    private func useCurrentLocationForEnd() {
        locationManager.requestLocation()
        
        if let userLocation = locationManager.location?.coordinate {
            let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    let mkPlacemark = MKPlacemark(
                        coordinate: userLocation,
                        addressDictionary: placemark.addressDictionary as? [String: Any]
                    )
                    endSelectedPlacemark = IdentifiablePlacemark(placemark: mkPlacemark)
                    
                    // Update region
                    endRegion = MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    
                    // Update search query
                    let locationName = [
                        placemark.name,
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea
                    ].compactMap { $0 }.joined(separator: ", ")
                    
                    endSearchQuery = locationName.isEmpty ?
                        "Location at \(userLocation.latitude), \(userLocation.longitude)" : locationName
                }
            }
        }
    }
    
    // Search for start placemark
    private func searchAndSelectStartPlacemark(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let error = error {
                print("Location search error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response, let mapItem = response.mapItems.first else {
                print("No locations found")
                return
            }
            
            // Create placemark and update selection
            let identifiable = IdentifiablePlacemark(placemark: mapItem.placemark)
            startSelectedPlacemark = identifiable
            startSearchQuery = completion.title
            
            // Update map view
            startRegion = MKCoordinateRegion(
                center: identifiable.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    // Search for end placemark
    private func searchAndSelectEndPlacemark(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let error = error {
                print("Location search error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response, let mapItem = response.mapItems.first else {
                print("No locations found")
                return
            }
            
            // Create placemark and update selection
            let identifiable = IdentifiablePlacemark(placemark: mapItem.placemark)
            endSelectedPlacemark = identifiable
            endSearchQuery = completion.title
            
            // Update map view
            endRegion = MKCoordinateRegion(
                center: identifiable.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    // Save transport to trip
    private func saveTransport() {
        guard let tripId = tripStore.selectedTripId else {
            print("No trip selected")
            return
        }
        
        guard
            startSelectedPlacemark != nil,
            endSelectedPlacemark != nil,
            let budget = Double(budgetText)
        else {
            print("Validation failed")
            return
        }
        
        let newTransport = Transport(
            mode: mode,
            dateTime: dateTime,
            startLocation: startSearchQuery,
            startCoordinate: CodableCoordinate(coordinate: startSelectedPlacemark!.coordinate),
            endLocation: endSearchQuery,
            endCoordinate: CodableCoordinate(coordinate: endSelectedPlacemark!.coordinate),
            budget: budget,
            notes: notes
        )
        
        if let index = tripStore.trips.firstIndex(where: { $0.id == tripId }) {
            tripStore.trips[index].transports.append(newTransport)
            tripStore.saveTrips() // Persist the change
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct TransportCard: View {
    var transport: Transport
    @EnvironmentObject var tripStore: TripStore
    @State private var showingDeleteAlert = false
    @State private var routePolyline: MKPolyline?
    @State private var mapRegion: MKCoordinateRegion?
    @State private var isLoadingRoute = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: transportIcon)
                    .foregroundColor(transportColor)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading) {
                    Text(transport.mode.rawValue.capitalized)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(formattedDateTime) • \(transport.budget.formatted(.currency(code: "LKR")))")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "arrow.right")
                    Text("\(transport.startLocation) → \(transport.endLocation)")
                }
                
                // Add map view to show the route
                ZStack {
                    if let routePolyline = routePolyline, let mapRegion = mapRegion {
                        RouteMapView(polyline: routePolyline,
                                    startCoordinate: transport.startCoordinate.coordinate,
                                    endCoordinate: transport.endCoordinate.coordinate,
                                    region: mapRegion)
                            .frame(height: 150)
                            .cornerRadius(10)
                    }
                    
                    if isLoadingRoute {
                        VStack {
                            ProgressView()
                            Text("Loading route...")
                                .font(.caption)
                                .padding(.top, 4)
                        }
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.top, 8)
                
                if !transport.notes.isEmpty {
                    Text(transport.notes)
                        .font(.caption)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(hex: "#222222"))
        .cornerRadius(15)
        .alert("Delete Transport", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) { deleteTransport() }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            // For airplanes, show straight line immediately
            if transport.mode == .airplane {
                createStraightLineRoute(from: transport.startCoordinate.coordinate, to: transport.endCoordinate.coordinate)
                isLoadingRoute = false
            } else {
                calculateRoute()
            }
        }
    }
    
    private var transportIcon: String {
        switch transport.mode {
        case .bus: return "bus"
        case .train: return "tram"
        case .taxi: return "car"
        case .airplane: return "airplane"
        }
    }
    
    private var transportColor: Color {
        switch transport.mode {
        case .bus: return .blue
        case .train: return .green
        case .taxi: return .yellow
        case .airplane: return .purple
        }
    }
    
    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: transport.dateTime)
    }
    
    private func deleteTransport() {
        if let tripIndex = tripStore.trips.firstIndex(where: { $0.id == tripStore.selectedTripId }) {
            if let transportIndex = tripStore.trips[tripIndex].transports.firstIndex(where: { $0.id == transport.id }) {
                tripStore.trips[tripIndex].transports.remove(at: transportIndex)
                tripStore.saveTrips()
            }
        }
    }
    
    private func calculateRoute() {
        isLoadingRoute = true
        
        let startCoordinate = transport.startCoordinate.coordinate
        let endCoordinate = transport.endCoordinate.coordinate
        
        // Create a directions request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
        
        // Set transport type based on mode - make sure we get a road route
        switch transport.mode {
        case .bus:
            request.transportType = .transit
        case .train:
            request.transportType = .transit
        case .taxi:
            request.transportType = .automobile
        case .airplane:
            // For airplane we now use straight line (handled in onAppear)
            return
        }
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            isLoadingRoute = false
            
            guard let route = response?.routes.first else {
                print("Error calculating route: \(error?.localizedDescription ?? "Unknown error")")
                
                // Try again with automobile type as fallback for all transport types
                if transport.mode != .taxi {
                    retryWithAutomobileType()
                } else {
                    // If all else fails, try with any transport type
                    retryWithAnyTransportType()
                }
                return
            }
            
            // Successfully calculated route
            self.routePolyline = route.polyline
            
            // Calculate region that encompasses the route
            let rect = route.polyline.boundingMapRect
            let region = MKCoordinateRegion(rect)
            
            // Add some padding to the region
            let paddedRegion = MKCoordinateRegion(
                center: region.center,
                span: MKCoordinateSpan(
                    latitudeDelta: region.span.latitudeDelta * 1.2,
                    longitudeDelta: region.span.longitudeDelta * 1.2
                )
            )
            
            self.mapRegion = paddedRegion
        }
    }
    
    private func retryWithAutomobileType() {
        let startCoordinate = transport.startCoordinate.coordinate
        let endCoordinate = transport.endCoordinate.coordinate
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                print("Retry with automobile failed: \(error?.localizedDescription ?? "Unknown error")")
                retryWithAnyTransportType()
                return
            }
            
            self.routePolyline = route.polyline
            let rect = route.polyline.boundingMapRect
            let region = MKCoordinateRegion(rect)
            
            self.mapRegion = MKCoordinateRegion(
                center: region.center,
                span: MKCoordinateSpan(
                    latitudeDelta: region.span.latitudeDelta * 1.2,
                    longitudeDelta: region.span.longitudeDelta * 1.2
                )
            )
        }
    }
    
    private func retryWithAnyTransportType() {
        let startCoordinate = transport.startCoordinate.coordinate
        let endCoordinate = transport.endCoordinate.coordinate
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
        request.transportType = .any
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                print("All route calculations failed")
                // Fall back to straight line when all routing fails
                createStraightLineRoute(from: startCoordinate, to: endCoordinate)
                return
            }
            
            self.routePolyline = route.polyline
            let rect = route.polyline.boundingMapRect
            let region = MKCoordinateRegion(rect)
            
            self.mapRegion = MKCoordinateRegion(
                center: region.center,
                span: MKCoordinateSpan(
                    latitudeDelta: region.span.latitudeDelta * 1.2,
                    longitudeDelta: region.span.longitudeDelta * 1.2
                )
            )
        }
    }
    
    private func createStraightLineRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        // Create a straight line if route calculation fails or for airplane mode
        let coordinates = [start, end]
        self.routePolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        // Calculate a region that encompasses both points
        let minLat = min(start.latitude, end.latitude)
        let maxLat = max(start.latitude, end.latitude)
        let minLon = min(start.longitude, end.longitude)
        let maxLon = max(start.longitude, end.longitude)
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.4,
            longitudeDelta: (maxLon - minLon) * 1.4
        )
        
        self.mapRegion = MKCoordinateRegion(center: center, span: span)
    }
}

// The RouteMapView remains the same
struct RouteMapView: UIViewRepresentable {
    let polyline: MKPolyline
    let startCoordinate: CLLocationCoordinate2D
    let endCoordinate: CLLocationCoordinate2D
    let region: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        
        // Add the route
        mapView.addOverlay(polyline)
        
        // Add start and end annotations
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = startCoordinate
        startAnnotation.title = "Start"
        
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = endCoordinate
        endAnnotation.title = "End"
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Clear existing overlays and annotations
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        // Add the route
        uiView.addOverlay(polyline)
        
        // Add start and end annotations
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = startCoordinate
        startAnnotation.title = "Start"
        
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = endCoordinate
        endAnnotation.title = "End"
        
        uiView.addAnnotations([startAnnotation, endAnnotation])
        
        // Update region
        uiView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Pin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            // Configure pin color based on start/end
            if annotation.title == "Start" {
                annotationView?.markerTintColor = .green
            } else if annotation.title == "End" {
                annotationView?.markerTintColor = .red
            }
            
            return annotationView
        }
    }
}
