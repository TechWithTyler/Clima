//
//  WeatherViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, WeatherManagerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

	@IBOutlet weak var conditionImageView: UIImageView?

	@IBOutlet weak var temperatureLabel: UILabel?

	@IBOutlet weak var cityLabel: UILabel?

	@IBOutlet weak var searchTextField: UITextField!

	var weatherManager = WeatherManager()

	let locationManager = CLLocationManager()

	var weatherURL: URL? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		loadWeatherData()
		weatherManager.delegate = self
		searchTextField.delegate = self
		locationManager.delegate = self
		locationManager.requestAlwaysAuthorization()
		locationManager.requestLocation()
	}

	// MARK: - @IBActions

	@IBAction func searchButtonPressed(_ sender: UIButton) {
		searchTextField.endEditing(true)
	}

	@IBAction func locationButtonPressed(_ sender: UIButton) {
		loadWeatherData()
		locationManager.requestLocation()
	}

}

extension WeatherViewController {

	// MARK: - UITextField Delegate

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		searchTextField.endEditing(true)
		return true
	}

	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		if textField.text != String() {
			return true
		} else {
			return false
		}
	}

	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
		if let city = textField.text {
			weatherManager.fetchWeather(cityName: city)
		}
		searchTextField?.text = String()
	}

}

extension WeatherViewController {

	// MARK: - WeatherManager Delegate

	func weatherManagerWillUpdate(_ weatherManager: WeatherManager) {
		loadWeatherData()
	}

	func weatherManager(_ weatherManager: WeatherManager, didUpdateWeatherUsingModel weather: WeatherModel) {
		DispatchQueue.main.async { [self] in
			cityLabel?.text = weather.cityName
			temperatureLabel?.text = weather.temperatureString
			conditionImageView?.image = UIImage(systemName: weather.conditionName)
		}
	}

	func weatherManager(_ weatherManager: WeatherManager, didGenerateURL url: URL) {
		weatherURL = url
	}

	func weatherManager(_ weatherManager: WeatherManager, didFailWithError error: Error) {
		let nsError = error as NSError
		presentAlert(error: nsError)
		weatherDataUnavailable()
	}

}

extension WeatherViewController {

	// MARK: - CLLocationManager Delegate

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.last {
			locationManager.stopUpdatingLocation()
			let lat = location.coordinate.latitude
			let lon = location.coordinate.longitude
			weatherManager.fetchWeather(latitude: lat, longitude: lon)
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		let nsError = error as NSError
		presentAlert(error: nsError)
		weatherDataUnavailable()
	}

}

extension WeatherViewController {

	// MARK: - Display - Loading

	func loadWeatherData() {
		DispatchQueue.main.async { [self] in
			cityLabel?.text = "Loading Weather Data…"
			temperatureLabel?.text = "--"
			conditionImageView?.image = UIImage(systemName: "ellipsis")
		}
	}

	func weatherDataUnavailable() {
		locationManager.stopUpdatingLocation()
		DispatchQueue.main.async { [self] in
			cityLabel?.text = "Weather Data Unavailable"
			temperatureLabel?.text = "--"
			conditionImageView?.image = UIImage(systemName: "questionmark")
		}
	}

	// MARK: - Display - Error Alert Presentation

	func presentAlert(error: NSError) {
		let message: String
		let info: String?
		switch error.code {
			case 0, -1009:
				message = "No internet connection"
				info = "Please check your internet connection and try again."
			case 1:
				message = "Location permissions denied"
				info = "Please check your location settings and try again."
			default:
				message = "Invalid data"
				info = "Try checking the entered city name. Press the location button to return to your current location's data."
		}
		DispatchQueue.main.async { [self] in
			let alert = UIAlertController(title: message, message: info, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
				alert.dismiss(animated: true)
			}))
			present(alert, animated: true)
		}
	}

}
