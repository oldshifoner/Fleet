//
//  ViewController.swift
//  Fleet
//
//  Created by Максим Игоревич on 05.10.2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        let ford = Truck(make: "Ford",model: "Transit",year: 1992,capacity: 3000,types:[CargoType.bulk(2),CargoType.perischable(4),CargoType.fragile(43)],trailerAttached: true,trailerTypes:[CargoType.bulk(2)])
        var hummer = Truck(make: "Hummer",model: "M3",year: 2005,capacity: 2000,types: nil, trailerAttached: false,trailerTypes:nil)

        var audi = Vehicle(make: "Audi", model: "A4", year: 2019, capacity: 1500, types:[CargoType.bulk(2)])
        var bmw = Vehicle(make: "BMW", model: "X2", year: 2017, capacity: 900, types:nil)
        
        var fleet = Fleet()
        
        fleet.addVehicle(ford)
        fleet.addVehicle(hummer)
        fleet.addVehicle(audi)
        fleet.addVehicle(bmw)
           
        var glass = Cargo(description: "Стекло", weight: 500, type: CargoType.fragile(15.5))
        var sand = Cargo(description: "Песок", weight: 1000, type: CargoType.bulk(5))
        var milk = Cargo(description: "Молоко", weight: 10000, type: CargoType.perischable(1))
        var meat = Cargo(description: "Мясо", weight: 1500, type: CargoType.perischable(10))
        
        fleet.vehicles[0].loadCargo(cargo: glass!)
        fleet.vehicles[1].loadCargo(cargo: sand!)
        fleet.vehicles[2].loadCargo(cargo: milk!)
        fleet.vehicles[3].loadCargo(cargo: meat!)
        
        fleet.vehicles[1].unloadCargo()
        
        var programFleet = ProgramFleet(fleet: fleet)
        
        programFleet.info()
        
        super.viewDidLoad()
    }


}

class ProgramFleet{
    
    var fleet : Fleet
    init(fleet: Fleet) {
        self.fleet = fleet
    }
    
    func info(){
        print("Общий список транспортных средств в автопарке:")
        for vehicle in fleet.vehicles {
            print("\(vehicle.make) \(vehicle.model)")
        }
        print("Общая грузоподьемность автопарка \(fleet.totalCapacity())")
        print("Общая текущая нагрузка автопарка \(fleet.totalCurrentLoad())")
    }
}


class Fleet{
    
    var vehicles: [Vehicle] = []
    
    func addVehicle(_ vehicle: Vehicle){
        vehicles.append(vehicle)
    }
    func totalCurrentLoad()->Int{
        var currentLoad:Int = 0
        for vehicle in vehicles{
            if vehicle.currentLoad != nil{
                currentLoad += vehicle.currentLoad!
            }
        }
        return currentLoad
    }
    
    func totalCapacity()->Int{
        var capacity:Int = 0
        for vehicle in vehicles {capacity += vehicle.capacity}
        return capacity
    }
    
}

class Vehicle{
    
    var make:String
    var model:String
    var year:Int
    var capacity:Int
    var types: [CargoType]? = nil
    var currentLoad:Int? = nil
    
    init(make: String, model: String, year: Int, capacity: Int, types: [CargoType]?, currentLoad: Int? = nil) {
        self.make = make
        self.model = model
        self.year = year
        self.capacity = capacity
        self.types = types
        self.currentLoad = currentLoad
    }
    func loadCargo(cargo:Cargo){
        if currentLoad == nil {currentLoad = 0}
        if cargo.weight + currentLoad! > capacity{
            print("Внимение! Груз \(cargo.description) превышает грузоподъемность \(make) \(model)")
            if currentLoad == 0 {currentLoad = nil}
            return
        }
        if !(checkingCargoForType(cargoType: cargo.type,cargoTypes: types)) {
            print("Внимение! Груз \(cargo.description) не поддерживается транспортным средством \(make) \(model)")
            if currentLoad == 0 {currentLoad = nil}
            return
        }
                
        currentLoad! += cargo.weight
    }
    
    func checkingCargoForType(cargoType:CargoType, cargoTypes:[CargoType]?) -> Bool{
        if cargoTypes != nil{
            for type in cargoTypes! {
                if cargoType == type {return true}
            }
            return false
        }
        return true
    }
    func unloadCargo(){
        currentLoad = nil
    }
}

class Truck:Vehicle{
    var trailerAttached:Bool
    var trailerCapacity:Int?
    var trailerTypes:[CargoType]?
    
    init(make:String , model: String, year: Int, capacity: Int, types: [CargoType]?, currentLoad: Int? = nil, trailerAttached: Bool, trailerCapacity: Int? = nil, trailerTypes: [CargoType]?) {
        self.trailerAttached = trailerAttached
        self.trailerCapacity = trailerCapacity
        self.trailerTypes = trailerTypes
        super.init(make: make, model: model, year: year, capacity: capacity, types: types, currentLoad: currentLoad)
    }
    
    
    override func loadCargo(cargo: Cargo) {
        if currentLoad == nil {currentLoad = 0}
        if trailerCapacity == nil {trailerCapacity = 0}
        if trailerAttached {
            if !(checkingCargoForType(cargoType: cargo.type, cargoTypes: trailerTypes)){
                print("Внимение! Груз \(cargo.description) не поддерживается типом прицепа")
            }else{
                capacity += trailerCapacity!
            }
        }
        if cargo.weight + currentLoad! > capacity{
            print("Внимение! Груз \(cargo.description) превышает грузоподъемность \(make) \(model)")
            if currentLoad == 0 {currentLoad = nil}
            return
        }
        if !(checkingCargoForType(cargoType: cargo.type, cargoTypes: types)) {
            print("Внимение! Груз \(cargo.description) не поддерживается транспортным средством \(make) \(model)")
            if currentLoad == 0 {currentLoad = nil}
            return
        }
                
        currentLoad! += cargo.weight
    }
}

struct Cargo {
    
    var description:String
    var weight:Int
    var type:CargoType
    
    init?(description: String, weight: Int, type: CargoType) {
        if weight < 0 {return nil}
        self.weight = weight
        self.description = description
        self.type = type
    }
}
enum CargoType:Equatable{
    case fragile(Double)
    case perischable(Double)
    case bulk(Double)
}
