//
//  FlightSearchView.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import SwiftUI

struct FlightSearchView<ViewModel: FlightSearchViewModeling>: View {
    @ObservedObject private var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .onAppear { viewModel.loadCityNames() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: { viewModel.loadCityNames() },
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
        }
        .padding()
        .contentShape(.rect)
    }
}

#Preview {
    NavigationView {
        FlightSearchView(
            viewModel: MockFlightSearchViewModel(cityNames: ["Porto", "London"])
        )
        .navigationTitle("Preview Title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
