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
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Button(action: {
                    viewModel.selectDepartureTapped()
                }, label: {
                    Text("Departure: \(viewModel.departure ?? "")")
                        .frame(maxWidth: .infinity)
                })
                
                Button(action: {
                    viewModel.selectDestinationTapped()
                }, label: {
                    Text("Destination: \(viewModel.destination ?? "")")
                        .frame(maxWidth: .infinity)
                })
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 16)
            .frame(minHeight: 44)

            Spacer()
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    FlightConnectionsListView(
        viewModel: MockFlightConnectionsListViewModel()
    )
}
