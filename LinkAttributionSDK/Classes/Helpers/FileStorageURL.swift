import Foundation

public struct FileStorageURL{
    public let url: URL;
    
    public init(URL theURL: URL) {
        url = theURL;
    }
    
    public init(filePath: String) {
        url = URL(fileURLWithPath: filePath);
    }
    
    public func file(name: String) -> URL {
        return url.appendingPathComponent(name, isDirectory: false);
    }
    
    /** Default is check and create the sub directory, disable it use 'creating = false' */
    public func appendingSubDirectory(_ subDirectory: String, creating: Bool = true) -> FileStorageURL {
        let newUrl = url.appendingPathComponent(subDirectory);
        if creating {
            checkAndCreateDirectories(forURL: newUrl);
        }
        return FileStorageURL(URL: newUrl);
    }
    
    public static let temporaryDirectory = FileStorageURL(filePath: NSTemporaryDirectory());
    public static let sdkDirectory = getLibraryDirectoryURL().appendingSubDirectory(Configuration.Brand + "-aRDrdAOPcD");
    
}

fileprivate extension FileStorageURL {
    
    static func getLibraryDirectoryURL() -> FileStorageURL {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true);
        let basePath = paths.first!;
        return FileStorageURL(filePath: basePath);
    }
    
    func checkAndCreateDirectories(forURL url: URL) {
        let fileManager = FileManager.default;
        if !fileManager.fileExists(atPath: url.path) {
            
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil);
            } catch let error {
                print("WARNING: Couldn't create path<\(url)> with err \(error)");
            }
            
        }
    }
}
