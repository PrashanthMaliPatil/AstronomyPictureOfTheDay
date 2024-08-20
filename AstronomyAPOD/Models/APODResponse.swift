//
//  APODResponse.swift
//  AstronomyAPOD
//
//  Created by Prashanth Mali Patil on 20/08/24.
//

import Foundation

struct APODResponse: Codable{
    let title: String
    let explanation: String
    let url: String
    let date: String
    let media_type: String
}
