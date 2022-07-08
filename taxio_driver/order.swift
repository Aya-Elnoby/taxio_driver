//
//  order.swift
//  taxio_driver
//
//  Created by Fatema Sherif on 7/8/22.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class order: UIViewController, CLLocationManagerDelegate {
    
    
    var dbRef : DatabaseReference?
    
    @IBOutlet weak var map: MKMapView!
    
    private  var locationManager : CLLocationManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = Database.database().reference()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if isLocationServiceEnabled() {
            checkAuthorization()
        }else{
            showAlert(msg: "Please enable location service")
        }
    }
    
    func isLocationServiceEnabled() -> Bool{
        return CLLocationManager.locationServicesEnabled()
    }
    
    func checkAuthorization(){
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            map.showsUserLocation = true
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            map.showsUserLocation = true
            break
        case.denied:
            showAlert(msg: "Please authorize access to location")
            break
        case .restricted:
            showAlert(msg: "Authorization restricted")
            break
        default:
            print("default")
            break
        }
    }


    
    func zoomToUserLocation(location: CLLocation){
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            map.showsUserLocation = true
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            map.showsUserLocation = true
            break
        case.denied:
            showAlert(msg: "Please authorize access to location")
            break
        default:
            print("default")
            break
        }
    }
    
    func showAlert(msg: String){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "close", style: .default))
        present(alert, animated: true, completion: nil)
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
//            print("location: \(location.coordinate)")
            zoomToUserLocation(location: location)
            let cordinates = ["latitude" : location.coordinate.latitude, "longitude" : location.coordinate.longitude]
//            self.getPlaceName(location.coordinate)
            self.dbRef?.child("driver_points").setValue(cordinates)

        }
    }
}

