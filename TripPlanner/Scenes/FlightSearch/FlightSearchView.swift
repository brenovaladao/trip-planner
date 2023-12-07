//
//  FlightSearchView.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import SwiftUI

public struct FlightSearchView<ViewModel: FlightSearchViewModeling>: View {
    @StateObject private var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        content
            .task { await viewModel.loadCityNames() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: { Task { await viewModel.loadCityNames() } },
                        label: { Image(systemName: "arrow.clockwise") }
                    )
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.cityNames, id: \.self) { name in
                        makeCityRow(name: name)
                            .onTapGesture {
                                viewModel.citySelected(name)
                            }                        
                    }
                }
            }
        }
    }
    
    private func makeCityRow(name: String) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(name)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .contentShape(.rect)
    }
}

#Preview {
    NavigationView {
        FlightSearchView(
            viewModel: MockFlightSearchViewModel(cityNames: ["Porto", "London"])
        )
    }
}
