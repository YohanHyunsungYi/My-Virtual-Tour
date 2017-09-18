import UIKit
import MapKit
import CoreLocation
import CoreData


func savePins(_ annotataions: MKAnnotation ){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let pinForCoreData = NSEntityDescription.insertNewObject(forEntityName: "Pin_Coredata", into: context)
    
    print(annotataions.coordinate.longitude)
    print(annotataions.coordinate.latitude)
    
    var longitude = annotataions.coordinate.longitude
    var latitude = annotataions.coordinate.latitude
    
    longitude = longitude.round12()
    latitude = latitude.round12()
    
    print(longitude)
    print(latitude)
    
    pinForCoreData.setValue(longitude, forKey: "longitude")
    pinForCoreData.setValue(latitude, forKey: "latitude")
    appDelegate.saveContext()
}

func deletePhotos(_ photoToDelete: Photo ){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    managedObjectContext.delete(photoToDelete)
    appDelegate.saveContext()
    
}


func deletePins(_ annotataions: MKAnnotation ){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let entityDescription = NSEntityDescription.entity(forEntityName: "Pin_Coredata", in: context)
    let request = NSFetchRequest<NSFetchRequestResult>()
    request.entity = entityDescription
    
    var longitude = annotataions.coordinate.longitude
    var latitude = annotataions.coordinate.latitude
    
    print(longitude)
    print(latitude)
    
    
    //Find
    let pred = NSPredicate(format: "(latitude = %@) AND (longitude = %@)", String(latitude.round12()), String(longitude.round12()))
    request.predicate = pred
    
    do {
        var results = try context.fetch(request)
        
        context.delete(results[0] as! Pin_Coredata)
        
    } catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
    
    appDelegate.saveContext()
}

func getContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
}

func fetchPins(){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    do {
        appDelegate.pinList = try context.fetch(Pin_Coredata.fetchRequest())
    } catch {
        print("Could not Fetch \(String(describing: error)), \(error.localizedDescription)")
    }
}

func fetchlocation() -> MKCoordinateRegion? {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var location = StoredLocation()
    
    do {
        let temp = try context.fetch(StoredLocation.fetchRequest())
        print(temp)
        location = temp[temp.count-1] as! StoredLocation
        let span = MKCoordinateSpanMake((location.span1), (location.span2))
        let defaultLocation = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(location.latitude),
            longitude: CLLocationDegrees(location.longitude)
        )
        return MKCoordinateRegion(center: defaultLocation, span:span)
    } catch {
        print("Could not Fetch \(String(describing: error)), \(error.localizedDescription)")
    }
    return nil
}

func saveLocation(_ region: MKCoordinateRegion) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let regionForCoreData = NSEntityDescription.insertNewObject(forEntityName: "StoredLocation", into: context)
    regionForCoreData.setValue(region.center.longitude, forKey: "longitude")
    regionForCoreData.setValue(region.center.latitude, forKey: "latitude")
    regionForCoreData.setValue(region.span.latitudeDelta, forKey: "span1")
    regionForCoreData.setValue(region.span.longitudeDelta, forKey: "span2")
    
    appDelegate.saveContext()
}

func phasingFromFlickers ( longitude: Double, latitude: Double, completionHandler: @escaping (_ success: Bool,_ result: [UIImage]?, _ errorMessage: String?) -> Void ){
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var photos = [UIImage]()
    
    searchFlicker(longitude: longitude, latitude: latitude){ success, errorMessage in
        if( success ) {
            //search CoreData
            let downloadingQueue = DispatchQueue(label: "downloading", attributes: [])
            downloadingQueue.async{ () -> Void in
                for j in 0...appDelegate.parsedFlickerPhotos.count {
                    if j > 20 { break }
                    //get image URLs
                    let imageURL = URL(string: appDelegate.parsedFlickerPhotos[j])
                    
                    if let imageData = try? Data(contentsOf: imageURL!) {
                        photos.append(UIImage(data: imageData)!)
                    }
                }
                print("complete")
                completionHandler(true, photos, nil)
            }
        } else {
            //Phasing Fail
            print("Image does not exist")
            completionHandler(false, nil, errorMessage)
        }
    }
}
