//
//  WeatherManager.swift
//  Clima
//
//  Created by TechWithTyler on 8/25/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {

	func weatherManagerWillUpdate(_ weatherManager: WeatherManager)

	func weatherManager(_ weatherManager: WeatherManager, didUpdateWeatherUsingModel weather: WeatherModel)

	func weatherManager(_ weatherManager: WeatherManager, didGenerateURL url: URL)

	func weatherManager(_ weatherManager: WeatherManager, didFailWithError error: Error)

}

struct WeatherManager {

	static let apiKey = (Bundle.main.infoDictionary?["OpenWeatherMapAPIKey"])!

	let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(WeatherManager.apiKey)&units=imperial"

	var delegate: WeatherManagerDelegate?

	func fetchWeather(cityName: String) {
		let urlFriendlyCityName = cityName.spacesFormattedForURLs()
		let urlString = "\(weatherURL)&q=\(urlFriendlyCityName)"
		performRequest(with: urlString)
	}

	func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
		let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
		performRequest(with: urlString)
	}

	func performRequest(with urlString: String) {
		delegate?.weatherManagerWillUpdate(self)
		if let url = URL(string: urlString) {
			let session = URLSession(configuration: .default)
			let task = session.dataTask(with: url) { data, response, error in
				if let error = error {
					self.delegate?.weatherManager(self, didFailWithError: error)
					return
				}
				if let url = response?.url {
					self.delegate?.weatherManager(self, didGenerateURL: url)
				}
				if let safeData = data {
					if let weather = self.parseJSON(safeData) {
						self.delegate?.weatherManager(self, didUpdateWeatherUsingModel: weather)
					}
				}

			}
			task.resume()
		}
	}

	func parseJSON(_ weatherData: Data) -> WeatherModel? {
		let decoder = JSONDecoder()
		do {
			let decodedWeatherData = try decoder.decode(WeatherData.self, from: weatherData)
			let id = decodedWeatherData.weather[0].id
			let temp = decodedWeatherData.main.temp
			let name = decodedWeatherData.name.withoutURLFriendlySpaces()
			let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
			return weather
		} catch {
			delegate?.weatherManager(self, didFailWithError: error)
			return nil
		}
	}

}

extension String {

	func spacesFormattedForURLs() -> String {
		return self.replacingOccurrences(of: " ", with: "%20")
	}

	func withoutURLFriendlySpaces() -> String {
		return self.replacingOccurrences(of: "%20", with: " ")
	}
	
}
