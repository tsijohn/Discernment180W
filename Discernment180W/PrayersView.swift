import SwiftUI

struct Prayer: Identifiable {
    let id = UUID()
    let title: String
    let text: String
}

struct PrayersView: View {
    @Environment(\.dismiss) var dismiss
    
    private let accentColor = Color.blue
    private let backgroundColor = Color(.systemBackground)
    private let cardColor = Color(.secondarySystemBackground)
    
    // Hardcoded prayer data
    private let prayers = [
        Prayer(
            title: "Prayer to Know My Vocation",
            text: """
            Lord, my God and my loving Father, you have made me to  know you, to love you, to serve you, and thereby to find and to  fulfill my deepest longings. I know that you are in all things, and  that every path can lead me to you. But of them all, there is one  especially by which you want me to come to you. I pray you,  send your Holy Spirit to me: into my mind, to show me what  you want for me; into my heart, to give me the determination  to do it. By your grace, may I do it with all my love, with all my  mind, and with all my strength. Jesus, I trust in you. Amen.
            """
        ),

        Prayer(
            title: "Entrust Your Vocation to Mary",
            text: """
            Blessed Mother, I entrust myself and my vocation to your  motherly care and intercession. You perfectly heard the word of  God and obeyed. Pray for me, that I too might also hear God’s  word and follow where He leads. Should the Lord desire me to  be a priest, ask your Son that I might receive the grace to hear  His call and the strength of faith and hope to lay down my life  in loving service for the Church. O Mother of the Word Incar nate, be my mother, too. May God be glorified to answer your  prayers on my behalf. Amen. 

            """
        ),
        Prayer(
            title: "Memorare",
            text: """
            Remember, O most gracious Virgin Mary, that never was  it known that anyone who fled to thy protection, implored thy  help, or sought thine intercession was left unaided. Inspired by  this confidence, I fly unto thee, O Virgin of virgins, my mother;  to thee do I come, before thee I stand, sinful and sorrowful. O  Mother of the Word Incarnate, despise not my petitions, but in  thy mercy hear and answer me. Amen.

            """
        ),
        Prayer(
            title: "Consecrate Discernment 180 to the Lord",
            text: """
            Consecrate Discernment 180 to the Lord 
            Heavenly Father, you are the source of all that is good. I  offer myself to you. Send your Holy Spirit, I pray, to consecrate  these 180 days of vocational discernment, and receive them as  an expression of my gratitude for your love and mercy. Bless  and anoint my efforts, Lord. May they be inspired by your  grace, draw me into deeper communion with the Sacred Heart  of Your Son, and bear great fruit for your Kingdom. Should it  be your will, I ask for the grace to know my vocation. If this is  not the time, may I receive the graces I need to abandon myself  to Your providence no matter where You may lead. Hear and  answer my prayer, Lord. I make it in faith through Jesus Christ,  Your Son and my Lord. Amen. 

            """
        ),
        Prayer(
            title: "Suscipe",
            text: """
            Take, O Lord, and receive my entire liberty, my memory,  my understanding and my whole will. All that I am and all that  I possess, Thou hast given me: I surrender it all to Thee to be  disposed of according to Thy will. Give me only Thy love and 

            """
        )
    ]
    
    @State private var favoritePrayers: Set<UUID> = []
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(prayers) { prayer in
                        PrayerCard(
                            prayer: prayer,
                            isFavorite: favoritePrayers.contains(prayer.id),
                            toggleFavorite: {
                                if favoritePrayers.contains(prayer.id) {
                                    favoritePrayers.remove(prayer.id)
                                } else {
                                    favoritePrayers.insert(prayer.id)
                                }
                            },
                            accentColor: accentColor
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "book.pages.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                        Text("Prayers")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct PrayerCard: View {
    let prayer: Prayer
    let isFavorite: Bool
    let toggleFavorite: () -> Void
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(prayer.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            Text(prayer.text)
                .font(.body)
                .lineSpacing(6)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            

        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            isFavorite ?
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor, lineWidth: 2)
            : nil
        )
        .animation(.easeInOut(duration: 0.2), value: isFavorite)
    }
}

struct PrayersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrayersView()
        }
    }
}
