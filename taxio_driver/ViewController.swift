//
//  ViewController.swift
//  taxio_driver
//
//  Created by Fatema Sherif on 7/8/22.
//

import UIKit
import FirebaseDatabase
import CoreLocation
import MapKit
import FirebaseFirestore

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var lbl_src: UILabel!
    @IBOutlet weak var lbl_dest: UILabel!
    
    
//    var ref: DatabaseReference!
    
    
    var srcName = ""
    var destName = ""
    
    var srcLat = Double()
    var srcLng = Double()
    var destLat = Double()
    var destLng = Double()
    
    let srcAnnotation = MKPointAnnotation()
    let destAnnotation = MKPointAnnotation()
    
    var docRef: DocumentReference!
    var rideListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        docRef = Firestore.firestore().document("user/order")
        
//        ref = Database.database().reference()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rideListener = docRef.addSnapshotListener { [self] (docSnapshot, error ) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let data = docSnapshot.data()
            self.destName = data!["destName"] as? String ?? ""
            self.srcName = data!["srcName"] as? String ?? ""
            self.srcLng = data!["srcLng"] as? Double ?? 0
            self.srcLat = data!["srcLat"] as? Double ?? 0
            self.destLng = data!["destLng"] as? Double ?? 0
            self.destLat = data!["destlat"] as? Double ?? 0
            
            self.lbl_src.text = self.srcName
            self.lbl_dest.text = self.destName
            self.orderView.isHidden = false
            
            self.srcAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.srcLat, longitude: self.srcLng)
            self.srcAnnotation.title = "location"
            self.destAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.destLat, longitude: self.destLng)
            self.destAnnotation.title = "destination"
            
            self.map.addAnnotations([self.srcAnnotation,self.destAnnotation])
            
            DrawRoute()

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rideListener.remove()
    }
    

    
    

    
//    func rideObserver(){
//        Database.database().reference().child("ride").observeSingleEvent(of : .value, with : { [self](Snap) in
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {granted, error in
//                if granted{
//                    print("granted")
//                    self.scheduleNotification()
//                }else{
//                    print("denied")
//                }
//            }
//
//            if let snapDict = Snap.value as? [String:AnyObject]{
//                print("sssssss\(Snap.value ?? "ok")")
//                self.destName = snapDict["destName"]! as! String
//                self.srcName = snapDict["srcName"]! as! String
//                self.srcLng = snapDict["srcLng"]! as! Double
//                self.srcLat = snapDict["srcLat"]! as! Double
//                self.destLng = snapDict["destLng"]! as! Double
//                self.destLat = snapDict["destlat"]! as! Double
//
//                print("\(self.srcName)   \(self.destName)")
//                print("slat\(self.srcLng)")
//                print("slng\(self.srcLat)")
//                print("dlat\(self.destLng)")
//                print("dlng\(self.destLat)")
//
//
//           }
//        })
//    }
    
    func scheduleNotification(){
        let content = UNMutableNotificationContent()
        content.title = " New Ride "
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(3), repeats: false)
        
        let request = UNNotificationRequest(identifier: "", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myCustomPin")
        switch annotation.title{
        case "location":
            annotationView.markerTintColor = .blue
//            annotationView.glyphImage = UIImage(named: "blueCircle")
            break
        case "destination":
            annotationView.markerTintColor = .lightGray
//            annotationView.glyphImage = UIImage(named: "grayCircle")
            break
        default:
            break
        }
        
        return annotationView
    }

    
    func DrawRoute() {
        let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: srcLat, longitude: srcLng), addressDictionary: nil)
        let destinationPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destLat, longitude: destLng), addressDictionary: nil)
        
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .automobile
        
        let direction = MKDirections(request: directionRequest)
        
        
        direction.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("ERROR FOUND : \(error.localizedDescription)")
                }
                return
            }
            let route = response.routes[0]
            self.map.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            self.map.setRegion(MKCoordinateRegion(route.polyline.boundingMapRect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendere = MKPolylineRenderer(overlay: overlay)
        rendere.lineWidth = 4
        rendere.strokeColor = .darkGray
        
        return rendere
    }
}

