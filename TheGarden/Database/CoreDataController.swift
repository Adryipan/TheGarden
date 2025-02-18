//
//  CoreDataController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate{


    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    var allPlantsFetchedResultsController: NSFetchedResultsController<Plant>?
    var allExhibitionFetchedResultsController: NSFetchedResultsController<Exhibition>?
    var exhibitionPlantsFetchedResultsController: NSFetchedResultsController<Plant>?
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
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
    func checkExhibition(name: String) -> Bool {
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
        }
        
        if exhibition.count == 0{
            return false
        } else {
            return true
        }
    }
    
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
                let _ = addExhibition(name: "Temp", desc: "", lat: 0, long: 0, isTracking: false, image_url: "")
            } else {
                let _ = addExhibition(name: "Temp", desc: "", lat: 0, long: 0, isTracking: false, image_url: "")
            }
         } else{
            let _ = addExhibition(name: "Temp", desc: "", lat: 0, long: 0, isTracking: false, image_url: "")
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
    
    func getPlant(name: String) -> Plant {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]

        let plantFetchedResultsController = NSFetchedResultsController<Plant>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        plantFetchedResultsController.delegate = self

        do {
            try plantFetchedResultsController.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
         

         var plant = [Plant]()

         if plantFetchedResultsController.fetchedObjects != nil {
            plant = (plantFetchedResultsController.fetchedObjects)!
         }

         return plant[0]
    }
    
    func updatePlant(plant: Plant, commonName: String, scienceName: String, year: String, family: String) {
        plant.setValue(commonName, forKey: "commonName")
        plant.setValue(scienceName, forKey: "scientificName")
        plant.setValue(year, forKey: "year")
        plant.setValue(family, forKey: "family")      
    }
    
    func updateExhibition(exhibition: Exhibition, newDesc: String) {
        exhibition.setValue(newDesc, forKey: "desc")
    }
    
    func addExhibitionTracking(exhibition: Exhibition) {
        exhibition.setValue(true, forKey: "isTracking")
    }
    
    func removeExhibitionTracking(exhibition: Exhibition) {
        exhibition.setValue(false, forKey: "isTracking")
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
    
    func addPlant(plantData: PlantData, image: Data) -> Plant {
        let plant = NSEntityDescription.insertNewObject(forEntityName: "Plant", into: persistantContainer.viewContext) as! Plant
        plant.commonName = plantData.commonName
        plant.scientificName = plantData.scienceName
        plant.image_url = plantData.image_url
        plant.family = plantData.family
        plant.year = String(plantData.yearDiscovered!)
        plant.image = image
        
        return plant
    }
    
    func addExhibition(name: String, desc: String, lat: Double, long: Double, isTracking: Bool, image_url: String) -> Exhibition{
        let exhibition = NSEntityDescription.insertNewObject(forEntityName: "Exhibition", into: persistantContainer.viewContext) as! Exhibition
        exhibition.name = name
        exhibition.desc = desc
        exhibition.lat = lat
        exhibition.long = long
        exhibition.isTracking = isTracking
        exhibition.image_url = image_url
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
    
    func getExhibitionPlants(exhibitionName: String) -> [Plant] {
        if exhibitionPlantsFetchedResultsController == nil{
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "commonName", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        let predicate = NSPredicate(format: "ANY exhibitions.name == %@", exhibitionName)
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
        let roseExhibition = addExhibition(name: "Species Rose Collection", desc: "Showing more than 100 variety of roses.", lat: -37.830644, long: 144.983362, isTracking: true, image_url: "https://cdn.pixabay.com/photo/2017/05/06/14/13/pathway-2289978_150.jpg")
        let rose1 = addPlant(commonName: "yellow rose", scientificName: "Rosa xanthina", image_url: "https://bs.floristic.org/image/o/6416eb252e4e3d359aa298647c1568ed8ad03b90", family: "Rosaceae", year: 1820)
        let rose2 = addPlant(commonName: "chinese rose", scientificName: "Rosa chinensis", image_url: "https://bs.floristic.org/image/o/5ffdd7134abcd7e2e386dc1ba1d09774e2264b1e", family: "Rosaceae", year: 1768)
        let rose3 = addPlant(commonName: "chestnut rose", scientificName: "Rosa roxburghii", image_url: "https://bs.floristic.org/image/o/2d6c25e69331c645e31cc46d9f8f8e3b2a2090c0", family: "Rosaceae", year: 1823)
        
        roseExhibition.addToPlants([rose1, rose2, rose3])

        
        let aridExhibition = addExhibition(name: "Arid Garden", desc: "Displaying assortment of aloes, bromeliads, agaves and cati.", lat: -37.831760, long: 144.983095, isTracking: true, image_url: "https://cdn.pixabay.com/photo/2017/05/06/14/13/pathway-2289978_150.jpg")
        let arid1 = addPlant(commonName: "Joshua-tree", scientificName: "Yucca brevifolia", image_url: "https://bs.floristic.org/image/o/25ffeb64175cf2540206a817d4ec8fcc55496a7b", family: "Asparagaceae", year: 1871)
        let arid2 = addPlant(commonName: "Tree euphorbia", scientificName: "Euphorbia triangularis", image_url: "https://bs.floristic.org/image/o/d68c4272848bffd3b30fe035136d701bc7eb59c1", family: "Euphorbiaceae", year: 1906)
        let arid3 = addPlant(commonName: "smallflower century plant", scientificName: "Agave parviflora", image_url: "https://bs.floristic.org/image/o/1f6582640227f0915a0a578d695acb863a65d7f8", family: "Asparagaceae", year: 1858)
        
        aridExhibition.addToPlants([arid1, arid2, arid3])
        
        let forestExhibition = addExhibition(name: "Australian Forest Walk", desc: "Showing a range of Australian forest species.", lat: -37.831333, long: 144.977588, isTracking: true, image_url: "https://cdn.pixabay.com/photo/2017/05/06/14/13/pathway-2289978_150.jpg")
        let forest1 = addPlant(commonName: "Blue oliveberry", scientificName: "Elaeocarpus reticulatus", image_url: "https://bs.floristic.org/image/o/0857436b7baf0081d7c331168398da4dc5667430", family: "Elaeocarpaceae", year: 1809)
        let forest2 = addPlant(commonName: "Saw Banksia", scientificName: "Corymbia citriodora", image_url: "https://bs.floristic.org/image/o/4bfeb2059b2ec30933587b307d6e2d65ef31c7c5", family: "Proteaceae", year: 1782)
        let forest3 = addPlant(commonName: "Lemonscented gum", scientificName: "Elaeocarpus reticulatus", image_url: "https://bs.floristic.org/image/o/d54ee9525351786868fc6a260a20d1bd18b376c8", family: "Myrtaceae", year: 1995)
        
        forestExhibition.addToPlants([forest1, forest2, forest3])
        
        let bambooExhibition = addExhibition(name: "Bamboo Collection", desc: "Taxonomic and Evolutionary collection of Bamboo.", lat: -37.830422, long: 144.980248, isTracking: true, image_url: "https://cdn.pixabay.com/photo/2017/05/06/14/13/pathway-2289978_150.jpg")
        let bamboo1 = addPlant(commonName: "black bamboo", scientificName: "Phyllostachys nigra", image_url: "https://bs.floristic.org/image/o/45e7e42c5f9b0a9ec324b9fba3abf970bcfe8ded", family: "Poaceae", year: 1868)
        let bamboo2 = addPlant(commonName: "sacred bamboo", scientificName: "Nandina domestica", image_url: "https://bs.floristic.org/image/o/c9ee505a8e9c3ff960972c9753e6b2b10f10e0f3", family: "Berberidaceae", year: 1781)
        let bamboo3 = addPlant(commonName: "Castillon bamboo", scientificName: "Phyllostachys reticulata", image_url: "https://bs.floristic.org/image/o/0dc03f60b8ebf21c0105f234b8b692ee2b5f039e", family: "Poaceae", year: 1873)
        
        bambooExhibition.addToPlants([bamboo1, bamboo2, bamboo3])
        
        
        let camelliaCollection = addExhibition(name: "Camellia Collection", desc: "A breathtaking best exhibition in winter.", lat: -37.830997, long: 144.979243, isTracking: true, image_url: "https://cdn.pixabay.com/photo/2017/05/06/14/13/pathway-2289978_150.jpg")
        let camellia1 = addPlant(commonName: "Yellow camellia", scientificName: "Camellia petelotii", image_url: "https://bs.floristic.org/image/o/e8f2b963c47a310a19366dcb473efc27e0d22ea8", family: "Theaceae", year: 1949)
        let camellia2 = addPlant(commonName: "camellia", scientificName: "Camellia japonica", image_url: "https://bs.floristic.org/image/o/d581db1f72706fdf81c8e34a239f478077ea8cb4", family: "Theaceae", year: 1753)
        let camellia3 = addPlant(commonName: "Tea-oil-plant", scientificName: "Camellia oleifera", image_url: "https://bs.floristic.org/image/o/d706dd156d80626b4d40de3b730d8f1193caca90", family: "Theaceae", year: 1818)
        
        camelliaCollection.addToPlants([camellia1, camellia2, camellia3])
    }
    
    

}

