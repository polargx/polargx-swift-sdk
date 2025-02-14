import Foundation

struct DictionaryModel: Decodable {
    let content: [String: Any]
    
    private struct CodingKeys: CodingKey {
        let stringValue: String
        let intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init?(intValue: Int) {
            self.stringValue = String(intValue)
            self.intValue = intValue
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var dict: [String: Any] = [:]
        
        for key in container.allKeys {
            if let value = try? container.decode(String.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? container.decode(Int.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? container.decode(Double.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? container.decode(Bool.self, forKey: key) {
                dict[key.stringValue] = value
            }
            // Add more types as needed
        }
        
        self.content = dict
    }
}

