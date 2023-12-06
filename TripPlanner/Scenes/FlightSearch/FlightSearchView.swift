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
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Hello, World!")
            }
            .navigationTitle(viewModel.title)
        }
    }
}

#Preview {
    FlightSearchView(
        viewModel: MockFlightSearchViewModel()
    )
}
