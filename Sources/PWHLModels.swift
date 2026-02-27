import Foundation

struct PWHLRootResponse: Codable {
    let SiteKit: PWHLSiteKit
}

struct PWHLSiteKit: Codable {
    let Scorebar: [PWHLScorebarGame]?
}

struct PWHLScorebarGame: Codable, Identifiable {
    let id: String
    let SeasonID: String
    let Date: String
    let GameDateISO8601: String
    let HomeLongName: String
    let VisitorLongName: String
    let HomeGoals: String
    let VisitorGoals: String
    let GameStatusString: String
    let GameStatus: String
    let venue_name: String
    
    // New fields
    let HomeLogo: String
    let VisitorLogo: String
    let HomeWins: String
    let HomeRegulationLosses: String
    let HomeOTLosses: String
    let VisitorWins: String
    let VisitorRegulationLosses: String
    let VisitorOTLosses: String
    let HomeVideoUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case SeasonID
        case Date
        case GameDateISO8601
        case HomeLongName
        case VisitorLongName
        case HomeGoals
        case VisitorGoals
        case GameStatusString
        case GameStatus
        case venue_name
        case HomeLogo
        case VisitorLogo
        case HomeWins
        case HomeRegulationLosses
        case HomeOTLosses
        case VisitorWins
        case VisitorRegulationLosses
        case VisitorOTLosses
        case HomeVideoUrl
    }
    
    var parsedDate: Foundation.Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: GameDateISO8601)
    }
}

struct GameGroup: Identifiable {
    let id = UUID()
    let title: String
    let games: [GameDisplay]
}

struct GameDisplay: Identifiable {
    var id: String { game.id }
    let game: PWHLScorebarGame
    let networks: [String]
}

// Models for Schedule endpoint used to fetch broadcasters
struct PWHLScheduleRootResponse: Codable {
    let SiteKit: PWHLScheduleSiteKit
}

struct PWHLScheduleSiteKit: Codable {
    let Schedule: [PWHLScheduleDetailedGame]?
}

struct PWHLScheduleDetailedGame: Codable {
    let id: String
    let broadcasters: PWHLBroadcasters?
}

struct PWHLBroadcasters: Codable {
    let home_video: [PWHLBroadcaster]?
    let home_video_fr: [PWHLBroadcaster]?
    let home_webcast: [PWHLBroadcaster]?
    // Ignore others for now as video/webcast are primary
}

struct PWHLBroadcaster: Codable {
    let name: String
    let url: String
    let logo_url: String
}
