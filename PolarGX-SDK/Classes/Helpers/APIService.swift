
import Foundation

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
        body: Encodable?,
        logResult: Bool = true,
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
            logResult: logResult,
            result: result
        )
    }
    
    
    private func _request<RO: Decodable>(
        method: HTTPMethod,
        url: URL,
        headers: [String: String],
        queries: [String: String],
        body: Encodable?,
        logResult: Bool,
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
        urlRequest.httpBody = try body.flatMap({ try encoder.encode($0) })

        var headers = defaultHeaders.merging(headers, uniquingKeysWith: { $1 })
        headers["Content-Type"] = "application/json"
        headers["Content-Length"] = "\(urlRequest.httpBody?.count ?? 0)"
        urlRequest.allHTTPHeaderFields = headers
        
        let (data, response) = try await session.data(for: urlRequest)
        let responseStatus = (response as? HTTPURLResponse)?.statusCode
                
        guard let responseStatus = responseStatus else {
            logFailure(request: urlRequest, response: response, responseData: data)
            throw Errors.unexpectedError()
        }
        
        let responseObject = try decoder.decode(APIResponseModel<RO>.self, from: data)

        guard responseStatus == 200 else {
            logFailure(request: urlRequest, response: response, responseData: data)

            let apiError = APIErrorResponse(
                httpStatus: responseStatus,
                code: responseObject.code ?? 0,
                message: responseObject.message ?? "Unknown error!"
            )
            throw Errors.apiError(apiError)
        }
        
        logSuccess(request: urlRequest, response: response, responseData: logResult ? data : nil)
        return responseObject.data
    }
    
    private func logSuccess(request: URLRequest, response: URLResponse, responseData: Data?) {
        if PolarApp.isLoggingEnabled {
            lazy var method = request.httpMethod ?? ""
            lazy var path = (request.url?.absoluteString).flatMap({ $0[$0.index($0.startIndex, offsetBy: server.count)...] }) ?? ""
            lazy var statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            lazy var requestBodyString = request.httpBody.flatMap({ String(data: $0, encoding: .utf8) }) ?? "<<empty>>"
            lazy var responseDataString = responseData.flatMap({ String(data: $0, encoding: .utf8) })?.replacingOccurrences(of: "\n", with: "") ?? ""
            print("[\(Configuration.Brand)][API]🌐 \(method) \(path) [\(statusCode)] 💚 -B \(requestBodyString) ➡️ \(responseDataString)")
        }
    }
    
    private func logFailure(request: URLRequest, response: URLResponse, responseData: Data?) {
        if PolarApp.isLoggingEnabled {
            lazy var method = request.httpMethod ?? ""
            lazy var server = (request.url?.absoluteString) ?? "<<none>>"
            lazy var statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            lazy var requestHeaderString = request.allHTTPHeaderFields?.map{ "-H \($0.key): \($0.value)" }.joined(separator: " ") ?? "<<none>>"
            lazy var requestBodyString = request.httpBody.flatMap({ String(data: $0, encoding: .utf8) }) ?? "<<none>>"
            lazy var responseDataString = responseData.flatMap({ String(data: $0, encoding: .utf8) })?.replacingOccurrences(of: "\n", with: "") ?? ""
            print("[\(Configuration.Brand)][API]🌐 \(method) \(server) [\(statusCode)] ❤️ \(requestHeaderString) -B \(requestBodyString) ➡️ \(responseDataString)")
        }
    }
}



