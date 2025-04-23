//
//  Components.swift
//  TripMate
//
//  Created by Bhanuka on 4/22/25.
//

import SwiftUI

enum Tab {
    case home, trips, addtrip, map, discover
}

class TabRouter: ObservableObject {
    @Published var currentTab: Tab = .home
}

struct HeaderView<Leading: View, Trailing: View>: View {
    let title: String
    var leading: () -> Leading
    var trailing: () -> Trailing

    init(
        title: String,
        @ViewBuilder leading: @escaping () -> Leading = { EmptyView() },
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.leading = leading
        self.trailing = trailing
    }

    var body: some View {
        ZStack {
            HStack {
                leading()
                Spacer()
                trailing()
            }

            Text(title)
                .font(.title)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(hex: "#00485C"))
        .foregroundColor(.white)
    }
}



//struct CustomTabBar: View {
//    @Binding var selectedIndex: Int
//
//    let icons = ["house", "briefcase", "plus.square", "map", "safari"]
//
//    var body: some View {
//        HStack {
//            ForEach(0..<icons.count, id: \.self) { index in
//                Spacer()
//                Button(action: {
//                    selectedIndex = index
//                }) {
//                    Image(systemName: selectedIndex == index ? "\(icons[index]).fill" : icons[index])
//                                            .font(.system(size: index == 2 ? 32 : 25)) // Bigger plus icon
//                                            .foregroundColor(.white) // Keep same color, just change filled style
//                }
//                Spacer()
//            }
//        }
//        .padding()
//        .background(Color(Color(hex: "#383838")).shadow(radius: 5))
//    }
//}




struct CustomTabBar: View {
    @EnvironmentObject var router: TabRouter

    let icons: [(image: String, tab: Tab)] = [
        ("house", .home),
        ("briefcase", .trips),
        ("plus.square", .addtrip),
        ("map", .map),
        ("safari", .discover)
    ]

    var body: some View {
        HStack {
            ForEach(icons, id: \.tab) { icon in
                Spacer()
                Button(action: {
                    router.currentTab = icon.tab
                }) {
                    Image(systemName: router.currentTab == icon.tab ? "\(icon.image).fill" : icon.image)
//                        .font(.system(size: 24))
                        .font(.system(size: icon.tab == .addtrip ? 32 : 24))
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(Color(hex: "#383838")).shadow(radius: 5))
    }
}



extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)

        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)

        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)

        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

