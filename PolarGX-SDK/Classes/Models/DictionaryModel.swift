import Foundation

struct DictionaryModel: Codable {
    let content: [String: Any]
    
    init(content: [String: Any]) {
        self.content = content
    }
    
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
            if let value = try? container.decode(Bool.self, forKey: key) {
                dict[key.stringValue] = value
                
            }else if let value = try? container.decode(Int.self, forKey: key) {
                dict[key.stringValue] = value
                
            }else if let value = try? container.decode(UInt.self, forKey: key) {
                dict[key.stringValue] = value
                
            }else if let value = try? container.decode(Double.self, forKey: key) {
                dict[key.stringValue] = value
                
            }else if let value = try? container.decode(String.self, forKey: key) {
                dict[key.stringValue] = value
                
            }else if let value = try? container.decode(DictionaryModel.self, forKey: key) {
                dict[key.stringValue] = value.content
                
            }else if let value = try? container.decode([DictionaryModel].self, forKey: key) {
                dict[key.stringValue] = value.map({ $0.content })

            }
        }
        
        self.content = dict
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        for (key, value) in content {
            let codingKey = CodingKeys(stringValue: key)!
            
            if value is NSNull {
                try container.encodeNil(forKey: codingKey)
                
            }else if let value = value as? Encodable {
                try container.encode(value, forKey: codingKey)
                
            }else if let value = value as? [String: Any] {
                try container.encode(DictionaryModel(content: value), forKey: codingKey)

            }else {
                let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "DictionaryModel.content cannot be encoded")
                throw EncodingError.invalidValue(value, context)
            }
        }
    }
}

