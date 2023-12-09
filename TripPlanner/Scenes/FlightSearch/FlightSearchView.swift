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
        _viewModel = StateObject(wrappedValue: viewModel)
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
}

private extension FlightSearchView {
    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 16, pinnedViews: [.sectionHeaders]) {
                Section(content: {
                    if let errorMessage = viewModel.errorMessage {
                        ErrorView(errorMessage)
                    } else {
                        if viewModel.isLoading {
                            SpinnerView()
                        }
                        
                        citiesList()
                    }
                }, header: textField)
            }
        }
    }
    
    func citiesList() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.cityNames, id: \.self) { name in
                makeCityRow(name: name)
                    .onTapGesture {
                        viewModel.citySelected(name)
                    }
            }
        }
    }
    
    func makeCityRow(name: String) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(name)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .contentShape(.rect)
    }
    
    func textField() -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "magnifyingglass")
            
            TextField("Search for a city name...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.background)
    }
}

#Preview {
    NavigationView {
        FlightSearchView(
            viewModel: MockFlightSearchViewModel(cityNames: ["Porto", "London"])
        )
    }
}
