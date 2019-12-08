//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Genuis on 26/11/2019.
//  Copyright © 2019 Abdullah ALAmri. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var activityIndicator: UIActivityIndicatorView!
    
    let annotation = MKPointAnnotation()
    var lat: Double = 0.0
    var lon: Double = 0.0
    var page: Int = 0
    var photos: [Photo] = []
    var images: [Images] = []
    var pin: Pin!
    var dataController: DataController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewFlowLayout()
        
        createActivityIndicator()
        
        self.collectionView.delegate = self
        
        images = fetchResultImages()
        if images.count > 0 {
            for image in images {
                images.append(image)
                collectionView.reloadData()
            }
        } else {
            getPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showActivityIndicator(true)
        showPin()
        getPhotos()
    }
    
    func fetchResultImages() -> [Images] {
        let fetchRequest: NSFetchRequest<Images> = Images.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            images = result
           showActivityIndicator(false)
        } catch {
            print(error)
            showActivityIndicator(false)
            alertMessage()
        }
        return images
    }
    
    @IBAction func loadNewCollection(_ sender: UIBarButtonItem) {
        newCollectionButton.isEnabled = false
        clearPhotos()
        photos = []
        images = []
        getPhotos()
        collectionView.reloadData()
    }
    
    func getPhotos() {
        showActivityIndicator(true)
       FlickrClient.searchPhotos(lat: lat, lon: lon, page: page, completion: { (photos, error) in
            if (photos != nil) {
                if photos?.pages == 0 {
                    self.noPhotosLabel.isHidden = false
                    self.newCollectionButton.isEnabled = false
                    self.showActivityIndicator(false)
                } else {
                    self.photos = (photos?.photo)!
                    let randomPage = Int.random(in: 1...photos!.pages)
                    self.page = randomPage
                    print(self.page)
                    self.getImageURL()
                    self.collectionView.reloadData()
                   self.showActivityIndicator(false)
                }
            } else {
                self.newCollectionButton.isEnabled = true
                self.showActivityIndicator(false)
                self.alertMessage()
            }
        })
    }
    
    func getImageURL() {
        for photo in photos {
            let Imagess = Images(context: dataController.viewContext)
            Imagess.imageUrl = photo.urlm
            Imagess.pin = pin
            images.append(Imagess)
            do {
                try self.dataController.viewContext.save()
            } catch {
                print(error)
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    func clearPhotos() {
        for image in images {
            dataController.viewContext.delete(image)
            do {
                try self.dataController.viewContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    
    func showPin() {
        mapView.removeAnnotations(mapView.annotations)
        annotation.coordinate.latitude = lat
        annotation.coordinate.longitude = lon
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.newCollectionButton.isEnabled = false
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let cellImage = images[indexPath.row]
        
        if cellImage.image != nil {
            cell.photoImageView.image = UIImage(data: cellImage.image!)
            self.newCollectionButton.isEnabled = true
        } else {
            cell.photoImageView.image = UIImage(named: "image-placeholder-350x350")
            
            if cellImage.imageUrl != nil {
                let url = URL(string: cellImage.imageUrl ?? "")
                FlickrClient.downloadPhoto(url: url!) { (data, error) in
                    if (data != nil) {
                        DispatchQueue.main.async {
                            cellImage.image = data
                            cellImage.pin = self.pin
                            do {
                                try self.dataController.viewContext.save()
                            } catch {
                                print("There was an error saving photos")
                            }
                            DispatchQueue.main.async {
                                cell.photoImageView?.image = UIImage(data: data!)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("error")
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.newCollectionButton.isEnabled = true
                    }
                    
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alertVC = UIAlertController(title: "Menu", message: "Select option?", preferredStyle: .alert)
        
        
        
        alertVC.addAction(UIAlertAction(title: "Show Picture", style: .default, handler: { (action: UIAlertAction) in
            alertVC.dismiss(animated: true, completion: nil)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PicShow")
            
            let cellImage = self.images[indexPath.row]
            PicShow.imageeee = UIImage(data: cellImage.image!)
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }))
        
            alertVC.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction) in
                
            let flickrPhoto = self.images[indexPath.row]
            self.dataController.viewContext.delete(flickrPhoto)
            self.images.remove(at: indexPath.row)
            do {
                try self.dataController.viewContext.save()
            } catch {
                print(error)
            }
                    self.collectionView.reloadData()}
                
        ))
        
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            alertVC.dismiss(animated: true, completion: nil)
            
        
        }))
       
        self.present(alertVC, animated: true)
        }
    

    func showActivityIndicator(_ isState: Bool) {
        activityIndicator.isHidden = !isState
        isState ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
          activityIndicator.center = self.view.center
        
        
    }

    
    func createActivityIndicator(){
        
        activityIndicator = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.gray)
        self.view.addSubview(activityIndicator)
        activityIndicator.bringSubviewToFront(self.view)
        activityIndicator.center = self.view.center
        
    }
    
    
  func collectionViewFlowLayout() {
        
    let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let width = UIScreen.main.bounds.width
    flowLayout.itemSize = CGSize(width: width / 5, height: width / 3)
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    collectionView!.collectionViewLayout = flowLayout

    }
    
    func alertMessage(){
        
        let alertVC = UIAlertController(title: "Error", message: "There was an error getting photos due to network issue!", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
        
        
    }
    


