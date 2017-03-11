//
//  TheaterAnnotation.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import Foundation
import MapKit

//protocolo
class TheaterAnnotation: NSObject, MKAnnotation {
    //para adequar ao tipo de protocolo e necessario criar algumas variaveis
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        
    }
    
    func getAnnotationView() -> MKAnnotationView {
        let annotationView = MKAnnotationView(annotation: self, reuseIdentifier: "Theater")
        annotationView.canShowCallout = true
        annotationView.image = UIImage(named:"theaterIcon")
        
        //animacao
        /*let imageView = UIImageView(image: UIImage(named:"theaterIcon"))
        imageView.frame.origin.y = -200
        annotationView.addSubview(imageView)
        
        //animacao de view, estado final da view
        UIView.animate(withDuration: 0.75){
            //anima a properdade de origem y, sai de -200 para 0 na duracao passada por parametro
            imageView.frame.origin.y = 0
        }*/
        
        return annotationView
    }
}
