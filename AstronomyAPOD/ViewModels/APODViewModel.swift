//
//  APODViewModel.swift
//  AstronomyAPOD
//
//  Created by Prashanth Mali Patil on 20/08/24.
//

import Foundation
import SwiftUI
import Combine

class APODViewModel:ObservableObject{
    @Published var imageURL: URL?
    @Published var title: String = ""
    @Published var explanation: String = ""
    
    @Published var apod: APODResponse?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiKey = "DEMO_KEY" // Replace with your API key
    private let apiUrl = "https://api.nasa.gov/planetary/apod"
    private let userDefaultsKey = "savedAPOD"
    private let lastFetchedDateKey = "lastFetchedDate"
    
    var currentDate: String{
        let now = Date()
        return formattedDateString(from: now)
    }
    
    
    init() {
        loadSavedData()
        fetchAPOD()
    }
    
    func fetchAPOD() {
        guard let url = URL(string: "\(apiUrl)?api_key=\(apiKey)&date=\(currentDate)") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        // Check if there's internet connection
        if !NetworkReachability.isConnected() {
            handleOfflineScenario()
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: APODResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.handleFetchError(error)
                }
            }, receiveValue: { apod in
                self.apod = apod
                self.saveToUserDefaults(apod: apod)
                UserDefaults.standard.set(Date(), forKey: self.lastFetchedDateKey)
            })
            .store(in: &cancellables)
    }
    
    func loadSavedData() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let apod = try? JSONDecoder().decode(APODResponse.self, from: data) {
            self.apod = apod
        }
    }
    
    func handleOfflineScenario() {
        if let lastAPOD = UserDefaults.standard.data(forKey: userDefaultsKey),
           let apod = try? JSONDecoder().decode(APODResponse.self, from: lastAPOD) {
            self.apod = apod
            self.errorMessage = "We are not connected to the internet, showing you the last image we have."
        } else {
            self.errorMessage = "No data available and no internet connection."
        }
    }
    
    func handleFetchError(_ error: Error) {
        self.errorMessage = "An error occurred: \(error.localizedDescription)"
    }
    
    func saveToUserDefaults(apod: APODResponse) {
        if let data = try? JSONEncoder().encode(apod) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    func formattedDateString(from date:Date)-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
