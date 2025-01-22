
import Foundation

private func Log(_ sf: @autoclosure () -> String) {
    if LinkAttributionApp.isLoggingEnabled {
        print("[LinkAttribution/NETWORK] \(sf())")
    }
}

class APIService {
    let server: String
    var defaultHeaders: [String: String] = [:]

    init(server: String) {
        self.server = server
        assert(!server.hasSuffix("/"), "Invalid server")
    }
    
    private lazy var session = URLSession(configuration: .default)
    private lazy var encoder = JSONEncoder()
    private lazy var decoder = JSONDecoder()
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
    }
    
    func request<RO: Decodable>(
        method: HTTPMethod,
        path: String,
        headers: [String: String],
        queries: [String: String],
        body: Encodable,
        result: RO.Type
    ) async throws -> RO? {
        assert(!server.hasPrefix("/"), "Invalid path")
        guard let url = URL(string: server + path) else {
            throw Errors.with(message: "Invalid url!")
        }
        
        return try await _request(
            method: method,
            url: url,
            headers: headers,
            queries: queries,
            body: body,
            result: result
        )
    }
    
    
    private func _request<RO: Decodable>(
        method: HTTPMethod,
        url: URL,
        headers: [String: String],
        queries: [String: String],
        body: Encodable,
        result: RO.Type
    ) async throws -> RO? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Errors.unexpectedError()
        }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queries.map({ URLQueryItem(name: $0.key, value: $0.value) })
        guard let url = urlComponents.url else {
            throw Errors.unexpectedError()
        }
                
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = try encoder.encode(body)

        var headers = defaultHeaders.merging(headers, uniquingKeysWith: { $1 })
        headers["Content-Type"] = "application/json"
        headers["Content-Length"] = "\(urlRequest.httpBody?.count ?? 0)"
        urlRequest.allHTTPHeaderFields = headers
            
        Log("REQUEST \(urlRequest.httpMethod ?? "") \(urlRequest.url?.absoluteString ?? "")\n   \(urlRequest.httpBody.flatMap({ String(data: $0, encoding: .utf8) }) ?? "")")
        
        let (data, response) = try await session.data(for: urlRequest)
        let responseStatus = (response as? HTTPURLResponse)?.statusCode
        
        Log("RESPONSE \(urlRequest.httpMethod ?? "") \(urlRequest.url?.absoluteString ?? "") [\(responseStatus ?? -1)]\n   \(String(data: data, encoding: .utf8) ?? "")")
        
        guard let responseStatus = responseStatus else {
            throw Errors.unexpectedError()
        }
        
        let responseObject = try decoder.decode(APIResponseModel<RO>.self, from: data)

        guard responseStatus == 200 else {
            let apiError = APIErrorResponse(
                httpStatus: responseStatus,
                code: responseObject.code ?? 0,
                message: responseObject.message ?? "Unknown error!"
            )
            throw Errors.apiError(apiError)
        }
        
        return responseObject.data
    }
}



