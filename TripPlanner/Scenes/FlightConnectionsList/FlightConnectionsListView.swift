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
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
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
                                // TODO: Map view
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
}

#Preview {
    FlightConnectionsListView(
        viewModel: MockFlightConnectionsListViewModel()
    )
}
