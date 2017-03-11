//
//  TheartersMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit

class TheartersMapViewController: UIViewController {

    //MARK: - Properties
    var elementName: String!
    var theater: Theater!
    var theaters:  [Theater] = []
    lazy var locationManager = CLLocationManager()
    var poiAnnotations: [MKPointAnnotation] = []
    
    
    //MARK: IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.mapType = .standard
        mapView.delegate = self
        //
        
        mapView.showsUserLocation = true
        
        loadXML()
        requestLocation()
    }
    
    
    
    //MARK: - Methods
    func requestLocation(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                print("Usuario ja autorizou!")
                monitorUserLocation()
            case .notDetermined:
                print("Usuario ainda nao autorizou")
                locationManager.requestWhenInUseAuthorization()
            case .denied:
                print("Usuario negou autorizacao!")
            case .restricted:
                print("O acesso ao GPS esta bloqueado")
            default:
                break
            }
        }
    }
    
    func loadXML(){
        
        if let xmlURL = Bundle.main.url(forResource: "theaters.xml", withExtension: nil), let xmlParser = XMLParser(contentsOf: xmlURL){
            
            //inicia o parser do arquivo, quando se tem self e necessario implantar o protocolo delegate
            xmlParser.delegate = self
            xmlParser.parse()
            
        }
        
    }
    
    func monitorUserLocation() {
        //monitoramento da localizacao
        //locationManager.startUpdatingLocation()
        //locationManager.stopUpdatingLocation()
        
    }
    
    func getRoute(destination: CLLocationCoordinate2D){
        let request = MKDirectionsRequest()
        //para onde quero ir
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
        
        let directions = MKDirections(request: request)
        directions.calculate{(response: MKDirectionsResponse?, error: Error?) in
            if error == nil {
                guard let response = response else {return}
                //recupera a primeira rota
                let route = response.routes.first!
                print("Nome:", route.name)
                print("Distancia:", route.distance)
                print("Duration:", route.expectedTravelTime)
                
                for step in route.steps{
                    print("Em \(step.distance) metros, \(step.instructions)")
                }
                
                DispatchQueue.main.async{
                
                //desenho vetorial no mapview
                self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                }
            }
        }
    }
}

//protocolo delegate para fazer o parse das informaçoes
extension TheartersMapViewController: XMLParserDelegate{
    
    //encontrar o elemento <>
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("Start: ", elementName)
        //verifica o ponto onde foi iniciado
        self.elementName = elementName
        if elementName == "Theater" {
            theater = Theater()
            
        }
    }
    //encontrar o conteudo
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let content = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !content.isEmpty{
            print("Content: ",content)
            
            //variavel global
            switch elementName {
            case "name":
                theater.name = content
            case "address":
                theater.address = content
            case "latitude":
                theater.latitude = Double(content)
            case "longitude":
                theater.longitude = Double(content)
            case "url":
                theater.url = content
            default:
                break
            }
        }
    }
    //encontrar o fim do elemento <>
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("End: ", elementName)
        
        if elementName == "Theater"{
            self.theaters.append(theater)
        }
    }
    
    //final do documento
    func parserDidEndDocument(_ parser: XMLParser) {
        print("Total de cinemas", self.theaters.count)
        addTheatersToMap()
    }
    
    func addTheatersToMap(){
        
        for theater in theaters{
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            //pontos
            //let annotation = MKPointAnnotation()
            //annotation.coordinate = coordinate
            let annotation = TheaterAnnotation(coordinate: coordinate)
            annotation.title = theater.name
            annotation.subtitle = theater.url
            mapView.addAnnotation(annotation)
        }
        
        //fiap paulista maps -23.5699628,-46.6823249
        //cria uma regiao no map que define a latitude e longitude e o espaco
        //definindo regi;áo
        /*let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:-23.5699628, longitude:-46.6823249), 2000, 2000)
        mapView.setRegion(region, animated: true)*/
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
        
    }
    
}

extension TheartersMapViewController: MKMapViewDelegate{
    
    //tracar rota
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let render = MKPolylineRenderer(overlay:overlay)
            render.strokeColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            render.lineWidth = 6.0
            return render
        }else{
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    //metodo utilizado toda vez for chamar o alfinete, eu deixo de receber a view padrao e passo a dizer qual view quero escolher
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!
        
        //verifica o tipo da annotation
        if annotation is MKPinAnnotationView{
            //alterar annotation - alfinete do mapa - reutilizar celulas
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "TheaterPin") as!
                MKPinAnnotationView
            if annotationView == nil{
                //annotation tem os dados do title, latitude etc
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "TheaterPin")
                (annotationView as! MKPinAnnotationView).canShowCallout = true
                (annotationView as! MKPinAnnotationView).pinTintColor = .blue
                (annotationView as! MKPinAnnotationView).animatesDrop = true
            }else{
                annotationView?.annotation = annotation
            }
        } else if annotation is TheaterAnnotation{
            annotationView = (annotation as! TheaterAnnotation).getAnnotationView()
            //aparece info ao lado esquerdo ou direito do alfinete
            let btLeft = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            btLeft.setImage(UIImage(named:"car"), for: .normal)
            annotationView.leftCalloutAccessoryView = btLeft
            
            let btRight = UIButton(type: UIButtonType.detailDisclosure)
            annotationView.rightCalloutAccessoryView = btRight
            
        }
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //clique no botao esquerdo
        if control != view.leftCalloutAccessoryView {
            let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            vc.url = view.annotation!.subtitle!
            present(vc, animated:  true)
        }else{
            print("Tracando rota!!")
            getRoute(destination: view.annotation!.coordinate)
        }
        
        //remove a tra;a anterior e acrescenta uma nova
        mapView.removeOverlays(mapView.overlays)
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
    
    
}

//MARK: -CLLocationManagerDelegate
extension TheartersMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Acabou de autorizar")
            monitorUserLocation()
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("userLocation:", userLocation.location!.speed)
        //regiao centralizada na coordenada do usuario e tem uma area de 500
        //let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
        //mapView.setRegion(region, animated: true)
    }
    
}

//MARK: - UISearchBarDelegate
extension TheartersMapViewController: UISearchBarDelegate{
    
    //busca locais proximo a area selecionada
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //pontos de interesse de acordo com o usuario, barra de pesquisa
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        //necessario colocar uma regiao, limitado a 10, faz uma pesquisa na regiao que estamos pesquisando na tela
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response: MKLocalSearchResponse?, error: Error?) in
            if error == nil{
                guard let response = response else {return}
                
                DispatchQueue.main.async {
                
                self.mapView.removeAnnotations(self.poiAnnotations)
                self.poiAnnotations.removeAll()
                
                for item in response.mapItems{
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    self.poiAnnotations.append(annotation)
                }
                    self.mapView.addAnnotations(self.poiAnnotations)
                }
            }
            
            searchBar.resignFirstResponder()
        }
    }
    
}
