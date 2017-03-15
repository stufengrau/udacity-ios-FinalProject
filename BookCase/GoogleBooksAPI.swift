//
//  GoogleBooksAPI.swift
//  BookCase
//
//  Created by heike on 14/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation

enum SearchGoogleBooksResult {
    case success
    case failure
}

class GoogleBooksAPI {
    
    // MARK: Properties
    private var session = URLSession.shared
    
    // Singleton
    static let shared = GoogleBooksAPI()
    private init() {}
    
    // MARK: Network Requests
    
    // Search Google Books 
    func searchGoogleBooks(_ searchTerm: String, completionHandler: @escaping (SearchGoogleBooksResult) -> Void) {
        
        let methodParameters = [
            GoogleBooksParameterKeys.Query: searchTerm,
            GoogleBooksParameterKeys.Results: GoogleBooksParameterValues.maxResults,
            GoogleBooksParameterKeys.APIKey: GoogleBooksAPIKey.APIKey
        ]
        
        let request = NSMutableURLRequest(url: googleBooksURLFromParameters(methodParameters))
        
        session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let parsedResult = self.getResult(data: data, response: response, error: error) else {
                completionHandler(.failure)
                return
            }
            
            // does the data contain a key "items"?
            guard let items = parsedResult[GoogleBooksAPI.GoogleBooksResponseKeys.Items] as? [[String:AnyObject]] else {
                completionHandler(.failure)
                return
            }
            
            debugPrint("Items: \(items)")
            
            completionHandler(.success)
            
            }.resume()
        
    }
    
    
    // Create Google Books Search URL from Parameters
    private func googleBooksURLFromParameters(_ parameters: [String:String]) -> URL {
        
        var components = URLComponents()
        components.scheme = GoogleBooksURL.APIScheme
        components.host = GoogleBooksURL.APIHost
        components.path = GoogleBooksURL.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // Given raw JSON, return a usable Foundation object
    private func convertData(_ data: Data?) -> AnyObject? {
        
        guard let data = data else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
    }
    
    // Return the parsed Result if no errors occured
    private func getResult(data: Data?, response: URLResponse?, error: Error?) -> [String: AnyObject]? {
        
        guard error == nil else {
            return nil
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            return nil
        }
        
        guard let parsedResult = convertData(data) as? [String: AnyObject] else {
            return nil
        }
        
        return parsedResult
    }
}
