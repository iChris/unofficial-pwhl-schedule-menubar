import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var service: PWHLScheduleService
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            
            if service.isLoading && service.gameGroups.isEmpty {
                VStack {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                }
            } else if let error = service.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
            } else if service.gameGroups.isEmpty {
                VStack {
                    Spacer()
                    Text("No upcoming games found.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                gameList
            }
            
            Divider()
            footer
        }
        .frame(width: 320, height: 420)
        .background(service.hasLiveGame ? Color(hex: "33058D") : Color(NSColor.windowBackgroundColor))
        .environment(\.colorScheme, service.hasLiveGame ? .dark : colorScheme)
    }
    
    private var header: some View {
        HStack {
            Text("PWHL Schedule")
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
        }
        .padding()
        .background(Color.clear)
    }
    
    private var gameList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(service.gameGroups) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(group.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(group.games) { display in
                            GameRow(display: display)
                        }
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom)
        }
    }
    
    private var footer: some View {
        HStack {
            Button("Refresh") {
                Task {
                    await service.fetchSchedule()
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.clear)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GameRow: View {
    let display: GameDisplay
    private var game: PWHLScorebarGame { display.game }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            teamRow(name: game.VisitorLongName, logoURL: game.VisitorLogo, wins: game.VisitorWins, losses: game.VisitorRegulationLosses, otl: game.VisitorOTLosses, goals: game.VisitorGoals)
            teamRow(name: game.HomeLongName, logoURL: game.HomeLogo, wins: game.HomeWins, losses: game.HomeRegulationLosses, otl: game.HomeOTLosses, goals: game.HomeGoals)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.venue_name.components(separatedBy: "|").first?.trimmingCharacters(in: .whitespaces) ?? game.venue_name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    let watchText = display.networks.isEmpty ? "Where to Watch" : display.networks.joined(separator: ", ")
                    if let url = URL(string: game.HomeVideoUrl), !game.HomeVideoUrl.isEmpty {
                        Link(destination: url) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.tv.fill")
                                Text(watchText)
                            }
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
                
                if game.GameStatus == "4" {
                    Text(game.GameStatusString)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                } else if game.GameStatus != "1" {
                     Text("Live")
                        .font(.caption)
                        .foregroundColor(.red)
                        .bold()
                } else {
                    Text(formatTime(game.parsedDate))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func teamRow(name: String, logoURL: String, wins: String, losses: String, otl: String, goals: String) -> some View {
        HStack {
            if let url = URL(string: logoURL.replacingOccurrences(of: "\\/", with: "/")) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else if phase.error != nil {
                        Color.gray.opacity(0.3)
                    } else {
                        ProgressView().scaleEffect(0.5)
                    }
                }
                .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .fontWeight(.bold)
                Text("\(wins)-\(losses)-\(otl)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Spacer()
            if game.GameStatus != "1" {
                Text(goals)
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "TBD" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
