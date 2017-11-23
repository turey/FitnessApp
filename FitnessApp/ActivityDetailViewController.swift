//
//  ActivityDetailViewController.swift
//  FitnessApp
//
//  Created by Bishal Wagle on 11/23/17.
//  Copyright © 2017 FitnessGroup. All rights reserved.
//

import UIKit
import MapKit

class ActivityDetailViewController: UIViewController {
    var MapView: MKMapView!
    var activity : Activity!
    var pathPoints : [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView = MKMapView()
        self.view.addSubview(MapView)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MapView.frame = self.view.bounds
        
        self.setupPathPoints()
        self.addLine()
        
        MapView.delegate = self
    }
    
    func setupPathPoints(){
        self.pathPoints = []
        var pointToZoom : CLLocation!
        if(activity != nil){
            for item in activity.Path{
                let pathPoint = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
                if(pointToZoom == nil){
                    pointToZoom = CLLocation(latitude: item.latitude, longitude: item.longitude)
                    zoomToLocation(location: pointToZoom)
                    
                }
                self.pathPoints.append(pathPoint)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ActivityDetailViewController: MKMapViewDelegate{
    private func zoomToLocation(location: CLLocation){
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        MapView.setRegion(region, animated: true)
        //        MapView.showsUserLocation = true
    }
    
    private func addLine(){
        let testline = MKPolyline(coordinates: pathPoints, count: self.pathPoints.count)
        MapView.add(testline)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline{
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .blue
            lineRenderer.lineWidth = 2.0
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

