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
        VStack(alignment: .leading, spacing: 0) {
            Text("Hello, World!")
            
            Button(action: {
                viewModel.citySelected("test")
            }, label: {
                Text("navigate back")
            })
        }
    }
}

#Preview {
    FlightSearchView(
        viewModel: MockFlightSearchViewModel()
    )
}
