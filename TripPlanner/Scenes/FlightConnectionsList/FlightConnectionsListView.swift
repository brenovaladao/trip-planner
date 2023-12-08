//
//  FlightConnectionsListView.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import MapKit
import SwiftUI

public struct FlightConnectionsListView<ViewModel: FlightConnectionsListViewModeling>: View {
    @StateObject private var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        content
    }
    
    private var content: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section(
                    content: {
                        // TODO: Move to different getters / views
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else if let routeInfo = viewModel.routeInfo {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(routeInfo)
                                    .bold()
                                    .padding()
                                
                                if !viewModel.annotations.isEmpty {
                                    mapView(annotations: viewModel.annotations)
                                }
                            }
                        } else {
                            EmptyView()
                        }
                    },
                    header: header
                )
            }
        }
    }
    
    private func header() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            makeButton(title: "Departure: \(viewModel.departure ?? "")") {
                viewModel.selectDepartureTapped()
            }
            
            makeButton(title: "Destination: \(viewModel.destination ?? "")") {
                viewModel.selectDestinationTapped()
            }
        }
        .background(Color.background)
    }
    
    private func makeButton(title: String, action: @escaping () -> Void) -> some View {
        Button(
            action: action,
            label: {
                Text(title)
                    .frame(maxWidth: .infinity)
            }
        )
        .buttonStyle(.bordered)
        .padding(.horizontal, 16)
        .frame(minHeight: 44)
    }
    
    func mapView(annotations: [CityAnnotation]) -> some View {
        let initialCoordinate = MKCoordinateRegion(
            center: annotations.first?.coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        return Map(
            coordinateRegion: .constant(initialCoordinate),
            annotationItems: viewModel.annotations
        ) { annotation in
            MapMarker(coordinate: annotation.coordinates)
        }
        .frame(height: 400)
        .frame(maxWidth: .infinity)
        .padding(16)
    }
}

#Preview {
    FlightConnectionsListView(
        viewModel: MockFlightConnectionsListViewModel()
    )
}
