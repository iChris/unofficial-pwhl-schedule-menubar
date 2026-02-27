import Foundation
import Combine

class PWHLScheduleService: ObservableObject {
    @Published var gameGroups: [GameGroup] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasLiveGame = false
    
    init() {
        Task {
            await fetchSchedule()
        }
    }
    
    @MainActor
    func fetchSchedule() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let scorebarURL = URL(string: "https://lscluster.hockeytech.com/feed/index.php?feed=modulekit&view=scorebar&numberofdaysback=1&numberofdaysahead=14&key=446521baf8c38984&client_code=pwhl")!
            let (scorebarData, _) = try await URLSession.shared.data(from: scorebarURL)
            let scorebarResult = try JSONDecoder().decode(PWHLRootResponse.self, from: scorebarData)
            let games = scorebarResult.SiteKit.Scorebar ?? []
            
            var broadcastersMap: [String: [String]] = [:]
            
            if let firstGame = games.first {
                let seasonId = firstGame.SeasonID
                let scheduleURLString = "https://lscluster.hockeytech.com/feed/?feed=modulekit&view=schedule&season_id=\(seasonId)&key=446521baf8c38984&client_code=pwhl"
                
                if let scheduleURL = URL(string: scheduleURLString) {
                    do {
                        let (scheduleData, _) = try await URLSession.shared.data(from: scheduleURL)
                        let scheduleResult = try JSONDecoder().decode(PWHLScheduleRootResponse.self, from: scheduleData)
                        
                        if let scheduleGames = scheduleResult.SiteKit.Schedule {
                            for g in scheduleGames {
                                var networks: [String] = []
                                if let b = g.broadcasters {
                                    if let video = b.home_video { networks.append(contentsOf: video.map { $0.name }) }
                                    if let videoFr = b.home_video_fr { networks.append(contentsOf: videoFr.map { $0.name }) }
                                    if let webcast = b.home_webcast { networks.append(contentsOf: webcast.map { $0.name }) }
                                }
                                // Remove exact duplicates but keep order
                                var uniqueNetworks: [String] = []
                                for n in networks {
                                    if !uniqueNetworks.contains(n) {
                                        uniqueNetworks.append(n)
                                    }
                                }
                                broadcastersMap[g.id] = uniqueNetworks
                            }
                        }
                    } catch {
                        print("Failed to fetch detailed schedule: \(error)")
                    }
                }
            }
            
            self.processSchedule(games: games, broadcastersMap: broadcastersMap)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func processSchedule(games: [PWHLScorebarGame], broadcastersMap: [String: [String]]) {
        let now = Date()
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: now)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        
        let sortedGames = games.filter { game in
            guard let date = game.parsedDate else { return false }
            return date >= yesterdayStart
        }.sorted { ($0.parsedDate ?? Date.distantFuture) < ($1.parsedDate ?? Date.distantFuture) }
        
        let limitedGames = Array(sortedGames.prefix(8))
        
        var groupsMap: [String: [GameDisplay]] = [:]
        var groupOrder: [String] = []
        
        for game in limitedGames {
            guard let date = game.parsedDate else { continue }
            let title: String
            
            if calendar.isDate(date, inSameDayAs: yesterdayStart) {
                title = "Past Games"
            } else if calendar.isDate(date, inSameDayAs: todayStart) {
                title = "Today's Games"
            } else if calendar.isDate(date, inSameDayAs: tomorrowStart) {
                title = "Tomorrow"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                title = formatter.string(from: date)
            }
            
            if groupsMap[title] == nil {
                groupsMap[title] = []
                groupOrder.append(title)
            }
            
            let networks = broadcastersMap[game.id] ?? []
            let display = GameDisplay(game: game, networks: networks)
            groupsMap[title]?.append(display)
        }
        
        let liveGameExists = limitedGames.contains {
            $0.GameStatus != "1" && $0.GameStatus != "4"
        }
        
        self.gameGroups = groupOrder.map { GameGroup(title: $0, games: groupsMap[$0]!) }
        self.hasLiveGame = liveGameExists
    }
}
