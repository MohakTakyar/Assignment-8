//
//  ViewController.swift
//  coredata
//
//  Created by user238229 on 3/19/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,
                      CLLocationManagerDelegate  {
    
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            getDataFromAPI(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { [weak self] result in
                guard let data = result else {
                    print("Error")
                    return
                }
                DispatchQueue.main.async {
                    self?.updateUI(data: data)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func updateUI(data: WeatherData) {
        cityNameLabel.text = data.name ?? ""
        descLabel.text = data.weather?.first?.description ?? ""
        if let url = URL(string: "https://openweathermap.org/img/wn/\(data.weather?.first?.icon ?? "")@2x.png") {
            weatherImageView.getImage(url: url)
        }
        humidityLabel.text = "Humidity: \(data.main?.humidity ?? 0)"
        windLabel.text = "Wind: \(data.wind?.speed ?? 0)Km/h"
        weatherTemp.text = "\(Int(data.main?.temp ?? 0))°C"
    }
    
    func getDataFromAPI(lat: Double, lon: Double, completion: @escaping (WeatherData?) -> ()) {
        let APIKey = "debc0757dd7272a17a9927ab2cda88b7&units=metric"
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(APIKey)") else { return }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { jsonData, _, error in
            guard let jsonData = jsonData else { return }
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: jsonData)
                completion(weatherData)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}

extension UIImageView {
    func getImage(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
