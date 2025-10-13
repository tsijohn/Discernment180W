import SwiftUI

struct ResourceView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let featuredResources = [
        Resource(
            title: "Discernment 180 (Actual Book)",
            author: "Fr. Greg Gerhart",
            description: "A comprehensive 180-day discernment guide for men considering the priesthood. This book provides daily reflections, prayers, and practical advice for a thorough discernment journey.",
            url: "https://vianneyvocations.com/product/d180/",
            category: .book
        ),
        Resource(
            title: "To Save a Thousand Souls",
            author: "Fr. Brett Brannen",
            description: "The definitive guide for men considering the priesthood. This comprehensive book explains in down-to-earth language how to carefully discover God's call to diocesan priesthood.",
            url: "https://vianneyvocations.com/product/to-save-a-thousand-souls/",
            category: .book
        ),
        Resource(
            title: "His Mercy Endures",
            author: "Catholic Resources",
            description: "Straightforward advice and practical resources for dealing with temptations to pornography and unchaste dating. Offers support for growing in the virtue of chastity.",
            url: "https://www.hismercyendures.org/",
            category: .website
        )
    ]
    
    let additionalBooks = [
        Resource(
            title: "Virginity",
            author: "Raniero Cantalamessa",
            description: "A guide to celibacy for the sake of the Kingdom as it truly is: a gift to be received, not a burden to be imposed.",
            url: "https://www.amazon.com/Virginity-Positive-Approach-Celibacy-Kingdom/dp/0818914009",
            category: .book
        ),
        Resource(
            title: "Discernment of Spirits",
            author: "Timothy Gallagher",
            description: "A guide to understanding the different movements of spiritual life, how to recognize which are from God, which are from the enemy, and how to respond to each.",
            url: "https://www.amazon.com/Discernment-Spirits-Ignatian-Everyday-Living/dp/0824522915",
            category: .book
        ),
        Resource(
            title: "The Priest is Not His Own",
            author: "Fulton Sheen",
            description: "A reflection on the priesthood of Jesus Christ, who offered the sacrifice not of a separate victim, but of Himself.",
            url: "https://www.amazon.com/Priest-Not-His-Own/dp/1586170449",
            category: .book
        )
    ]
    
    let prayerResources = [
        Resource(
            title: "Liturgy of the Hours",
            author: "Hallow / Catholic Tradition",
            description: "The official daily prayer of the Church, marking the hours of each day and sanctifying the day with prayer. Discernment 180 recommends praying Night Prayer.",
            url: "https://hallow.com/blog/liturgy-of-the-hours/",
            category: .prayer
        ),
        Resource(
            title: "Lectio Divina",
            author: "Hallow App / Catholic Tradition",
            description: "Prayerfully reading scripture is a cornerstone of the Christian life. The practice of Divine Reading includes step-by-step instructions for meditative prayer with Scripture.",
            url: "https://hallow.com/blog/how-to-pray-lectio-divina/",
            category: .prayer
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed header with back button only
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                        Text("Home")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
            // Scrollable content
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    // Content Sections
                    LazyVStack(spacing: 24) {
                        // Essential Resources
                        ResourceSection(
                            title: "Essential Resources",
                            subtitle: "Start your journey with these foundational materials",
                            resources: featuredResources,
                            accentColor: Color(red: 0.2, green: 0.4, blue: 0.8)
                        )
                        
                        // Prayer Resources
                        ResourceSection(
                            title: "Prayer & Liturgy",
                            subtitle: "Deepen your spiritual practice",
                            resources: prayerResources,
                            accentColor: Color(red: 0.6, green: 0.3, blue: 0.8)
                        )
                        
                        // Additional Books
                        ResourceSection(
                            title: "Additional Reading",
                            subtitle: "Expand your understanding",
                            resources: additionalBooks,
                            accentColor: Color(red: 0.8, green: 0.4, blue: 0.2)
                        )
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
    }
}

struct ResourceSection: View {
    let title: String
    let subtitle: String
    let resources: [Resource]
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Section Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            
            // Resources
            LazyVStack(spacing: 10) {
                ForEach(resources, id: \.title) { resource in
                    ModernResourceCard(resource: resource, accentColor: accentColor)
                        .padding(.horizontal, 16)
                }
            }
        }
    }
}

struct ModernResourceCard: View {
    let resource: Resource
    let accentColor: Color
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if let url = URL(string: resource.url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: resource.category.iconName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(accentColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(resource.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(resource.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(resource.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: isPressed ? 2 : 6,
                        x: 0,
                        y: isPressed ? 1 : 3
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                accentColor.opacity(0.3),
                                accentColor.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct Resource {
    let title: String
    let author: String
    let description: String
    let url: String
    let category: ResourceCategory
}

enum ResourceCategory {
    case book
    case website
    case prayer
    
    var iconName: String {
        switch self {
        case .book:
            return "book.closed.fill"
        case .website:
            return "globe"
        case .prayer:
            return "hands.sparkles.fill"
        }
    }
}

#Preview {
    NavigationView {
        ResourceView()
    }
}
