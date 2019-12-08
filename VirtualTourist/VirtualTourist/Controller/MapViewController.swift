//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Genuis on 26/11/2019.
//  Copyright © 2019 Abdullah ALAmri. All rights reserved.
//


import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textDeletePin: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    var activityIndicator: UIActivityIndicatorView!
    var annotations = [MKPointAnnotation]()
    var annotation = MKPointAnnotation()
    var pins: [Pin] = []
    var dataController: DataController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      createActivityIndicator()
       gestureRecognizer ()
       
        showActivityIndicator(true)
        pins = fetchPins()
        if pins.count > 0 {
            for pin in pins {
            let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapView.addAnnotation(annotation)
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showActivityIndicator(true)
        mapView.deselectAnnotation(annotations as? MKAnnotation, animated: false)
       showActivityIndicator(false)
    }
    
    func fetchPins() -> [Pin] {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            pins = result
           showActivityIndicator(false)
        } catch {
            print(error)
            showActivityIndicator(false)
        }
        return pins
    }
    
    @objc func longPress(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == .began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            print(annotation.coordinate)
            mapView.addAnnotation(annotation)
            do {
                try dataController.viewContext.save()
            } catch {
                print(error)
            }
            pins.append(pin)
            mapView.reloadInputViews()
            showActivityIndicator(false)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { guard annotation is MKPointAnnotation else { print(Error.self); return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if isEditing, let viewAnnotation = view.annotation {
            for pin in pins {
                if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude {
                    dataController.viewContext.delete(pin)
                }
            }
            do {
                try dataController.viewContext.save()
            } catch {
                print(error)
            }
            mapView.removeAnnotation(viewAnnotation)
            return
        }
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "showAlbum") as! PhotoAlbumViewController
        controller.lat = view.annotation?.coordinate.latitude ?? 0.0
        controller.lon = view.annotation?.coordinate.longitude ?? 0.0
        for pin in pins {
            if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude {
                controller.pin = pin
            }
            
        }
        controller.dataController = dataController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func showActivityIndicator(_ isState: Bool) {
        activityIndicator.isHidden = !isState
        isState ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
      
    }
    

    
    override func setEditing(_ editing:Bool, animated:Bool) {
        super.setEditing(editing, animated: animated)
        if (self.isEditing) {
            toolBar.isHidden = false
            textDeletePin.isHidden = false
            self.editButtonItem.title = "Done"
        } else {
            toolBar.isHidden = true
            textDeletePin.isHidden = true
            self.editButtonItem.title = "Edit"
        }
    }
    
    func gestureRecognizer () {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        mapView.addGestureRecognizer(gestureRecognizer)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem!.title = "Edit"
        
    }
    
    func createActivityIndicator(){
        
        activityIndicator = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.gray)
        self.view.addSubview(activityIndicator)
        activityIndicator.bringSubviewToFront(self.view)
        activityIndicator.center = self.view.center
        
    }
}

