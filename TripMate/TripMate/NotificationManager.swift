//
//  NotificationManager.swift
//  TripMate
//
//  Created by Bhanuka on 4/26/25.
//


import SwiftUI
import UserNotifications
import EventKit

// MARK: - Notification Manager
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotifications(for trip: Trip) {
        // Clear any existing notifications for this trip
        cancelNotifications(for: trip)
        
        // Schedule pre-trip reminder (3 days before)
        schedulePreTripReminder(for: trip)
        
        // Schedule day-before reminder
        scheduleDayBeforeReminder(for: trip)
        
        // Schedule departure reminder
        scheduleDepartureReminder(for: trip)
        
        // Schedule return reminder
        scheduleReturnReminder(for: trip)
    }
    
    private func schedulePreTripReminder(for trip: Trip) {
        let calendar = Calendar.current
        if let preTripReminderDate = calendar.date(byAdding: .day, value: -3, to: trip.startDate) {
            if preTripReminderDate > Date() {
                let content = UNMutableNotificationContent()
                content.title = "Upcoming Trip: \(trip.name)"
                content.body = "Your trip to \(trip.name) is coming up in 3 days. Time to start packing!"
                content.sound = .default
                content.badge = 1
                content.userInfo = ["tripId": trip.id.uuidString]
                
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: preTripReminderDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let request = UNNotificationRequest(identifier: "pretrip-\(trip.id.uuidString)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    private func scheduleDayBeforeReminder(for trip: Trip) {
        let calendar = Calendar.current
        if let dayBeforeDate = calendar.date(byAdding: .day, value: -1, to: trip.startDate) {
            if dayBeforeDate > Date() {
                let content = UNMutableNotificationContent()
                content.title = "Trip Tomorrow: \(trip.name)"
                content.body = "Your trip to \(trip.name) starts tomorrow. Make sure you're ready!"
                content.sound = .default
                content.badge = 1
                content.userInfo = ["tripId": trip.id.uuidString]
                
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dayBeforeDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let request = UNNotificationRequest(identifier: "daybefore-\(trip.id.uuidString)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    private func scheduleDepartureReminder(for trip: Trip) {
        if trip.startDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Trip Starting Today: \(trip.name)"
            content.body = "Your trip to \(trip.name) begins today. Have a great journey!"
            content.sound = .default
            content.badge = 1
            content.userInfo = ["tripId": trip.id.uuidString]
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: trip.startDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: "departure-\(trip.id.uuidString)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    private func scheduleReturnReminder(for trip: Trip) {
        if trip.endDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Trip Ending: \(trip.name)"
            content.body = "Your trip to \(trip.name) ends today. We hope you had a wonderful time!"
            content.sound = .default
            content.badge = 1
            content.userInfo = ["tripId": trip.id.uuidString]
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: trip.endDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: "return-\(trip.id.uuidString)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func cancelNotifications(for trip: Trip) {
        let identifiers = [
            "pretrip-\(trip.id.uuidString)",
            "daybefore-\(trip.id.uuidString)",
            "departure-\(trip.id.uuidString)",
            "return-\(trip.id.uuidString)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Calendar Manager
class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()
    @Published var calendarAccessGranted = false
    
    init() {
        checkCalendarAuthorization()
    }
    
    func checkCalendarAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            self.calendarAccessGranted = true
        case .notDetermined:
            requestAccess()
        case .denied, .restricted:
            self.calendarAccessGranted = false
        @unknown default:
            self.calendarAccessGranted = false
        }
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.calendarAccessGranted = granted
                if granted {
                    print("Calendar access granted")
                } else if let error = error {
                    print("Calendar access error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addTripToCalendar(trip: Trip) -> Bool {
        guard calendarAccessGranted else {
            print("Calendar access not granted")
            return false
        }
        
        // First remove any existing events for this trip
        removeFromCalendar(trip: trip)
        
        // Create the event
        let event = EKEvent(eventStore: eventStore)
        event.title = "Trip: \(trip.name)"
        event.startDate = trip.startDate
        event.endDate = trip.endDate
        event.notes = "Budget: LKR \(String(format: "%.2f", trip.budget))"
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Add trip ID to event for future reference
        event.addAlarm(EKAlarm(relativeOffset: -86400)) // 1 day before
        
        // Save the event
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            saveTripEventIdentifier(tripId: trip.id.uuidString, eventId: event.eventIdentifier)
            return true
        } catch {
            print("Error saving event: \(error.localizedDescription)")
            return false
        }
    }
    
    func removeFromCalendar(trip: Trip) {
        guard calendarAccessGranted, let eventId = getTripEventIdentifier(tripId: trip.id.uuidString) else {
            return
        }
        
        if let event = try? eventStore.event(withIdentifier: eventId) {
            do {
                try eventStore.remove(event, span: .thisEvent, commit: true)
                removeTripEventIdentifier(tripId: trip.id.uuidString)
            } catch {
                print("Error removing event: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper methods to store event IDs with trip IDs
    private func saveTripEventIdentifier(tripId: String, eventId: String) {
        UserDefaults.standard.set(eventId, forKey: "trip_event_\(tripId)")
    }
    
    public func getTripEventIdentifier(tripId: String) -> String? {
        return UserDefaults.standard.string(forKey: "trip_event_\(tripId)")
    }
    
    private func removeTripEventIdentifier(tripId: String) {
        UserDefaults.standard.removeObject(forKey: "trip_event_\(tripId)")
    }
}

// MARK: - TripStore Extension
extension TripStore {
    func addTrip(trip: Trip) {
        // Add trip to store
        trips.append(trip)
        saveTrips()
        
        // Schedule notifications
        NotificationManager.shared.scheduleNotifications(for: trip)
        
        // Add to calendar
        _ = CalendarManager.shared.addTripToCalendar(trip: trip)
    }
    
    func updateTrip(trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            saveTrips()
            
            // Update notifications
            NotificationManager.shared.scheduleNotifications(for: trip)
            
            // Update calendar event
            _ = CalendarManager.shared.addTripToCalendar(trip: trip)
        }
    }
    
    func deleteTrip(trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            // Delete associated image if it exists
            if let imageName = trip.imageName {
                let url = getDocumentsDirectory().appendingPathComponent(imageName)
                try? FileManager.default.removeItem(at: url)
            }
            
            // Cancel notifications
            NotificationManager.shared.cancelNotifications(for: trip)
            
            // Remove from calendar
            CalendarManager.shared.removeFromCalendar(trip: trip)
            
            // Remove from trips array
            trips.remove(at: index)
            
            // Save the updated trips
            saveTrips()
        }
    }
}

// MARK: - App Delegate for Push Notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Reset badge count
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               willPresent notification: UNNotification, 
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show alert and play sound even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               didReceive response: UNNotificationResponse, 
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let tripIdString = userInfo["tripId"] as? String, 
           let tripId = UUID(uuidString: tripIdString) {
            // Store the trip ID to navigate to when app opens/resumes
            UserDefaults.standard.set(tripIdString, forKey: "notificationTripId")
            
            // Post notification that app should navigate to trip details
            NotificationCenter.default.post(name: NSNotification.Name("OpenTripDetails"), object: nil, userInfo: ["tripId": tripId])
        }
        
        // Reset badge count
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler()
    }
}

// MARK: - Trip Calendar Integration View
struct TripCalendarIntegrationView: View {
    var trip: Trip
    @ObservedObject private var calendarManager = CalendarManager.shared
    @State private var isInCalendar: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(Color(hex: "#00B4D8"))
                
                Text("Calendar Integration")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if calendarManager.calendarAccessGranted {
                HStack {
                    Toggle("Add to iPhone Calendar", isOn: $isInCalendar)
                        .foregroundColor(.white)
                        .onChange(of: isInCalendar) { newValue in
                            if newValue {
                                addToCalendar()
                            } else {
                                removeFromCalendar()
                            }
                        }
                }
            } else {
                Button(action: {
                    calendarManager.requestAccess()
                }) {
                    Text("Grant Calendar Access")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color(hex: "#00485C"))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(hex: "#2A2A2A"))
        .cornerRadius(12)
        .onAppear {
            checkCalendarStatus()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Calendar"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func checkCalendarStatus() {
        if let eventId = CalendarManager.shared.getTripEventIdentifier(tripId: trip.id.uuidString) {
            isInCalendar = true
        } else {
            isInCalendar = false
        }
    }
    
    private func addToCalendar() {
        if CalendarManager.shared.addTripToCalendar(trip: trip) {
            alertMessage = "Trip added to calendar successfully"
            showingAlert = true
        } else {
            isInCalendar = false
            alertMessage = "Failed to add trip to calendar"
            showingAlert = true
        }
    }
    
    private func removeFromCalendar() {
        CalendarManager.shared.removeFromCalendar(trip: trip)
        alertMessage = "Trip removed from calendar"
        showingAlert = true
    }
}

// MARK: - Trip Notification Settings View
struct TripNotificationSettingsView: View {
    var trip: Trip
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var notificationsEnabled = true
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "#00B4D8"))
                
                Text("Notification Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Toggle("Trip Reminders", isOn: $notificationsEnabled)
                .foregroundColor(.white)
                .onChange(of: notificationsEnabled) { newValue in
                    if newValue {
                        enableNotifications()
                    } else {
                        disableNotifications()
                    }
                }
            
            if notificationsEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    NotificationTypeRow(icon: "calendar.badge.clock", text: "3 days before trip")
                    NotificationTypeRow(icon: "calendar.badge.clock", text: "1 day before trip")
                    NotificationTypeRow(icon: "airplane.departure", text: "Day of departure")
                    NotificationTypeRow(icon: "airplane.arrival", text: "Day of return")
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(Color(hex: "#2A2A2A"))
        .cornerRadius(12)
        .onAppear {
            checkNotificationStatus()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Notifications"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let tripRequests = requests.filter { $0.identifier.contains(trip.id.uuidString) }
            DispatchQueue.main.async {
                notificationsEnabled = !tripRequests.isEmpty
            }
        }
    }
    
    private func enableNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    notificationManager.scheduleNotifications(for: trip)
                    alertMessage = "Trip notifications enabled"
                    showingAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    notificationManager.requestAuthorization()
                    alertMessage = "Please enable notifications in Settings"
                    showingAlert = true
                }
            }
        }
    }
    
    private func disableNotifications() {
        notificationManager.cancelNotifications(for: trip)
        alertMessage = "Trip notifications disabled"
        showingAlert = true
    }
}

struct NotificationTypeRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#00B4D8").opacity(0.7))
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}
