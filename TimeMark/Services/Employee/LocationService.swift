import Foundation
import CoreLocation
import FirebaseFirestore

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published
    @Published var userLocation: CLLocation? = nil
    @Published var distance: Double? = nil
    @Published var isWithinRange: Bool = false
    @Published var distanceText: String = "Đang xác định vị trí..."
    @Published var officeRadius: Int = 20
    @Published var isLoadingOffice: Bool = true
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    private let manager = CLLocationManager()
    private let db = Firestore.firestore()
    private var officeLocation: CLLocation? = nil
    
    static let shared = LocationService()
    
    override init() {
        super.init()
        setupLocationManager()
        fetchOfficeFromFirestore()
    }
    
    private func setupLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        if isAuthorized {
            manager.startUpdatingLocation()
        }
    }
    
    // MARK: - Lấy thông tin văn phòng
    func fetchOfficeFromFirestore() {
        isLoadingOffice = true
        
        db.collection("office").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoadingOffice = false
                
                if let error = error {
                    self.distanceText = "Không thể lấy thông tin văn phòng"
                    return
                }
                
                guard let doc = snapshot?.documents.first,
                      let geoPoint = doc.data()["coordinates"] as? GeoPoint,
                      let radius = doc.data()["radius_meter"] as? Int else {
                    self.distanceText = "Chưa cấu hình vị trí văn phòng"
                    return
                }
                
                self.officeLocation = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                self.officeRadius = radius
                
                if let userLoc = self.userLocation {
                    self.updateDistance(from: userLoc)
                }
            }
        }
    }
    
    // MARK: - Delegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if isAuthorized {
            manager.startUpdatingLocation()
        } else if authorizationStatus == .denied || authorizationStatus == .restricted {
            self.distanceText = "Chưa cấp quyền vị trí"
            self.isWithinRange = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = latest
            self.updateDistance(from: latest)
        }
    }
    
    private func updateDistance(from userLoc: CLLocation) {
        guard let officeLoc = officeLocation else { return }
        
        let dist = userLoc.distance(from: officeLoc)
        distance = dist
        isWithinRange = dist <= Double(officeRadius)
        
        if isWithinRange {
            distanceText = " Trong văn phòng (\(Int(dist))m)"
        } else {
            distanceText = "Cách \(Int(dist))m"
        }
    }
}
