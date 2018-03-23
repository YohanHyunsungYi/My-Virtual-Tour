//
//  ViewController.swift
//  VirtualTourist_Yohan
//
//  Created by Yohan Yi on 2017. 6. 18..
//  Copyright © 2017년 Yohan Yi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {


    @IBOutlet var mapView: MKMapView!
    @IBOutlet var deleteLabel: UILabel!

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedPin = CLLocationCoordinate2D()
       // ["longitude": 0.0, "latitude": 0.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //Set Default Region - load from CoreData which is saved last time
        mapView.setRegion(setRegion(), animated: true)
        
        //Put Pins
        refreshPins()

        //Long Press Gesture Recognizer
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        
        //Hide Delete Label
        deleteLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        deleteLabel.isHidden = true
        saveLocation(mapView.region)
        refreshPins()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveLocation(mapView.region)
    }
    
    func refreshPins(){
        mapView.removeAnnotations(mapView.annotations)
        fetchPins()
    
        for temp in appDelegate.pinList {
            var location = CLLocationCoordinate2D()
            location.latitude = temp.latitude
            location.longitude = temp.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func setRegion() -> MKCoordinateRegion {
        // WILL CHANGE Set Default Region
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if !launchedBefore  {
            //If luanchgin first Time - 현재 위치로 바꾸기
            let span = MKCoordinateSpanMake(10, 10)
            let defaultLocation = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(34.0652),
                longitude: CLLocationDegrees(-118.303)
            )
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            print("FirstTime Luanch")
            return MKCoordinateRegion(center: defaultLocation, span:span)
        } else {
            //ELSE - load from CoreData which is saved last time
            print("Stored Last View")
            return fetchlocation()!
        }
    }
    
    // Add Pin to Map
    func addPinToMap(location: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        savePins(annotation)
        refreshPins()
    }
    
    
    @IBAction func edit(_ sender: Any) {
        if deleteLabel.isHidden == false {
            deleteLabel.isHidden = true
        } else {
            deleteLabel.isHidden = false
        }
    }
    
    
    //////////////////////Handle Long Press - add Pin//////////////////////
    
    func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        if deleteLabel.isHidden == true {
            addPinToMap(location: touchMapCoordinate)
        }
    }

    //////////////////////Pin SELECTED////////////////////////
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "Pin"
        var view: MKPinAnnotationView
            
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation as MKAnnotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation as MKAnnotation, reuseIdentifier: identifier)
            view.canShowCallout = false
            view.animatesDrop = true
            view.isDraggable = false
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if deleteLabel.isHidden == true {
            
            self.selectedPin = (view.annotation?.coordinate)!
            print(self.selectedPin.latitude)
            print(self.selectedPin.longitude)
            self.performSegue(withIdentifier: "PhotoAlbumSegue", sender: self)
        } else {
            deletePins(view.annotation!)
            mapView.removeAnnotation(view.annotation!)
            print("delete Pin")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoAlbumViewController = segue.destination as! PhotoAlbumViewController
        photoAlbumViewController.selectedPin = self.selectedPin
    }
    
}

