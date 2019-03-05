//
//  GooglePlacesAPI.swift
//  GetGoingClass
//
//  Created by Alla Bondarenko on 2019-01-21.
//  Copyright © 2019 SMU. All rights reserved.
//

import Foundation
import CoreLocation

class GooglePlacesAPI {

    class func requestPlaces(_ query: String, rankBy: String, radius: Double, coordinate: CLLocationCoordinate2D, isOpen: Bool, completion: @escaping(_ status: Int, _ json: [String: Any]?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.textPlaceSearch
        
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "key", value: Constants.apiKey),
            URLQueryItem(name: "opennow", value: "\(isOpen)")
        ]
        if(radius != 0){
            urlComponents.queryItems?.append(URLQueryItem(name: "radius", value: "\(radius)"))
            urlComponents.queryItems?.append(URLQueryItem(name: "location", value: "\(coordinate.latitude),\(coordinate.longitude)"))
        } else {
            urlComponents.queryItems?.append(URLQueryItem(name: "rankby", value: "\(rankBy)"))
        }
        
        if let url = urlComponents.url {
            NetworkingLayer.getRequest(with: url, timeoutInterval: 500) { (status, data) in

                if let responseData = data,
                    let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    completion(status, jsonResponse)
                } else {
                    completion(status, nil)
                }
            }
        }
    }

    class func requestPlacesNearby(for coordinate: CLLocationCoordinate2D, radius: Double, _ query: String?, isOpen: Bool, completion: @escaping(_ status: Int, _ json: [String: Any]?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.nearbySearch

        urlComponents.queryItems = [
            URLQueryItem(name: "location", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "\(Int(radius))"),
            URLQueryItem(name: "key", value: Constants.apiKey),
            URLQueryItem(name: "opennow", value: "\(isOpen)")
        ]

        if let keyword = query {
            urlComponents.queryItems?.append(URLQueryItem(name: "keyword", value: keyword))
        }

        if let url = urlComponents.url {
            NetworkingLayer.getRequest(with: url, timeoutInterval: 500) { (status, data) in

                if let responseData = data,
                    let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    completion(status, jsonResponse)
                } else {
                    completion(status, nil)
                }
            }
        }
    }

    class func requestPlaceDetails(for placeID: String, completion: @escaping(_ status: Int, _ json: [String: Any]?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.placeDetails

        urlComponents.queryItems = [
            URLQueryItem(name: "placeid", value: placeID),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]

        if let url = urlComponents.url {
            NetworkingLayer.getRequest(with: url, timeoutInterval: 500) { (status, data) in

                if let responseData = data,
                    let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    completion(status, jsonResponse)
                } else {
                    completion(status, nil)
                }
            }
        }
    }
}
