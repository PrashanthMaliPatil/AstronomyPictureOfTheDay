//
//  APODView.swift
//  AstronomyAPOD
//
//  Created by Prashanth Mali Patil on 20/08/24.
//

import Foundation
import SwiftUI

struct APODView: View {
    @StateObject private var viewModel = APODViewModel()
    
    var body: some View {
        ScrollView{
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if let apod = viewModel.apod {
                    Text(apod.title)
                        .font(.title)
                        .bold()
                        .underline()
                    
                    if apod.media_type == "image", let url = URL(string: apod.url) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding()
                    }
                    
                    Text(apod.explanation)
                        .font(.subheadline)
                } else {
                    Text("No data available")
                        .padding()
                }
            }.padding()
        }
    }
}

#Preview {
    APODView()
}
