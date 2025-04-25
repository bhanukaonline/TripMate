import SwiftUI

struct DiscoverPage: View {
    @EnvironmentObject var router: TabRouter
    @StateObject private var viewModel = DiscoverViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Discover",
                      leading: {
                          Button(action: {}) {
                              Image(systemName: "line.3.horizontal")
                                  .font(.title2)
                          }
                      },
                      trailing: {
                          Button(action: {}) {
                              Image(systemName: "bell.badge")
                                  .font(.title2)
                          }
                      })
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else {
                DiscoverContent(
                    popularDestinations: viewModel.popularDestinations,
                    trendingCities: viewModel.trendingCities,
                    travelTips: viewModel.travelTips
                )
            }
            
            CustomTabBar()
        }
        .background(Color(hex: "#00485C"))
        .edgesIgnoringSafeArea(.bottom)
        .task {
            await viewModel.fetchData()
        }
    }
}

struct SectionHeader: View {
    let title: String
    var action: String?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Spacer()
            
            if let action = action {
                Button(action: {}) {
                    Text(action)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DestinationDetailView: View {
    let destination: Destination
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: destination.imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                    }
                }
                .frame(height: 300)
                .clipped()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(destination.name)
                        .font(.largeTitle.bold())
                    
                    Text(destination.location)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", destination.rating))
                        
                        Text("(1,234 reviews)")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("From $\(destination.price) per person")
                        .font(.headline)
                        .padding(.top, 8)
                }
                .padding()
                
                Text("About this destination")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                Text("""
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. \
                    Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. \
                    Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.
                    """)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle(destination.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryCard: View {
    let category: TravelCategory
    
    var body: some View {
        HStack {
            Image(systemName: category.iconName)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
            
            Text(category.title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "#4F4F4F"))
        .cornerRadius(10)
    }
}
struct DiscoverContent: View {
    let popularDestinations: [Destination]
    let trendingCities: [Destination]
    let travelTips: [TravelTip]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                searchBar
                
                popularDestinationsSection
                
                trendingCitiesSection
                
                travelTipsSection
                
                categoriesSection
            }
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#383838"))
        .clipShape(RoundedCorner(radius: 25, corners: [.topLeft, .topRight]))
    }
    
    // MARK: - Components
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search destinations...", text: .constant(""))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(hex: "#4F4F4F"))
            .cornerRadius(12)
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color(hex: "#4F4F4F"))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    private var popularDestinationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Popular Destinations", action: "See all")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(popularDestinations) { destination in
                        NavigationLink(destination: DestinationDetailView(destination: destination)) {
                            DestinationCard(destination: destination)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var trendingCitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Trending Cities", action: "See all")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(trendingCities) { city in
                        NavigationLink(destination: DestinationDetailView(destination: city)) {
                            CityCard(city: city)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var travelTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Travel Tips", action: "See all")
            
            VStack(spacing: 12) {
                ForEach(travelTips.prefix(3)) { tip in
                    TravelTipCard(tip: tip)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Categories")
            
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(TravelCategory.allCases.prefix(6)) { category in
                    CategoryCard(category: category)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - View Components

struct DestinationCard: View {
    let destination: Destination
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: destination.imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 280, height: 180)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 280, height: 180)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(destination.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(destination.location)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text(String(format: "%.1f", destination.rating))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("$\(destination.price)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(4)
                }
            }
            .padding()
        }
        .frame(width: 280, height: 180)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct CityCard: View {
    let city: Destination
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: city.imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 150, height: 150)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 150, height: 150)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            VStack(alignment: .leading) {
                Text(city.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(city.location)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .frame(width: 150, height: 150)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct TravelTipCard: View {
    let tip: TravelTip
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: tip.imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(tip.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    
                    Text(tip.readingTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "#4F4F4F"))
        .cornerRadius(12)
    }
}

// MARK: - View Model

class DiscoverViewModel: ObservableObject {
    @Published var popularDestinations: [Destination] = []
    @Published var trendingCities: [Destination] = []
    @Published var travelTips: [TravelTip] = []
    @Published var isLoading = true
    
    private let imageURLs = [
        // Popular destinations
        "https://images.unsplash.com/photo-1431274172761-fca41d930114?w=800", // Paris
        "https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800", // Grand Canyon
        "https://images.unsplash.com/photo-1526397751294-331021109fbd?w=800", // Machu Picchu
        "https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800", // Santorini
        "https://images.unsplash.com/photo-1547981609-4b6bfe67ca0b?w=800", // Great Wall
        "https://images.unsplash.com/photo-1564507592333-c60657eea523?w=800", // Taj Mahal
        
        // Trending cities
        "https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=800", // Tokyo
        "https://images.unsplash.com/photo-1485871981521-5b1fd3805eee?w=800", // New York
        "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800", // Dubai
        "https://images.unsplash.com/photo-1523428096881-5bd79d043006?w=800", // Sydney
        "https://images.unsplash.com/photo-1486299267070-83823f5448dd?w=800", // London
        "https://images.unsplash.com/photo-1431274172761-fca41d930114?w=800", // Paris
        
        // Travel tips
        "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800", // Packing
        "https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=800", // Budget
        "https://images.unsplash.com/photo-1547592180-85f173990554?w=800" // Food
    ]
    
    @MainActor
    func fetchData() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Popular destinations with real images
        self.popularDestinations = [
            Destination(
                name: "Eiffel Tower",
                location: "Paris, France",
                imageURL: URL(string: imageURLs[0])!,
                rating: 4.8,
                price: 1200
            ),
            Destination(
                name: "Grand Canyon",
                location: "Arizona, USA",
                imageURL: URL(string: imageURLs[1])!,
                rating: 4.7,
                price: 800
            ),
            Destination(
                name: "Machu Picchu",
                location: "Cuzco, Peru",
                imageURL: URL(string: imageURLs[2])!,
                rating: 4.9,
                price: 1500
            ),
            Destination(
                name: "Santorini",
                location: "Cyclades, Greece",
                imageURL: URL(string: imageURLs[3])!,
                rating: 4.6,
                price: 1800
            ),
            Destination(
                name: "Great Wall",
                location: "China",
                imageURL: URL(string: imageURLs[4])!,
                rating: 4.8,
                price: 2000
            ),
            Destination(
                name: "Taj Mahal",
                location: "Agra, India",
                imageURL: URL(string: imageURLs[5])!,
                rating: 4.5,
                price: 900
            )
        ]
        
        // Trending cities with real images
        self.trendingCities = [
            Destination(
                name: "Tokyo",
                location: "Japan",
                imageURL: URL(string: imageURLs[6])!,
                rating: 4.9,
                price: 1500
            ),
            Destination(
                name: "New York",
                location: "USA",
                imageURL: URL(string: imageURLs[7])!,
                rating: 4.8,
                price: 1300
            ),
            Destination(
                name: "Dubai",
                location: "UAE",
                imageURL: URL(string: imageURLs[8])!,
                rating: 4.7,
                price: 2500
            ),
            Destination(
                name: "Sydney",
                location: "Australia",
                imageURL: URL(string: imageURLs[9])!,
                rating: 4.6,
                price: 1700
            ),
            Destination(
                name: "London",
                location: "UK",
                imageURL: URL(string: imageURLs[10])!,
                rating: 4.8,
                price: 1200
            ),
            Destination(
                name: "Paris",
                location: "France",
                imageURL: URL(string: imageURLs[11])!,
                rating: 4.9,
                price: 1100
            )
        ]
        
        // Travel tips with real images
        self.travelTips = [
            TravelTip(
                title: "Packing Light",
                subtitle: "How to pack everything you need in just a carry-on",
                imageURL: URL(string: imageURLs[12])!,
                readingTime: "5 min read"
            ),
            TravelTip(
                title: "Budget Travel",
                subtitle: "Tips for traveling on a shoestring budget",
                imageURL: URL(string: imageURLs[13])!,
                readingTime: "7 min read"
            ),
            TravelTip(
                title: "Local Cuisine",
                subtitle: "Must-try foods in different countries",
                imageURL: URL(string: imageURLs[14])!,
                readingTime: "4 min read"
            )
        ]
        
        self.isLoading = false
    }
}

// MARK: - Data Models

struct Destination: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let imageURL: URL
    let rating: Double
    let price: Int
}

struct TravelTip: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageURL: URL
    let readingTime: String
}

enum TravelCategory: String, CaseIterable, Identifiable {
    case beaches = "Beaches"
    case mountains = "Mountains"
    case cities = "Cities"
    case adventure = "Adventure"
    case food = "Food"
    case culture = "Culture"
    case roadTrips = "Road Trips"
    case luxury = "Luxury"
    
    var id: String { self.rawValue }
    
    var title: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .beaches: return "umbrella.fill"
        case .mountains: return "mountain.2.fill"
        case .cities: return "building.2.fill"
        case .adventure: return "figure.hiking"
        case .food: return "fork.knife"
        case .culture: return "theatermasks.fill"
        case .roadTrips: return "car.fill"
        case .luxury: return "sparkles"
        }
    }
}

// MARK: - Preview

struct DiscoverPage_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverPage()
            .environmentObject(TabRouter())
    }
}
