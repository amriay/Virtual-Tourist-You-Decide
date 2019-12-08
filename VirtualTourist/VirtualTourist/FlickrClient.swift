//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Genuis on 24/11/2019.
//  Copyright © 2019 Abdullah ALAmri. All rights reserved.
//

import Foundation

class FlickrClient {

    enum Endpoints {
        
        static let base = "https://api.flickr.com/services/rest"
        static let photoSearch = "?method=flickr.photos.search"
        static let apiKey = "49a1e77aa399c3a23a9fca742e91480d"
        
        case gettingPhotos(Double, Double, Int)
        
        var stringValue: String {
            switch self {
                
            case .gettingPhotos(let lat, let lon, let page):
            return Endpoints.base + Endpoints.photoSearch + "&extras=url_m" + "&api_key=\(Endpoints.apiKey)" + "&lat=\(lat)" + "&lon=\(lon)" + "&per_page=30" + "&page=\(page)" + "&format=json&nojsoncallback=1"
                
            }
            
        }
        
        var url: URL {
            return URL(string: stringValue)!
            
        }
        
      }

    class func searchPhotos(lat: Double, lon: Double, page: Int, completion: @escaping (Photos?, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.gettingPhotos(lat, lon, page).url)
        print(request)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil, error)
            }
            guard let data = data else {
                
                DispatchQueue.main.async {
                    
                    completion(nil, error)
                 
                }
                return
            }
            do {
                let response = try JSONDecoder().decode(PhotoResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.photos, nil)
                    print(response.photos)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                    
                }
            }
        }
        task.resume()
    }
    
    class func downloadPhoto(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
    

}
