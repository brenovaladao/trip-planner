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
            
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.cityNames, id: \.self) { name in
                    HStack(alignment: .center, spacing: 0) {
                        Text(name)
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationView {
        FlightSearchView(
            viewModel: MockFlightSearchViewModel()
        )
        .navigationTitle("Preview Title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
