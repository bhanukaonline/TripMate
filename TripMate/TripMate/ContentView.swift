//
//  ContentView.swift
//  TripMate
//
//  Created by Bhanuka on 4/22/25.
//

import SwiftUI

//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("TripMate( hi nee")
//        }
//        .padding()
//    }
//}
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
struct TripsPage: View {
    @EnvironmentObject var router: TabRouter

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

            VStack {
                Spacer()
                Text("list of trips")
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




struct Trip: Identifiable, Codable {
    let id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var imageData: Data?
    var budget: Double
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}




struct AddTripPage: View {
    @EnvironmentObject var router: TabRouter

    @State private var tripName = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var budgetText = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    @State private var savedTrips: [Trip] = [] // You can later persist this

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Add Trips",
                       leading: {
                           Button(action: {
                               router.currentTab = .home
                           }) { Image(systemName: "chevron.left") }
                       },
                       trailing: {
                           Button(action: saveTrip) {
                               Image(systemName: "square.and.arrow.down.fill")
                               Text("Save")
                           }
                       })

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Trip Name", text: $tripName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    Text("Start Date").foregroundColor(.white)
                    DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()

                    Text("End Date").foregroundColor(.white)
                    DatePicker("End", selection: $endDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()

                    TextField("Budget (LKR)", text: $budgetText)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    Button(action: { showImagePicker = true }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(10)
                        } else {
                            HStack {
                                Image(systemName: "photo")
                                Text("Upload Image")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
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
    }

    func saveTrip() {
        guard !tripName.isEmpty,
              let budget = Double(budgetText) else {
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

        savedTrips.append(newTrip)
        print("Trip saved: \(newTrip.name)")

        // Optional: clear form
        tripName = ""
        budgetText = ""
        selectedImage = nil
    }
}


struct MapPage: View {
    @EnvironmentObject var router: TabRouter

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Map",
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
                Text("Map here")
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

struct DiscoverPage: View {
    @EnvironmentObject var router: TabRouter

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Discover",
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
                Text("List of discover")
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
