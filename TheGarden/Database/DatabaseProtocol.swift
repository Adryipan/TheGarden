//
//  DatabaseProtocol.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType{
    case exhibitions
    case plants
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onExhibitionPlantListChange(change: DatabaseChange, exhibitionPlants:[Plant])
    func onPlantsRecordChange(change: DatabaseChange, plants: [Plant])
    func onExhibitionRecordChange(change: DatabaseChange, exhibitions:[Exhibition])
    
}

protocol DatabaseProtocol: AnyObject {
    func getExhibition(name: String) -> Exhibition
    func getPlant(name: String) -> Plant
    func checkExhibition(name: String) -> Bool
    func getExhibitionPlants(exhibitionName: String) -> [Plant]
    func configureTemp()
    func updateExhibition(exhibition: Exhibition, newDesc: String)
    func updatePlant(plant: Plant, commonName: String, scienceName: String, year: String, family: String)
    func addPlant(plantData: PlantData) -> Plant
    func addExhibition(name: String, desc: String, lat: Double, long: Double, isTracking: Bool, image_url: String) -> Exhibition
    func addPlantToExhibition(plant: Plant, exhibition: Exhibition) -> Bool
    func removeExhibition(exhibition: Exhibition)
    func addExhibitionTracking(exhibition: Exhibition)
    func removeExhibitionTracking(exhibition: Exhibition)
    func removePlantFromExhibition(plant: Plant, exhibition: Exhibition)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func cleanup()
}

