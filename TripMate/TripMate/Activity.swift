//
//  Activity.swift
//  TripMate
//
//  Created by Bhanuka on 4/25/25.
//
import SwiftUI
import MapKit
// 1. First, add the Activity model



// 2. Update the Trip model to include activities
// Add this to your Trip struct:
// var activities: [Activity] = []

// 3. Activity Card Component
struct ActivityCard: View {
    var activity: Activity
    @EnvironmentObject var tripStore: TripStore
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(Color(hex: "#4CAF50"))
                    .font(.system(size: 24))
                
                VStack(alignment: .leading) {
                    Text(activity.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(formattedDateTime) • \(activity.budget.formatted(.currency(code: "LKR")))")
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Location: \(activity.location)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                if !activity.notes.isEmpty {
                    Text(activity.notes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 4)
                }
            }
            
            Map {
                Marker(activity.location, coordinate: activity.coordinate.coordinate)
            }
            .frame(height: 120)
            .cornerRadius(10)
            .padding(.top, 8)
        }
        .padding()
        .background(Color(hex: "#222222"))
        .cornerRadius(15)
        .alert("Delete Activity", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteActivity()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(activity.name)?")
        }
    }
    
    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: activity.dateTime)
    }
    
    private func deleteActivity() {
        // Find the trip containing this activity
        if let tripIndex = tripStore.trips.firstIndex(where: { trip in
            trip.activities.contains(where: { $0.id == activity.id })
        }) {
            // Find the activity index in the trip's activities array
            if let activityIndex = tripStore.trips[tripIndex].activities.firstIndex(where: { $0.id == activity.id }) {
                // Remove the activity
                tripStore.trips[tripIndex].activities.remove(at: activityIndex)
                
                // Save the changes
                tripStore.saveTrips()
            }
        }
    }
}

// 4. Add Activity Page
struct AddActivityPage: View {
    @EnvironmentObject var tripStore: TripStore
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var locationManager = LocationManager()
    
    @State private var activityName = ""
    @State private var dateTime = Date()
    @State private var budgetText = ""
    @State private var notes = ""
    
    // Location search
    @State private var searchQuery = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var selectedPlacemark: IdentifiablePlacemark?
    @State private var isSearching = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Search completer
    @StateObject private var completerDelegate = SearchCompleterDelegate()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Activity name
                    VStack(alignment: .leading) {
                        Text("Activity Name").font(.headline)
                        TextField("Enter activity name", text: $activityName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
                    
                    // Date and time
                    DatePicker("Date & Time", selection: $dateTime)
                        .datePickerStyle(.compact)
                        .padding(.vertical, 8)
                    
                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location").font(.headline)
                        
                        TextField("Search location", text: $searchQuery)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .onChange(of: searchQuery) { newValue in
                                if !newValue.isEmpty {
                                    isSearching = true
                                    completerDelegate.completer.queryFragment = newValue
                                } else {
                                    isSearching = false
                                    searchResults = []
                                }
                            }
                        
                        if isSearching && !searchResults.isEmpty {
                            List {
                                ForEach(searchResults, id: \.self) { result in
                                    Button(action: {
                                        searchAndSelectPlacemark(result)
                                        isSearching = false
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
                            .frame(height: min(CGFloat(searchResults.count) * 60, 180))
                            .listStyle(PlainListStyle())
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                        
                        // Location actions
                        HStack {
                            Button(action: useCurrentLocation) {
                                Label("Current Location", systemImage: "location.fill")
                                    .padding(8)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            if selectedPlacemark != nil {
                                Button(action: {
                                    selectedPlacemark = nil
                                    searchQuery = ""
                                }) {
                                    Label("Clear", systemImage: "xmark.circle")
                                        .padding(8)
                                        .background(Color.red.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Location map
                        MapViewContainer(
                            region: $region,
                            selectedPlacemark: $selectedPlacemark,
                            searchQuery: $searchQuery
                        )
                        .frame(height: 200)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        if selectedPlacemark == nil {
                            Text("Tap on map to select location")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Budget
                    VStack(alignment: .leading) {
                        Text("Budget").font(.headline)
                        TextField("Budget (LKR)", text: $budgetText)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
                    
                    // Notes
                    VStack(alignment: .leading) {
                        Text("Notes (Optional)").font(.headline)
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
                    .padding(.vertical, 8)
                }
                .padding()
            }
            .navigationTitle("Add Activity")
            .onAppear {
                // Configure completer
                completerDelegate.completer.resultTypes = [.address, .pointOfInterest]
                completerDelegate.onUpdate = { results in
                    self.searchResults = results
                }
                
                // Initialize with user's location if available
                if let userLocation = locationManager.location?.coordinate {
                    region = MKCoordinateRegion(
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
                    Button("Save") { saveActivity() }
                        .disabled(!isFormValid)
                }
            }
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        !activityName.isEmpty && selectedPlacemark != nil && !budgetText.isEmpty
    }
    
    // Use current location
    private func useCurrentLocation() {
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
                    selectedPlacemark = IdentifiablePlacemark(placemark: mkPlacemark)
                    
                    // Update region
                    region = MKCoordinateRegion(
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
                    
                    searchQuery = locationName.isEmpty ?
                        "Location at \(userLocation.latitude), \(userLocation.longitude)" : locationName
                }
            }
        }
    }
    
    // Search for placemark
    private func searchAndSelectPlacemark(_ completion: MKLocalSearchCompletion) {
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
            selectedPlacemark = identifiable
            searchQuery = completion.title
            
            // Update map view
            region = MKCoordinateRegion(
                center: identifiable.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    // Save activity to trip
    private func saveActivity() {
        guard let tripId = tripStore.selectedTripId else {
            print("No trip selected")
            return
        }
        
        guard
            !activityName.isEmpty,
            selectedPlacemark != nil,
            let budget = Double(budgetText)
        else {
            print("Validation failed")
            return
        }
        
        let newActivity = Activity(
            name: activityName,
            dateTime: dateTime,
            location: searchQuery,
            coordinate: CodableCoordinate(coordinate: selectedPlacemark!.coordinate),
            budget: budget,
            notes: notes
        )
        
        if let index = tripStore.trips.firstIndex(where: { $0.id == tripId }) {
            tripStore.trips[index].activities.append(newActivity)
            tripStore.saveTrips() // Persist the change
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// 5. Update TripDetailsPage's activitiesView
// Replace the current activitiesView in TripDetailsPage with this:

// private var activitiesView: some View {
//     VStack(alignment: .leading, spacing: 16) {
//         HStack {
//             Text("Activities")
//                 .font(.title3)
//                 .fontWeight(.bold)
//                 .foregroundColor(.white)
//             
//             Spacer()
//             
//             Button(action: {
//                 tripStore.selectedTripId = trip.id
//                 showAddActivity = true
//             }) {
//                 Label("Add", systemImage: "plus")
//                     .font(.subheadline)
//                     .padding(.horizontal, 12)
//                     .padding(.vertical, 6)
//                     .background(Color(hex: "#00485C"))
//                     .cornerRadius(20)
//                     .foregroundColor(.white)
//             }
//         }
//         
//         if trip.activities.isEmpty {
//             EmptyStateView(
//                 icon: "figure.walk",
//                 title: "No Activities Yet",
//                 message: "Add your first activity by tapping the + button"
//             )
//         } else {
//             // Map showing all activities
//             Map {
//                 ForEach(trip.activities) { activity in
//                     Marker(activity.name, coordinate: activity.coordinate.coordinate)
//                         .tint(.green)
//                 }
//             }
//             .frame(height: 200)
//             .cornerRadius(15)
//             .padding(.bottom, 10)
//             
//             // List of activities
//             ForEach(trip.activities) { activity in
//                 ActivityCard(activity: activity)
//             }
//         }
//     }
// }

// 6. Update TripDetailsPage with necessary state variables and sheet
// Add these to TripDetailsPage:
// @State private var showAddActivity = false
//
// Then add this sheet after the other sheets in TripDetailsPage:
// .sheet(isPresented: $showAddActivity) {
//     AddActivityPage()
//         .environmentObject(tripStore)
//         .environmentObject(router)
//         .onDisappear {
//             // Refresh the trip data after adding activity
//             if let index = tripStore.trips.firstIndex(where: { $0.id == trip.id }) {
//                 trip = tripStore.trips[index]
//             }
//         }
// }
