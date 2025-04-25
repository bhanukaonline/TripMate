//
//  RouteMapPreview.swift
//  TripMate
//
//  Created by Bhanuka on 4/26/25.
//
import SwiftUI
import MapKit

struct RouteMapPreview: UIViewRepresentable {
    let startCoordinate: CLLocationCoordinate2D
    let endCoordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Calculate region to show both points
        let region = regionThatFitsBothCoordinates()
        mapView.setRegion(region, animated: false)
        
        // Add start and end annotations
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = startCoordinate
        startAnnotation.title = "Start"
        
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = endCoordinate
        endAnnotation.title = "End"
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
        
        // Add a simple line
        let coordinates = [startCoordinate, endCoordinate]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // No updates needed for preview
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func regionThatFitsBothCoordinates() -> MKCoordinateRegion {
        let minLat = min(startCoordinate.latitude, endCoordinate.latitude)
        let maxLat = max(startCoordinate.latitude, endCoordinate.latitude)
        let minLon = min(startCoordinate.longitude, endCoordinate.longitude)
        let maxLon = max(startCoordinate.longitude, endCoordinate.longitude)
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.4,
            longitudeDelta: (maxLon - minLon) * 1.4
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// Timeline Card Component
struct TimelineItemCard: View {
    var item: any TimelineItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with basic info
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    // Timeline icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: item.iconColor).opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: item.iconName)
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: item.iconColor))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text(item.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text(formattedTime(item.date))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding()
                .background(Color(hex: "#222222"))
                .cornerRadius(isExpanded ? 12 : 12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded details
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Date spanning info if applicable
                    if let endDate = item.endDate {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Starts")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Text(formattedFullDate(item.date))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Ends")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Text(formattedFullDate(endDate))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                    
                    // Item-specific details
                    item.detailsView
                        .padding(.horizontal)
                }
                .padding(.bottom, 16)
                .background(Color(hex: "#2A2A2A"))
                .cornerRadius(12)
            }
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formattedFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Day Section for the timeline
struct DaySection: View {
    var day: Int
    var date: Date
    var items: [any TimelineItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Day header
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#00485C"))
                        .frame(width: 40, height: 40)
                    
                    Text("\(day)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading) {
                    Text("Day \(day)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(formattedDate(date))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            // Day timeline
            VStack(spacing: 16) {
                ForEach(0..<items.count, id: \.self) { index in
                    let item = items[index]
                    
                    TimelineItemCard(item: item)
                    
                    // Connector line if not the last item
                    if index < items.count - 1 {
                        VStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 2, height: 20)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "#333333"))
        .cornerRadius(16)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
}


struct TripTimelineView: View {
    var trip: Trip
    @State private var allItems: [any TimelineItem] = []
    @State private var dayGroups: [Int: [Date: [any TimelineItem]]] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if allItems.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No Itinerary Items",
                    message: "Add accommodations, activities, or transports to see your trip timeline"
                )
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(dayGroups.keys.sorted()), id: \.self) { day in
                            if let dateItems = dayGroups[day], let firstDate = dateItems.keys.sorted().first {
                                DaySection(
                                    day: day,
                                    date: firstDate,
                                    items: dateItems[firstDate]?.sorted(by: { $0.date < $1.date }) ?? []
                                )
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            organizeTimelineItems()
        }
    }
    
    private func organizeTimelineItems() {
        // Combine all items
        var items: [any TimelineItem] = []
        items.append(contentsOf: trip.accommodations)
        items.append(contentsOf: trip.activities)
        items.append(contentsOf: trip.transports)
        
        // Sort by date
        items.sort { $0.date < $1.date }
        
        self.allItems = items
        
        // Organize by day
        organizeByDay()
    }
    
    private func organizeByDay() {
        var groups: [Int: [Date: [any TimelineItem]]] = [:]
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: trip.startDate)
        
        for item in allItems {
            // Calculate the day number relative to trip start
            let itemDate = calendar.startOfDay(for: item.date)
            let components = calendar.dateComponents([.day], from: startDate, to: itemDate)
            let dayNumber = (components.day ?? 0) + 1 // Day 1, Day 2, etc.
            
            // Add to groups
            if groups[dayNumber] == nil {
                groups[dayNumber] = [itemDate: [item]]
            } else if groups[dayNumber]?[itemDate] == nil {
                groups[dayNumber]?[itemDate] = [item]
            } else {
                groups[dayNumber]?[itemDate]?.append(item)
            }
        }
        
        self.dayGroups = groups
    }
}
