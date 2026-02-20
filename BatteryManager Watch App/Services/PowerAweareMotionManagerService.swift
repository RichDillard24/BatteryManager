import SwiftUI
import Foundation
import Combine
import CoreMotion
import WatchKit


enum PowerMode: String, CaseIterable, Identifiable {
    case eco = "Eco"
    case balance = "Balance"
    case performance = "Performance"
    
    var id: String { self.rawValue }
    
    var updateInterval: TimeInterval {
        switch self {
        case .eco:
            return 1.0
        case .balance:
            return 0.2
        case .performance:
            return 0.05
        }
    }
}
class PowerAweareMotionManagerService: ObservableObject {
    @Published var x: Double = 0.0
    @Published var y: Double = 0.0
    @Published var z: Double = 0.0
    
    @Published var currentMode: PowerMode = .balance
    
    @Published var isRunning: Bool = false
    @Published var updateCount: Int = 0
    
    @Published var simulatedBattery: Double = 100.0
    
    private var motionManager: CMMotionManager = CMMotionManager()
    private var batteryDrainTime: Timer?
    
    //MARK: - Computed props
    
    var isAvailable: Bool {
        motionManager.isAccelerometerAvailable
    }
    
    var currentInterval: TimeInterval {
        currentMode.updateInterval
    }
    
    func start() {
        guard isAvailable else { return
        }
        guard  !isRunning else { return }
        
        updateCount = 0
        
        motionManager.accelerometerUpdateInterval = currentMode.updateInterval
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self , let data = data, error == nil else { return }
            
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            
            self.updateCount += 1
            
        }
        
        isRunning = true
        WKInterfaceDevice.current().play(.start)
    }
    
    func stop() {
        motionManager.stopAccelerometerUpdates()
        isRunning = false
        WKInterfaceDevice.current().play(.stop)
    }
    
    func switchMode(_ mode: PowerMode) {
        guard mode != currentMode else { return }
        
        currentMode = mode
        WKInterfaceDevice.current().play(.click)
    }
    
    func reset() {
        updateCount = 0
        simulatedBattery = 100.0
        WKInterfaceDevice.current().play(.click)
    }
    
    private func restartWithNewInterval() {
        
    }
}
