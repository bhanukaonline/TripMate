//
//  UserAccountPage.swift
//  TripMate
//
//  Created by Bhanuka on 4/26/25.
//


import SwiftUI

struct UserAccountPage: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var router: TabRouter
    @State private var showingLogoutAlert = false
    @State private var showingEditProfile = false
    
    // User profile information - would come from a user model in a real app
    let username = "Bhanuka Seneviratne"
    let email = "bhanuka76@gmail.com"
    let memberSince = "January 2023"
    let avatarImage = "person.circle.fill" // Using system image as placeholder
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(hex: "#383838").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Custom navigation bar
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("My Account")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#00485C"))
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Profile header
                            ProfileHeaderView(username: username, email: email, avatarImage: avatarImage)
                            
                            // Stats section
                            StatsView()
                            
                            // Account settings
                            AccountSettingsView(showingLogoutAlert: $showingLogoutAlert)
                            
                            // App info
                            AppInfoView()
                        }
                        .padding(.bottom, 30)
                    }
                }
                .navigationBarHidden(true)
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out of your account?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        // Handle sign out logic here
                        print("User signed out")
                        // After signing out, you might want to navigate to a login screen
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// Profile header component
struct ProfileHeaderView: View {
    var username: String
    var email: String
    var avatarImage: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile image
            Image(systemName: avatarImage)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .frame(width: 120, height: 120)
                .background(Color(hex: "#2A2A2A"))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: "#00485C"), lineWidth: 4)
                )
                .padding(.top, 20)
            
            // User info
            VStack(spacing: 4) {
                Text(username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Premium badge
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(hex: "#FFD700"))
                
                Text("Premium Member")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#FFD700"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: "#FFD700").opacity(0.15))
            .cornerRadius(12)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal)
                .padding(.top, 8)
        }
    }
}

// User stats component
struct StatsView: View {
    var body: some View {
        HStack(spacing: 0) {
            StatItem(value: "8", label: "Trips", icon: "airplane.circle.fill")
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.1))
            
            StatItem(value: "12", label: "Countries", icon: "globe")
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.1))
            
            StatItem(value: "87", label: "Days", icon: "calendar")
        }
        .padding(.vertical, 16)
        .background(Color(hex: "#2A2A2A"))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Individual stat item
struct StatItem: View {
    var value: String
    var label: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#00B4D8"))
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// Account settings section
struct AccountSettingsView: View {
    @Binding var showingLogoutAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Settings")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                SettingsItem(icon: "person.fill", title: "Personal Information", color: "#4CAF50")
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                SettingsItem(icon: "creditcard", title: "Payment Methods", color: "#2196F3")
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                SettingsItem(icon: "bell.fill", title: "Notifications", color: "#FFC107")
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                SettingsItem(icon: "lock.fill", title: "Privacy & Security", color: "#9C27B0")
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "arrow.right.square")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#F44336"))
                            .frame(width: 36)
                        
                        Text("Sign Out")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal)
                }
            }
            .background(Color(hex: "#2A2A2A"))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

// Individual settings item
struct SettingsItem: View {
    var icon: String
    var title: String
    var color: String
    
    var body: some View {
        Button(action: {
            print("Tapped \(title)")
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: color))
                    .frame(width: 36)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 14)
            .padding(.horizontal)
        }
    }
}

// App info section
struct AppInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                InfoItem(icon: "doc.text", title: "Terms of Service")
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                InfoItem(icon: "hand.raised", title: "Privacy Policy")
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                InfoItem(icon: "questionmark.circle", title: "Help & Support")
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                InfoItem(icon: "star", title: "Rate the App")
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 56)
                
                InfoItem(icon: "info.circle", title: "App Version 1.0.2")
            }
            .background(Color(hex: "#2A2A2A"))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

// Individual info item
struct InfoItem: View {
    var icon: String
    var title: String
    
    var body: some View {
        Button(action: {
            print("Tapped \(title)")
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 36)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 14)
            .padding(.horizontal)
        }
    }
}

// Edit profile view
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var username = "Bhanuka Seneviratne"
    @State private var email = "bhanuka76@gmail.com"
    @State private var bio = "Travel enthusiast and photographer. Love exploring new cultures and cuisines."
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#383838").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    // Profile image
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 120)
                            .background(Color(hex: "#2A2A2A"))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "#00485C"), lineWidth: 4)
                            )
                        
                        Button(action: {
                            print("Change photo tapped")
                        }) {
                            Text("Change Photo")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "#00B4D8"))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 8)
                    
                    // Form fields
                    VStack(spacing: 20) {
                        InputField(title: "Full Name", text: $username, icon: "person.fill")
                        InputField(title: "Email", text: $email, icon: "envelope.fill")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "text.bubble")
                                    .foregroundColor(.white.opacity(0.7))
                                Text("Bio")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            TextEditor(text: $bio)
                                .foregroundColor(.white)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        // Save profile changes logic would go here
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#00485C"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .padding(.top, 16)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Edit Profile")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundColor(Color(hex: "#00B4D8"))
                        }
                    }
                }
            }
        }
    }
}

// Input field component
struct InputField: View {
    var title: String
    @Binding var text: String
    var icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            TextField("", text: $text)
                .foregroundColor(.white)
                .padding()
                .background(Color(hex: "#2A2A2A"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// Now, we need to update the HomePage to navigate to the UserAccountPage when username is tapped
extension HomePage {
    // Add this function to navigate to user account page
    func navigateToUserAccount() -> some View {
        return UserAccountPage()
            .environmentObject(router)
    }
}

// And modify the HeaderView in HomePage to use this navigation
// Replace the existing user profile section in HomePage with:
/*
Button(action: {
    // Show user account page
    self.showUserAccountPage = true
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
.sheet(isPresented: $showUserAccountPage) {
    navigateToUserAccount()
}
*/
