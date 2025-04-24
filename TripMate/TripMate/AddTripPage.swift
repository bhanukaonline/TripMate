//
//  AddTripPage.swift
//  TripMate
//
//  Created by Bhanuka on 4/24/25.
//


import SwiftUI
import MapKit

// 1️⃣ AddTripPage with FAB and pop-up options:



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

struct AddAccommodationPage: View {
    @EnvironmentObject var router: TabRouter
    @EnvironmentObject var tripStore: TripStore

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


    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Name", text: $name)
                        .padding().background(Color.white).cornerRadius(8)

                    DatePicker("Check-In", selection: $checkIn)
                        .labelsHidden().datePickerStyle(.compact)
                    DatePicker("Check-Out", selection: $checkOut)
                        .labelsHidden().datePickerStyle(.compact)

                    // Location search + map
                    TextField("Search location", text: $searchQuery, onCommit: performSearch)
                        .padding().background(Color.white).cornerRadius(8)
                    Map(coordinateRegion: $region, annotationItems: selectedPlacemark.map { [$0] } ?? []) { placemark in
                        MapPin(coordinate: placemark.coordinate)
                    }

                    .frame(height: 200).cornerRadius(8)

                    TextField("Budget (LKR)", text: $budgetText)
                        .keyboardType(.decimalPad)
                        .padding().background(Color.white).cornerRadius(8)

                    TextEditor(text: $notes)
                        .frame(height: 100).padding().background(Color.white).cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Add Accommodation")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { router.currentTab = .trips }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveAccommodation() }
                }
            }
        }
    }

    private func performSearch() {
        let completer = MKLocalSearchCompleter()
        completer.queryFragment = searchQuery
        completer.resultTypes = .address
        completer.delegate = SearchDelegate { results in
            self.searchResults = results
        }
    }

    private func saveAccommodation() {
        // TODO: append to current trip’s accommodations
        router.currentTab = .trips
    }
}

// SearchDelegate helper for MKLocalSearchCompleter
class SearchDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var callback: ([MKLocalSearchCompletion]) -> Void
    init(_ cb: @escaping ([MKLocalSearchCompletion]) -> Void) { callback = cb }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        callback(completer.results)
    }
}
