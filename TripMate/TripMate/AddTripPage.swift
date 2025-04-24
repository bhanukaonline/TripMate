//
//  AddTripPage.swift
//  TripMate
//
//  Created by Bhanuka on 4/24/25.
//


import SwiftUI
import MapKit

// 1️⃣ AddTripPage with FAB and pop-up options:

import CoreLocation

class TripStore: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var selectedTripId: UUID? // ✅ for tracking selected trip
}


struct CodableCoordinate: Codable {
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

struct Accommodation: Identifiable, Codable {
    let id = UUID()
    var name: String
    var checkIn: Date
    var checkOut: Date
    var coordinate: CodableCoordinate
    var budget: Double
    var notes: String
}


struct Trip: Identifiable, Codable {
    let id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var imageData: Data?
    var budget: Double
    var accommodations: [Accommodation] = []
}


struct IdentifiablePlacemark: Identifiable {
    let id = UUID()
    let placemark: MKPlacemark

    var coordinate: CLLocationCoordinate2D {
        placemark.coordinate
    }

    var title: String {
        placemark.name ?? ""
    }
}
struct AddTripPage: View {
    @EnvironmentObject var router: TabRouter
    @EnvironmentObject var tripStore: TripStore

    // existing form state…
    @State private var tripName = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var budgetText = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    // NEW: FAB state
    @State private var showOptions = false
    @State private var showAddAccommodation = false

    var body: some View {
        ZStack {
            // ▶️ Main content
            VStack(spacing: 0) {
                HeaderView(title: "Add Trips",
                           leading: {
                               Button(action: { router.currentTab = .home }) {
                                   Image(systemName: "chevron.left")
                               }
                           },
                           trailing: {
                               Button(action: saveTrip) {
                                   Image(systemName: "square.and.arrow.down.fill")
                                   Text("Save")
                               }
                           })

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // … your existing inputs …
                        TextField("Trip Name", text: $tripName)
                            .padding().background(Color.white).cornerRadius(8)

                        DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                        DatePicker("End Date",   selection: $endDate,   displayedComponents: [.date])
                            .datePickerStyle(.compact)

                        TextField("Budget (LKR)", text: $budgetText)
                            .keyboardType(.decimalPad)
                            .padding().background(Color.white).cornerRadius(8)

                        Button(action: { showImagePicker = true }) {
                            if let img = selectedImage {
                                Image(uiImage: img)
                                    .resizable().scaledToFit().frame(height:150).cornerRadius(8)
                            } else {
                                HStack { Image(systemName:"photo"); Text("Upload Image") }
                                  .padding().frame(maxWidth:.infinity)
                                  .background(Color.white).cornerRadius(8)
                            }
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }

            // ▶️ Floating Action Button + pop-up options
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        // Option buttons
                        if showOptions {
                            VStack(spacing: 16) {
                                Button(action: {
                                    // TODO: activity
                                }) {
                                    Label("Activity", systemImage: "figure.walk")
                                        .padding().background(Color.blue).cornerRadius(30).foregroundColor(.white)
                                }
                                Button(action: {
                                    // TODO: transport
                                }) {
                                    Label("Transport", systemImage: "car.fill")
                                        .padding().background(Color.blue).cornerRadius(30).foregroundColor(.white)
                                }
                                Button(action: {
                                    showAddAccommodation = true
                                }) {
                                    Label("Accommodation", systemImage: "bed.double.fill")
                                        .padding().background(Color.blue).cornerRadius(30).foregroundColor(.white)
                                }
                            }
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .zIndex(1)
                        }

                        // Main FAB
                        Button(action: {
                            withAnimation { showOptions.toggle() }
                        }) {
                            Image(systemName: showOptions ? "xmark" : "plus")
                                .font(.system(size: 24)).foregroundColor(.white)
                                .padding().background(Color.red).clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
            }
        }
        // ▶️ Present AddAccommodationPage
        .sheet(isPresented: $showAddAccommodation) {
            AddAccommodationPage()
                .environmentObject(tripStore)
                .environmentObject(router)
        }
    }

    func saveTrip() {
        guard !tripName.isEmpty, let budget = Double(budgetText) else {
            print("Validation failed")
            return
        }

        let newTrip = Trip(
            name: tripName,
            startDate: startDate,
            endDate: endDate,
            imageData: selectedImage?.jpegData(compressionQuality: 0.8),
            budget: budget
        )

       
        tripStore.trips.append(newTrip)
        tripStore.selectedTripId = newTrip.id

        print("Trip saved: \(newTrip.name)")

        // Navigate to trips page
        router.currentTab = .trips

        // Optionally reset fields
        tripName = ""
        budgetText = ""
        selectedImage = nil
    }

}



// 2️⃣ AddAccommodationPage

// Fix for the AddAccommodationPage focusing on map search and selection issues

struct AddAccommodationPage: View {
    @EnvironmentObject var router: TabRouter
    @EnvironmentObject var tripStore: TripStore
    @StateObject private var locationManager = LocationManager()

    @State private var name = ""
    @State private var checkIn = Date()
    @State private var checkOut = Date()
    @State private var budgetText = ""
    @State private var notes = ""

    // Map search / pin
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchQuery = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var selectedPlacemark: IdentifiablePlacemark?
    @State private var isSearching = false
    @State private var mapView = MKMapView()

    // A coordinator to handle map interactions
    private let completer = MKLocalSearchCompleter()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Name", text: $name)
                        .padding().background(Color.white).cornerRadius(8)

                    DatePicker("Check-In", selection: $checkIn)
                        .datePickerStyle(.compact)

                    DatePicker("Check-Out", selection: $checkOut)
                        .datePickerStyle(.compact)

                    // Improved location search section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location").font(.headline)
                        
                        TextField("Search location", text: $searchQuery)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .onChange(of: searchQuery) { newValue in
                                if !newValue.isEmpty {
                                    isSearching = true
                                    completer.queryFragment = newValue
                                } else {
                                    isSearching = false
                                    searchResults = []
                                }
                            }
                        
                        if isSearching && !searchResults.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(searchResults, id: \.self) { result in
                                        Button(action: {
                                            searchAndSelectPlacemark(result)
                                            isSearching = false
                                            searchQuery = result.title
                                        }) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(result.title)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Text(result.subtitle)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                Divider()
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .contentShape(Rectangle())
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            .frame(height: min(CGFloat(searchResults.count) * 60, 180))
                        }
                        
                        // Location action buttons
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
                    }

                    // Map View with MapViewCoordinator
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
                        Text("Tap on the map to select a location")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }

                    TextField("Budget (LKR)", text: $budgetText)
                        .keyboardType(.decimalPad)
                        .padding().background(Color.white).cornerRadius(8)

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
            .navigationTitle("Add Accommodation")
            .onAppear {
                // Setup completer for search results
                completer.resultTypes = .pointOfInterest
                completer.delegate = SearchCompleterDelegate(callback: { results in
                    self.searchResults = results
                })
                
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
                    Button("Cancel") { router.currentTab = .trips }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveAccommodation() }
                        .disabled(selectedPlacemark == nil || name.isEmpty || budgetText.isEmpty)
                }
            }
        }
    }
    
    // Use current device location
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
                    
                    // Update search query with readable location name
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

    // Search for placemark from completion and select it
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
            
            // Update map view
            region = MKCoordinateRegion(
                center: identifiable.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }

    // Save accommodation into selected trip
    private func saveAccommodation() {
        guard let tripId = tripStore.selectedTripId else {
            print("No trip selected")
            return
        }

        guard
            !name.isEmpty,
            let budget = Double(budgetText),
            let selectedPlacemark = selectedPlacemark
        else {
            print("Validation failed")
            return
        }

        let newAccommodation = Accommodation(
            name: name,
            checkIn: checkIn,
            checkOut: checkOut,
            coordinate: CodableCoordinate(coordinate: selectedPlacemark.coordinate),
            budget: budget,
            notes: notes
        )

        if let index = tripStore.trips.firstIndex(where: { $0.id == tripId }) {
            tripStore.trips[index].accommodations.append(newAccommodation)
            print("Accommodation added to trip: \(tripStore.trips[index].name)")
        } else {
            print("Trip not found")
        }

        // Go back to trip list
        router.currentTab = .trips
    }
}

// MARK: - Map View Container with UIViewRepresentable

struct MapViewContainer: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedPlacemark: IdentifiablePlacemark?
    @Binding var searchQuery: String
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update region
        mapView.setRegion(region, animated: true)
        
        // Clear existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Add annotation for selected placemark
        if let placemark = selectedPlacemark {
            let annotation = MKPointAnnotation()
            annotation.coordinate = placemark.coordinate
            annotation.title = placemark.title.isEmpty ? "Selected Location" : placemark.title
            mapView.addAnnotation(annotation)
            
            // Select annotation to show callout
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator to handle map interactions
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewContainer
        
        init(_ parent: MapViewContainer) {
            self.parent = parent
        }
        
        // Handle map tap gesture
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                let mapView = gestureRecognizer.view as! MKMapView
                let point = gestureRecognizer.location(in: mapView)
                let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                
                // Update region
                let region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                parent.region = region
                
                // Perform reverse geocoding
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let geocoder = CLGeocoder()
                
                geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        if let placemark = placemarks?.first {
                            let mkPlacemark = MKPlacemark(
                                coordinate: coordinate,
                                addressDictionary: placemark.addressDictionary as? [String: Any]
                            )
                            
                            self.parent.selectedPlacemark = IdentifiablePlacemark(placemark: mkPlacemark)
                            
                            // Update search query with location name
                            let locationName = [
                                placemark.name,
                                placemark.thoroughfare,
                                placemark.locality,
                                placemark.administrativeArea
                            ].compactMap { $0 }.joined(separator: ", ")
                            
                            self.parent.searchQuery = locationName.isEmpty ?
                                "Location at \(coordinate.latitude), \(coordinate.longitude)" : locationName
                        } else {
                            // If no placemark is found, create a basic one
                            let mkPlacemark = MKPlacemark(coordinate: coordinate)
                            self.parent.selectedPlacemark = IdentifiablePlacemark(placemark: mkPlacemark)
                            self.parent.searchQuery = "Location at \(coordinate.latitude), \(coordinate.longitude)"
                        }
                    }
                }
            }
        }
        
        // Customize annotation view
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            
            let identifier = "CustomPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        // Update region when annotation is selected
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            if annotation is MKUserLocation { return }
            
            let region = MKCoordinateRegion(
                center: annotation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            parent.region = region
        }
    }
}

// MARK: - Search Completer Delegate

class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var callback: ([MKLocalSearchCompletion]) -> Void
    
    init(callback: @escaping ([MKLocalSearchCompletion]) -> Void) {
        self.callback = callback
        super.init()
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        callback(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
        callback([])
    }
}

// MARK: - Location Manager for Current Location

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var status: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}
