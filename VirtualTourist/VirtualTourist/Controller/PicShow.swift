//
//  PicShow.swift
//  VirtualTourist
//
//  Created by Genuis on 07/12/2019.
//  Copyright © 2019 Abdullah ALAmri. All rights reserved.
//

import Foundation
import UIKit
class PicShow: UIViewController ,
UINavigationControllerDelegate{
    @IBOutlet weak var share: UIBarButtonItem!
    
    @IBOutlet weak var imagesh: UIImageView!
    static var imageeee:UIImage!

    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        imagesh.image = PicShow.imageeee
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        
        
        let controller = UIActivityViewController(activityItems: [generateImage()], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            
            (activity, completed, items, error) in if completed{
             
            }
            
        }
        
        
        self.present(controller, animated: true, completion: nil)
    
}
    func generateImage() -> UIImage {
      
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let Image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return Image
}
}
