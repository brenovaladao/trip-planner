//
//  FlightConnectionsListView.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

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
            LazyVStack(alignment: .center, spacing: 24, pinnedViews: [.sectionHeaders]) {
                Section(content: {
                    if let errorMessage = viewModel.errorMessage {
                        ErrorView(errorMessage)
                    } else if viewModel.isLoading {
                        SpinnerView()
                    } else if let routeInfo = viewModel.routeInfo {
                        routeInfoView(routeInfo)
                        
                        AnnotationsMapView(items: viewModel.annotations)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else {
                        EmptyView()
                    }
                }, header: header)
            }
            .padding(.horizontal, 16)
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
    
    private func routeInfoView(_ routeInfo: String) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text(routeInfo)
                .bold()
                .multilineTextAlignment(.center)
        }
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
        .frame(minHeight: 44)
    }

}

#Preview {
    FlightConnectionsListView(
        viewModel: MockFlightConnectionsListViewModel()
    )
}
