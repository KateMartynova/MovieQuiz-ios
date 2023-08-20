//import Foundation
//
//
//struct Actor: Codable {
//    let id: String
//    let image: String
//    let name: String
//    let asCharacter: String
//}
//struct Movie: Codable {
//    let id: String
//    let rank: Int
//    let title: String
//    let year: Int
//    let image: String
//    let releaseDate: String
//    let runtimeMins: Int
//    let directors: String
//    let actorList: [Actor]
//    
//    
//    enum ParseError: Error {
//        case yearFailure
//        case runtimeMinsFailure
//        
//    }
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        let id = try container.decode(String.self, forKey: .id)
//        let title = try container.decode(String.self, forKey: .title)
//        
//        let year = try container.decode(String.self, forKey: .year)
//        guard let yearValue = Int(year) else {
//            throw ParseError.yearFailure
//        }
//        self.year = yearValue
//        
//        let image = try container.decode(String.self, forKey: .image)
//        let releaseDate = try container.decode(String.self, forKey: .releaseDate)
//        
//        let runtimeMins = try container.decode(String.self, forKey: .runtimeMins)
//        guard let runtimeMinsValue = Int(runtimeMins) else {
//            throw ParseError.runtimeMinsFailure
//        }
//        self.runtimeMins = runtimeMinsValue
//        
//        let directors = try container.decode(String.self, forKey: .directors)
//        let actorList = try container.decode([Actor].self, forKey: .actorList)
//    }
//    
//    
//    enum CodingKeys: CodingKey {
//       case id, title, year, image, releaseDate, runtimeMins, directors, actorList
//     }
// 
//    
//}
//
//
//func getMovie(from jsonString: String) -> Movie? {
//    var movie: Movie? = nil
//    do {
//        guard let data = jsonString.data(using: .utf8) else {
//            return nil
//        }
//        
//        do {
//            let movie = try JSONDecoder().decode(Movie.self, from: data)
//        } catch {
//            print("Failed to parse: \(error.localizedDescription)")
//        }
//    }
//    return movie
//}
