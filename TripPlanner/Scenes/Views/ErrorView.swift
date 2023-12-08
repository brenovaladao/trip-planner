//
//  ErrorView.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import SwiftUI

struct ErrorView: View {
    private let errorMessage: String
    
    init(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        Text(errorMessage)
            .multilineTextAlignment(.center)
            .padding()
    }
}

#Preview {
    ErrorView("Some error message")
}
