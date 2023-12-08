//
//  AnnotationsMapView.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import MapKit
import SwiftUI
import UIKit

@MainActor
struct AnnotationsMapView: UIViewRepresentable {
    private let items: [CityAnnotation]
    
    init(items: [CityAnnotation]) {
        self.items = items
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.visibleMapRect = .world
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        
        addAnnotations(in: uiView, items: items)
        addOverlay(in: uiView, items: items)
    }
    
    func makeCoordinator() -> AnnotationsMapViewCoordinator {
        AnnotationsMapViewCoordinator(self)
    }
}

@MainActor
private extension AnnotationsMapView {
    func addAnnotations(in mapView: MKMapView, items: [CityAnnotation]) {
        let annotations = items.map {
            let annotation = MKPointAnnotation()
            annotation.coordinate = $0.coordinates
            annotation.title = $0.name
            return annotation
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func addOverlay(in mapView: MKMapView, items: [CityAnnotation]) {
        let coordinates: [CLLocationCoordinate2D] = items
            .map { $0.coordinates }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        if let coordinate = coordinates.first {
            mapView.setCenter(coordinate, animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate
final class AnnotationsMapViewCoordinator: NSObject, MKMapViewDelegate {
    private let mapView: AnnotationsMapView
    
    init(_ mapView: AnnotationsMapView) {
        self.mapView = mapView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .appRed
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
