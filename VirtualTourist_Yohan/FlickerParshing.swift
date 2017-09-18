//
//  FlickerParshing.swift
//  VirtualTourist_Yohan
//
//  Created by Yohan Yi on 2017. 6. 25..
//  Copyright © 2017년 Yohan Yi. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreLocation


func searchFlicker(longitude: Double, latitude: Double, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void ) {
    let methodParameters = [
        Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
        Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
        Constants.FlickrParameterKeys.BoundingBox: bboxString(longitude: longitude, latitude: latitude),
        Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
        Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
        Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
        Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
    ]
    displayImageFromFlickrBySearch(methodParameters as [String:AnyObject]){ success, errorMessage in
        if( success ) {
            completionHandler(true, nil)
        } else {
            completionHandler(false, errorMessage)
        }
    }

}

func bboxString(longitude: Double, latitude: Double) -> String {
    // ensure bbox is bounded by minimum and maximums
    
    let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
    let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
    let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
    let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
    
    return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
}

func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void ){
    
    // create session and request
    let session = URLSession.shared
    let request = URLRequest(url: flickrURLFromParameters(methodParameters))
    
    // create network request
    let task = session.dataTask(with: request) { (data, response, error) in
        
        // if an error occurs, print it and re-enable the UI
        func displayError(_ error: String) {
            print(error)
            completionHandler(false, error)
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            displayError("There was an error with your request: \(String(describing: error))")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            displayError("Your request returned a status code other than 2xx!")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            displayError("No data was returned by the request!")
            return
        }
        
        // parse the data
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            displayError("Could not parse the data as JSON: '\(data)'")
            return
        }
        
        /* GUARD: Did Flickr return an error (stat != ok)? */
        guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
            displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
            return
        }
        
        /* GUARD: Is "photos" key in our result? */
        guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
            displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
            return
        }
        
        /* GUARD: Is "pages" key in the photosDictionary? */
        guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
            displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
            return
        }
        
        // pick a random page!
        let pageLimit = min(totalPages, 40)
        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
        displayImageFromFlickrBySearch(methodParameters, withPageNumber: randomPage){ success, errorMessage in
            if( success ) {
                print( "Login Success" )
                completionHandler(true, nil)
            } else {
                completionHandler(false, errorMessage)
            }
        }
    }
    
    // start the task!
    task.resume()
}

// FIX: For Swift 3, variable parameters are being depreciated. Instead, create a copy of the parameter inside the function.

func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void ){
    
    var parsedFlickerPhotos = [String]()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // add the page to the method's parameters
    var methodParametersWithPageNumber = methodParameters
    methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
    
    // create session and request
    let session = URLSession.shared
    let request = URLRequest(url: flickrURLFromParameters(methodParameters))
    
    // create network request
    let task = session.dataTask(with: request) { (data, response, error) in
        
        // if an error occurs, print it and re-enable the UI
        func displayError(_ error: String) {
            print(error)
            completionHandler(false, error)
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            displayError("There was an error with your request: \(String(describing: error))")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            displayError("Your request returned a status code other than 2xx!")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            displayError("No data was returned by the request!")
            return
        }
        
        // parse the data
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            displayError("Could not parse the data as JSON: '\(data)'")
            return
        }
        
        /* GUARD: Did Flickr return an error (stat != ok)? */
        guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
            displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
            return
        }
        
        /* GUARD: Is the "photos" key in our result? */
        guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
            displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
            return
        }
        
        /* GUARD: Is the "photo" key in photosDictionary? */
        guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
            displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
            return
        }
        
        if photosArray.count == 0 {
            displayError("No Photos Found. Search Again.")
            return
        } else {
            for i in 0...photosArray.count {
                if i > 20 {
                    break
                }
                let photoDictionary = photosArray[i] as [String: AnyObject]
                
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return
                }
                parsedFlickerPhotos.append(imageUrlString)
            }
            print(parsedFlickerPhotos)
            appDelegate.parsedFlickerPhotos = parsedFlickerPhotos
            completionHandler(true, nil)
        }
    }
    
    // start the task!
    task.resume()
}

// MARK: Helper for Creating a URL from Parameters

func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
    
    var components = URLComponents()
    components.scheme = Constants.Flickr.APIScheme
    components.host = Constants.Flickr.APIHost
    components.path = Constants.Flickr.APIPath
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
        let queryItem = URLQueryItem(name: key, value: "\(value)")
        components.queryItems!.append(queryItem)
    }
    
    return components.url!
}


func phasingFromFlickerImage (_ url:String, completionHandler: @escaping (_ image: UIImage, _ success: Bool, _ errorMessage: String?) -> Void ) {
    
    var returnImage = UIImage()
    
    let downloadingQueue = DispatchQueue(label: "downloading", attributes: [])
    downloadingQueue.async{ () -> Void in
        let imageURL = URL(string: url)
       
        if let imageData = try? Data(contentsOf: imageURL!) {
            returnImage = UIImage(data: imageData)!
        }
        
        print("complete")
        completionHandler(returnImage, true, nil)
    }
}

