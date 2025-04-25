import SwiftUI
import LocalAuthentication

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = true
    @Published var errorMessage: String?
    @Published var showError = false
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Use biometric authentication
            let reason = "Authenticate to access your trips"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        // Handle different authentication errors
                        if let error = authError {
                            switch error {
                            case LAError.authenticationFailed:
                                self.errorMessage = "Authentication failed"
                            case LAError.userCancel:
                                self.errorMessage = "Authentication canceled"
                            case LAError.userFallback:
                                self.errorMessage = "Password option selected"
                                // Optionally show PIN entry here
                            case LAError.biometryNotAvailable:
                                self.errorMessage = "Biometric authentication not available"
                            case LAError.biometryNotEnrolled:
                                self.errorMessage = "No biometric authentication enrolled"
                            case LAError.biometryLockout:
                                self.errorMessage = "Biometric authentication is locked out"
                            default:
                                self.errorMessage = "Authentication error"
                            }
                            self.showError = true
                        }
                    }
                }
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // Fall back to device passcode
            let reason = "Authenticate to access your trips"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        if let error = authError {
                            self.errorMessage = error.localizedDescription
                            self.showError = true
                        }
                    }
                }
            }
        } else {
            // No authentication available
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Authentication not available: \(error.localizedDescription)"
                    self.showError = true
                }
                // Fallback to PIN authentication or allow access
                // For security, you may want to default to PIN instead of automatically allowing access
            }
        }
    }
}

struct AuthenticationView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var showPinView = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("TripMate")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your trips are secured")
                .font(.subheadline)
            
            Button(action: {
                authManager.authenticate()
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Unlock with Face ID")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 220)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.top, 30)
            
            Button(action: {
                showPinView = true
            }) {
                HStack {
                    Image(systemName: "rectangle.grid.2x2")
                    Text("Use PIN")
                }
                .font(.headline)
                .foregroundColor(.blue)
            }
            .padding(.top, 10)
            
            if authManager.showError {
                Text(authManager.errorMessage ?? "Authentication error")
                    .foregroundColor(.red)
                    .padding(.top, 20)
            }
        }
        .padding()
        .sheet(isPresented: $showPinView) {
            PINView(authManager: authManager)
        }
    }
}

struct PINView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var pin = ""
    @State private var showError = false
    @Environment(\.presentationMode) var presentationMode
    
    // In a real app, you would store this securely using Keychain
    let correctPin = "1234" // Example PIN
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter PIN")
                    .font(.headline)
                
                SecureField("PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button("Submit") {
                    if pin == correctPin {
                        authManager.isAuthenticated = true
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        showError = true
                        pin = ""
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                
                if showError {
                    Text("Incorrect PIN")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationTitle("PIN Authentication")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

@main
struct TripMateApp: App {
    @StateObject private var tripStore = TripStore()
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainView()
                        .environmentObject(tripStore)
                } else {
                    AuthenticationView(authManager: authManager)
                }
            }
            .onAppear {
                // Request authentication when app appears
                if !authManager.isAuthenticated {
                    // Don't automatically authenticate on app launch
                    // Let user choose authentication method instead
                }
            }
        }
    }
}
