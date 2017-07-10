//
//  PhotoAlbumViewController.swift
//  VirtualTourist_Yohan
//
//  Created by Yohan Yi on 2017. 6. 19..
//  Copyright © 2017년 Yohan Yi. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreLocation
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var newCollectionLabel: UIButton!
    @IBOutlet var selectedMapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var results = [Any]()
    var selectedPin = CLLocationCoordinate2D()
    var isdelete = false
    var toDeletePhoto = Photo()
    var downloaded = false
    var isAlreadyStored = false
    var selectedPinfromCoredata = Pin_Coredata()
    var index = IndexPath()
    
    let notificationCenter = NotificationCenter.default

    
    var photos: [UIImage] = [UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!]
    
    var photoURLs: [String] = ["","","","","","","","","","","","","","","","","","","","",""]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        //Find Same Pin Data at CoreData
        let entityDescription = NSEntityDescription.entity(forEntityName: "Pin_Coredata", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        //Find
        let pred = NSPredicate(format: "(latitude = %@) AND (longitude = %@)", String(selectedPin.latitude), String(selectedPin.longitude))
        request.predicate = pred
        
        
        do {
            results = try managedObjectContext.fetch(request)
            
            self.selectedPinfromCoredata = results[0] as! Pin_Coredata

            //If Foudnd !!!
            if ((self.selectedPinfromCoredata.photos)?.count)! > 0  {
                
                let photoArrayFromCoreData = Array(self.selectedPinfromCoredata.photos!)
                
                print(photoArrayFromCoreData)
                
                for i in 0...photoArrayFromCoreData.count - 1 {
                    if i > 21 { break }
                    if let temp = UIImage(data: (photoArrayFromCoreData[i] as! Photo).photoFromFlicker! as Data) {
                        print(i)
                        photos[i] = temp
                    }
                }
                
                isAlreadyStored = true
            } else {
                
                getCollectionFromFlicker()
            }
            
        }catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }

        //Set Default Region - load from CoreData which is saved last time
        selectedMapView.setRegion(setSelectedRegion(), animated: true)
    }
    
    
    func getCollectionFromFlicker(){
        
        self.photos = [UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!, UIImage(named: "placeHolder.png")!]
        
        let photoArrayFromCoreData = Array(self.selectedPinfromCoredata.photos!)
        
       
        if photoArrayFromCoreData.count > 0 {
            for i in 0...photoArrayFromCoreData.count - 1 {
                if i > 21 { break }
                print(i)
                deletePhotos(photoArrayFromCoreData[i] as! Photo)
            }
        }
        self.collectionView.reloadData()
        
        searchFlicker(longitude: selectedPin.longitude, latitude: selectedPin.latitude){ success, errorMessage in
            if( success ) {
                //search CoreData
                print("get URLs From Flickers")
                self.downloaded = true
                
                for i in 0...self.appDelegate.parsedFlickerPhotos.count - 1 {
                    phasingFromFlickerImage(self.appDelegate.parsedFlickerPhotos[i]){ (image, success, error) in
                        if success {
                            self.photos[i] = image
                            self.photoURLs[i] = self.appDelegate.parsedFlickerPhotos[i]
                            
                            let photoToInsert = UIImageJPEGRepresentation(image,1)! as NSData
                            let newPhoto = Photo(photoToInsert, self.managedObjectContext)
                            newPhoto.pin = self.selectedPinfromCoredata
                            newPhoto.url = self.appDelegate.parsedFlickerPhotos[i]
                            
                            do {
                                try self.managedObjectContext.save()
                                print(i)
                            } catch {
                                print("error\(error.localizedDescription)")
                            }
                            
                            self.notificationCenter.post(name: NSNotification.Name(rawValue: "simple-notification"), object: nil)
                        }
                    }
                }
                self.isAlreadyStored = true
            } else {
                //Phasing Fail
                print("Image does not exist")
            }
        }
    }
    
    
    @IBAction func getNewCollection(_ sender: Any) {
        
        if isdelete {
            deletePhotos(toDeletePhoto)
            collectionView.deleteItems(at: [self.index])

            
            self.collectionView.reloadData()
            isdelete = false
            self.newCollectionLabel.setTitle("NEW COLLECTION", for: .normal)
            
        } else {
            getCollectionFromFlicker()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isdelete = true
        self.newCollectionLabel.setTitle("Tap To Delete", for: .normal)
        self.index = indexPath
        
        let photoArrayFromCoreData = Array(self.selectedPinfromCoredata.photos!)

        self.toDeletePhoto = (photoArrayFromCoreData[indexPath[1]] as! Photo)
    }
    
    func setSelectedRegion() -> MKCoordinateRegion {
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let annotation = MKPointAnnotation()
    
        var location = CLLocationCoordinate2D()
        location.latitude = self.selectedPin.latitude
        location.longitude = self.selectedPin.longitude
        
        annotation.coordinate = location
        selectedMapView.addAnnotation(annotation)
        
        return MKCoordinateRegion(center: location, span:span)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! collectionViewCell
        
        cell.image.image = UIImage(named: "placeHolder.png")
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.hidesWhenStopped = true
   
        if isAlreadyStored {
            cell.activityIndicator.stopAnimating()
            cell.image.image = self.photos[indexPath[1]]
        } else {
            notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "simple-notification"),
                                           object: nil,
                                           queue: OperationQueue.main,
                                           using: { (n: Notification!) -> () in
                                            cell.activityIndicator.stopAnimating()
                                            cell.image.image = self.photos[indexPath[1]]
            })
        }
        
        return cell
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        self.collectionView.reloadData()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 3
    }
    
}

