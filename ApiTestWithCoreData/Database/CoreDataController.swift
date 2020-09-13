//
//  CoreDataController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate{

    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    var allPlantsFetchedResultsController: NSFetchedResultsController<Plant>?
    var allExhibitionFetchedResultsController: NSFetchedResultsController<Exhibition>?
    var exhibitionPlantsFetchedResultsController: NSFetchedResultsController<Plant>?
    
    override init(){
        persistantContainer = NSPersistentContainer(name: "TheGardenExhibition")
        persistantContainer.loadPersistentStores(){(description, error) in
            if let error = error{
                fatalError("Failed to load Core Data Stack: \(error)")
            }
        }
        super.init()
        
        if fetchAllExhibition().count == 0{
            createDefaultExhibition()
        }
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    // MARK: - Database Protocol Implementation
    
    func configureTemp(){
        let fetchRequest: NSFetchRequest<Exhibition> = Exhibition.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", "Temp")
        fetchRequest.predicate = predicate
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]

        let exhibitionFetchedResultsController = NSFetchedResultsController<Exhibition>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        exhibitionFetchedResultsController.delegate = self

        do {
            try exhibitionFetchedResultsController.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
         

         var exhibition = [Exhibition]()

         if exhibitionFetchedResultsController.fetchedObjects != nil {
            exhibition = (exhibitionFetchedResultsController.fetchedObjects)!
            if exhibition.count > 0{
                removeExhibition(exhibition: exhibition[0])
                addExhibition(name: "Temp", desc: "", lat: 0, long: 0)
            } else {
                addExhibition(name: "Temp", desc: "", lat: 0, long: 0)
            }
         } else{
            addExhibition(name: "Temp", desc: "", lat: 0, long: 0)
        }

    }
    
    func getExhibition(name: String) -> Exhibition {
        let fetchRequest: NSFetchRequest<Exhibition> = Exhibition.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]

        let exhibitionFetchedResultsController = NSFetchedResultsController<Exhibition>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        exhibitionFetchedResultsController.delegate = self

        do {
            try exhibitionFetchedResultsController.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
         

         var exhibition = [Exhibition]()

         if exhibitionFetchedResultsController.fetchedObjects != nil {
            exhibition = (exhibitionFetchedResultsController.fetchedObjects)!
         }

         return exhibition[0]
    }
    
    func updateExhibition(exhibition: Exhibition, newDesc: String) {
        exhibition.setValue(newDesc, forKey: "desc")
    }
    
    
    func addPlant(plantData: PlantData) -> Plant {
        let plant = NSEntityDescription.insertNewObject(forEntityName: "Plant", into: persistantContainer.viewContext) as! Plant
        plant.commonName = plantData.commonName
        plant.scientificName = plantData.scienceName
        plant.image_url = plantData.image_url
        plant.family = plantData.family
        plant.year = String(plantData.yearDiscovered!)

        return plant
     }
    
    func addExhibition(name: String, desc: String, lat: Double, long: Double) -> Exhibition{
        let exhibition = NSEntityDescription.insertNewObject(forEntityName: "Exhibition", into: persistantContainer.viewContext) as! Exhibition
        exhibition.name = name
        exhibition.desc = desc
        exhibition.lat = lat
        exhibition.long = long
        
        return exhibition
    }
    
    func addPlantToExhibition(plant: Plant, exhibition: Exhibition) -> Bool {
        exhibition.addToPlants(plant)
        
        return true
    }
    
    func removeExhibition(exhibition: Exhibition) {
        persistantContainer.viewContext.delete(exhibition)
    }
    
    func removePlantFromExhibition(plant: Plant, exhibition: Exhibition) {
        exhibition.removeFromPlants(plant)
    }


     func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .plants || listener.listenerType == .all{
            listener.onPlantsRecordChange(change: .update, plants: fetchAllPlants())
        }
        
        if listener.listenerType == .exhibitions || listener.listenerType == .all{
            listener.onExhibitionPlantListChange(change: .update, exhibitionPlants: fetchExhibitionPlants())
            listener.onExhibitionRecordChange(change: .update, exhibitions: fetchAllExhibition())
        }
        
     }

     func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
     }

     func cleanup() {
        saveContext()
     }
    
    func addPlant(commonName: String, scientificName: String, image_url: String, family: String, year: Int) -> Plant{
        let plant = NSEntityDescription.insertNewObject(forEntityName: "Plant", into: persistantContainer.viewContext) as! Plant
        plant.commonName = commonName
        plant.scientificName = scientificName
        plant.image_url = image_url
        plant.family = family
        plant.year = String(year)

        return plant
    }

    // MARK: - Fetched Results Controller Protocol Functions
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        if controller == allPlantsFetchedResultsController{
            listeners.invoke{(listener) in
                if listener.listenerType == .plants || listener.listenerType == .all{
                    listener.onPlantsRecordChange(change: .update, plants: fetchAllPlants())
                }
            }
        }else if controller == exhibitionPlantsFetchedResultsController{
            listeners.invoke{(listener) in
                if listener.listenerType == .exhibitions || listener.listenerType == .all{
                    listener.onExhibitionPlantListChange(change: .update, exhibitionPlants: fetchExhibitionPlants())
                }
            }
        }else if controller == allExhibitionFetchedResultsController{
            listeners.invoke{(listener) in
                if listener.listenerType == .exhibitions || listener.listenerType == .all{
                    listener.onExhibitionRecordChange(change: .update, exhibitions: fetchAllExhibition())
                }
                
            }
        }
    }
    
    
    
    // MARK: - Fetch Requests
    
    func fetchAllExhibition() -> [Exhibition]{
        if allExhibitionFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Exhibition> = Exhibition.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]

            allExhibitionFetchedResultsController = NSFetchedResultsController<Exhibition>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allExhibitionFetchedResultsController?.delegate = self

            do {
               try allExhibitionFetchedResultsController?.performFetch()
            } catch {
               print("Fetch Request Failed: \(error)")
            }
        }

        var exhibition = [Exhibition]()

        if allExhibitionFetchedResultsController?.fetchedObjects != nil {
           exhibition = (allExhibitionFetchedResultsController?.fetchedObjects)!
        }

        return exhibition
        
    }
    
     func fetchAllPlants() -> [Plant] {
         if allPlantsFetchedResultsController == nil {
             let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
             let nameSortDescriptor = NSSortDescriptor(key: "commonName", ascending: true)
             fetchRequest.sortDescriptors = [nameSortDescriptor]

             allPlantsFetchedResultsController = NSFetchedResultsController<Plant>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
             allPlantsFetchedResultsController?.delegate = self

             do {
                try allPlantsFetchedResultsController?.performFetch()
             } catch {
                print("Fetch Request Failed: \(error)")
             }
         }

         var plants = [Plant]()

         if allPlantsFetchedResultsController?.fetchedObjects != nil {
            plants = (allPlantsFetchedResultsController?.fetchedObjects)!
         }

         return plants
     }
    
    func fetchExhibitionPlants() -> [Plant]{
        if exhibitionPlantsFetchedResultsController == nil{
            let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "commonName", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            let predicate = NSPredicate(format: "ANY exhibitions.name == %@", "Temp")
            fetchRequest.predicate = predicate
            
            exhibitionPlantsFetchedResultsController = NSFetchedResultsController<Plant>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
                exhibitionPlantsFetchedResultsController?.delegate = self

                do {
                   try exhibitionPlantsFetchedResultsController?.performFetch()
                } catch {
                   print("Fetch Request Failed: \(error)")
                }
            }

            var plants = [Plant]()

            if exhibitionPlantsFetchedResultsController?.fetchedObjects != nil {
               plants = (exhibitionPlantsFetchedResultsController?.fetchedObjects)!
            }

            return plants
    }    
    
    // MARK: - Default Exhibition
    func createDefaultExhibition(){
        let roseExhibition = addExhibition(name: "Species Rose Collection", desc: "Showing more than 100 variety of roses.", lat: -37.830644, long: 144.983362)
        let rose1 = addPlant(commonName: "yello rose", scientificName: "Rosa xanthina", image_url: "    https://bs.floristic.org/image/o/6416eb252e4e3d359aa298647c1568ed8ad03b90", family: "Rosaceae", year: 1820)
        let rose2 = addPlant(commonName: "chinese rose", scientificName: "Rosa chinensis", image_url: "    https://bs.floristic.org/image/o/5ffdd7134abcd7e2e386dc1ba1d09774e2264b1e", family: "Rosaceae", year: 1768)
        let rose3 = addPlant(commonName: "chestnut rose", scientificName: "Rosa roxburghii", image_url: "    https://bs.floristic.org/image/o/2d6c25e69331c645e31cc46d9f8f8e3b2a2090c0", family: "Rosaceae", year: 1823)
        
        roseExhibition.addToPlants([rose1, rose2, rose3])

        
        let aridExhibition = addExhibition(name: "Arid Garden", desc: "Displaying assortment of aloes, bromeliads, agaves and cati.", lat: -37.831760, long: 144.983095)
        let arid1 = addPlant(commonName: "Joshua-tree", scientificName: "Yucca brevifolia", image_url: "https://bs.floristic.org/image/o/25ffeb64175cf2540206a817d4ec8fcc55496a7b", family: "Asparagaceae", year: 1871)
        let arid2 = addPlant(commonName: "Tree euphorbia", scientificName: "Euphorbia triangularis", image_url: "https://bs.floristic.org/image/o/d68c4272848bffd3b30fe035136d701bc7eb59c1", family: "Euphorbiaceae", year: 1906)
        let arid3 = addPlant(commonName: "smallflower century plant", scientificName: "Agave parviflora", image_url: "https://bs.floristic.org/image/o/1f6582640227f0915a0a578d695acb863a65d7f8", family: "Asparagaceae", year: 1858)
        
        aridExhibition.addToPlants([arid1, arid2, arid3])
        
        let forestExhibition = addExhibition(name: "Australian Forest Walk", desc: "Showing a range of Australian forest species.", lat: -37.831333, long: 144.977588)
        let forest1 = addPlant(commonName: "Blue oliveberry", scientificName: "Elaeocarpus reticulatus", image_url: "https://bs.floristic.org/image/o/0857436b7baf0081d7c331168398da4dc5667430", family: "Elaeocarpaceae", year: 1809)
        let forest2 = addPlant(commonName: "Saw Banksia", scientificName: "Corymbia citriodora", image_url: "https://bs.floristic.org/image/o/4bfeb2059b2ec30933587b307d6e2d65ef31c7c5", family: "Proteaceae", year: 1782)
        let forest3 = addPlant(commonName: "Lemonscented gum", scientificName: "Elaeocarpus reticulatus", image_url: "https://bs.floristic.org/image/o/d54ee9525351786868fc6a260a20d1bd18b376c8", family: "Myrtaceae", year: 1995)
        
        forestExhibition.addToPlants([forest1, forest2, forest3])
        
        let bambooExhibition = addExhibition(name: "Bamboo Collection", desc: "Taxonomic and Evolutionary collection of Bamboo.", lat: -37.830422, long: 144.980248)
        let bamboo1 = addPlant(commonName: "black bamboo", scientificName: "Phyllostachys nigra", image_url: "https://bs.floristic.org/image/o/45e7e42c5f9b0a9ec324b9fba3abf970bcfe8ded", family: "Poaceae", year: 1868)
        
        
        let _ = addExhibition(name: "Camellia Collection", desc: "A breathtaking best exhibition in winter.", lat: -37.830997, long: 144.979243)
    }
    

}

