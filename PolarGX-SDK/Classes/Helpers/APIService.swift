
import Foundation

class APIService {
    let server: String
    let appLinkServer: String
    var defaultHeaders: [String: String] = [:]
    
    private var locker = ThLocker()
    
    init(configuration: EnvConfigrationDescribe) {
        self.server = configuration.server
        self.appLinkServer = configuration.appLinkServer
        assert(!server.hasSuffix("/"), "Invalid server")
        assert(!appLinkServer.hasSuffix("/"), "Invalid appLinkServer")
    }
    
    private lazy var session = URLSession(configuration: .default)
    private lazy var encoder = JSONEncoder()
    private lazy var decoder = JSONDecoder()
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    func request<RO: Decodable>(
        method: HTTPMethod,
        path: String,
        headers: [String: String],
        queries: [String: String],
        body: () async throws -> Any?,
        logResult: Bool = true,
        result: RO.Type
    ) async throws -> RO? {
        assert(!server.hasPrefix("/"), "Invalid path")
        guard let url = URL(string: server + path) else {
            throw Errors.with(message: "Invalid url!")
        }
        
        return try await request(
            method: method,
            url: url,
            headers: headers,
            queries: queries,
            body: body,
            logResult: logResult,
            result: result
        )
    }
    
    
    func request<RO: Decodable>(
        method: HTTPMethod,
        url: URL,
        headers: [String: String],
        queries: [String: String],
        body: () async throws -> Any?,
        logResult: Bool,
        result: RO.Type,
    ) async throws -> RO? {
        await locker.waitForUnlock()
        
        let number = Int.random(in: 10000..<100000)
        
        let startTime = Logger.initialTime.currentIntervalString()
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Errors.unexpectedError()
        }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queries.map({ URLQueryItem(name: $0.key, value: $0.value) })
        guard let url = urlComponents.url else {
            throw Errors.unexpectedError()
        }
        
        var retry: Bool
        repeat {
            retry = false
            
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
            urlRequest.httpMethod = method.rawValue
            urlRequest.httpBody = try await body().flatMap({
                if let body = $0 as? Encodable {
                    return try encoder.encode(body)
                }else{
                    return try JSONSerialization.data(withJSONObject: $0)
                }
            })

            var headers = defaultHeaders.merging(headers, uniquingKeysWith: { $1 })
            headers["Content-Type"] = "application/json"
            headers["Content-Length"] = "\(urlRequest.httpBody?.count ?? 0)"
            urlRequest.allHTTPHeaderFields = headers
            
            let (data, response) = try await session.data(for: urlRequest)
            let responseStatus = (response as? HTTPURLResponse)?.statusCode
                    
            guard let responseStatus = responseStatus else {
                logFailure(request: urlRequest, response: response, responseData: data, startTime: startTime, number: number)
                throw Errors.unexpectedError()
            }
            
            let responseObject = try decoder.decode(APIResponseModel<RO>.self, from: data)
            
            if responseStatus == 429 {
                await locker.lock()
                logWarning(request: urlRequest, response: response, responseData: data, startTime: startTime, number: number)
                try? await Task.sleep(nanoseconds: PolarConstants.DeplayToRetryAPIRequestIfTimeLimits)
                await locker.unlock()
                retry = true
                continue
            }

            guard responseStatus == 200 && responseObject.error == nil else {
                logFailure(request: urlRequest, response: response, responseData: data, startTime: startTime, number: number)
                var apiError = responseObject.error ?? APIErrorResponse(
                    code: "-1",
                    message: "Unknown error!",
                    statusCode: -1
                )
                apiError.httpStatus = responseStatus
                throw Errors.apiError(apiError)
            }
            
            logSuccess(request: urlRequest, response: response, responseData: logResult ? data : nil, startTime: startTime, number: number)
            return responseObject.data
            
        }while retry
    }
    
    private func logSuccess(request: URLRequest, response: URLResponse, responseData: Data?, startTime: String, number: Int) {
        if PolarApp.isLoggingEnabled {
            lazy var method = request.httpMethod ?? ""
            lazy var url = request.url?.absoluteString ?? ""
            lazy var path = url.hasPrefix(server) ? url[url.index(url.startIndex, offsetBy: server.count)...] : nil
            lazy var statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            lazy var requestBodyString = request.httpBody.flatMap({ String(data: $0, encoding: .utf8) }) ?? "<<empty>>"
            lazy var responseDataString = responseData.flatMap({ String(data: $0, encoding: .utf8) })?.replacingOccurrences(of: "\n", with: "") ?? ""
            let endTime = Logger.initialTime.currentIntervalString()
            print("\(startTime)-\(endTime)-[\(Configuration.Brand)][API]🌐 #\(number) \(method) \(path ?? url[url.startIndex..<url.endIndex]) [\(statusCode)] 💚 -B \(requestBodyString) ➡️ \(responseDataString)")
        }
    }
    
    private func logFailure(request: URLRequest, response: URLResponse, responseData: Data?, startTime: String, number: Int) {
        if PolarApp.isLoggingEnabled {
            lazy var method = request.httpMethod ?? ""
            lazy var server = (request.url?.absoluteString) ?? "<<none>>"
            lazy var statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            lazy var requestHeaderString = request.allHTTPHeaderFields?.map{ "-H \($0.key): \($0.value)" }.joined(separator: " ") ?? "<<none>>"
            lazy var requestBodyString = request.httpBody.flatMap({ String(data: $0, encoding: .utf8) }) ?? "<<none>>"
            lazy var responseDataString = responseData.flatMap({ String(data: $0, encoding: .utf8) })?.replacingOccurrences(of: "\n", with: "") ?? ""
            let endTime = Logger.initialTime.currentIntervalString()
            print("\(startTime)-\(endTime)-[\(Configuration.Brand)][API]🌐 #\(number) \(method) \(server) [\(statusCode)] ❤️ \(requestHeaderString) -B \(requestBodyString) ➡️ \(responseDataString)")
        }
    }
    
    private func logWarning(request: URLRequest, response: URLResponse, responseData: Data?, startTime: String, number: Int) {
        if PolarApp.isLoggingEnabled {
            lazy var method = request.httpMethod ?? ""
            lazy var server = (request.url?.absoluteString) ?? "<<none>>"
            lazy var statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            lazy var requestHeaderString = request.allHTTPHeaderFields?.map{ "-H \($0.key): \($0.value)" }.joined(separator: " ") ?? "<<none>>"
            lazy var requestBodyString = request.httpBody.flatMap({ String(data: $0, encoding: .utf8) }) ?? "<<none>>"
            lazy var responseDataString = responseData.flatMap({ String(data: $0, encoding: .utf8) })?.replacingOccurrences(of: "\n", with: "") ?? ""
            let endTime = Logger.initialTime.currentIntervalString()
            print("\(startTime)-\(endTime)-[\(Configuration.Brand)][API]🌐 #\(number) \(method) \(server) [\(statusCode)] 💛 \(requestHeaderString) -B \(requestBodyString) ➡️ \(responseDataString)")
        }
    }
}



