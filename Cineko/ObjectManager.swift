//
//  ObjectManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 18/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreData

class ObjectManager: NSObject {

    // MARK: Constants
    static let BatchUpdateNotification = "BatchUpdateNotification"
    
    // MARK: Variables
    private var privateContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.privateContext
    }
    private var mainObjectContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.mainObjectContext
    }
    
    func findOrCreateMovie(dict: [String: AnyObject]) -> Movie {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Movie in
            return Movie(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Movie", objectKey: "movieID", objectValue: dict[Movie.Keys.MovieID] as! NSObject, initializer: initializer) as! Movie
    }
    
    func updateMovie(dict: [String: AnyObject]) {
        if let movieID = dict[Movie.Keys.MovieID] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: "Movie")
            fetchRequest.predicate = NSPredicate(format: "movieID == %@", movieID)
            
            do {
                if let m = try privateContext.executeFetchRequest(fetchRequest).first as? Movie {
                    
                    if let genres = dict["genres"] as? [[String: AnyObject]] {
                        let set = NSMutableSet()
                        
                        for genre in genres {
                            set.addObject(findOrCreateGenre(genre))
                        }
                        m.genres = set
                    }
                    
                    if let companies = dict["production_companies"] as? [[String: AnyObject]] {
                        let set = NSMutableSet()
                        
                        for company in companies {
                            set.addObject(findOrCreateCompany(company))
                        }
                        m.productionCompanies = set
                    }
                    
                    if let countries = dict["production_countries"] as? [[String: AnyObject]] {
                        let set = NSMutableSet()
                        
                        for country in countries {
                            set.addObject(findOrCreateCountry(country))
                        }
                        m.productionCountries = set
                    }
                    
                    if let languages = dict["spoken_languages"] as? [[String: AnyObject]] {
                        let set = NSMutableSet()
                        
                        for language in languages {
                            set.addObject(findOrCreateLanguage(language))
                        }
                        m.spokenLanguages = set
                    }
                    
                    m.update(dict)
                    CoreDataManager.sharedInstance.savePrivateContext()
                }
            } catch let error as NSError {
                print("Error in fetch \(error), \(error.userInfo)")
            }
        }
    }
    
    func findOrCreateTVShow(dict: [String: AnyObject]) -> TVShow {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> TVShow in
            return TVShow(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "TVShow", objectKey: "tvShowID", objectValue: dict[TVShow.Keys.TVShowID] as! NSObject, initializer: initializer) as! TVShow
    }
    
    func updateTVShow(dict: [String: AnyObject]) {
        if let tvShowID = dict[TVShow.Keys.TVShowID] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: "TVShow")
            fetchRequest.predicate = NSPredicate(format: "tvShowID == %@", tvShowID)
            
            do {
                if let m = try privateContext.executeFetchRequest(fetchRequest).first as? TVShow {

                    if let genres = dict["genres"] as? [[String: AnyObject]] {
                        let set = NSMutableSet()
                        
                        for genre in genres {
                            set.addObject(findOrCreateGenre(genre))
                        }
                        m.genres = set
                    }
                    
                    if let networks = dict["networks"] as? [[String: AnyObject]] {
                        let set = NSMutableSet()
                        
                        for network in networks {
                            set.addObject(findOrCreateNetwork(network))
                        }
                        m.networks = set
                    }
                    
                    if let companies = dict["production_companies"] as? [[String: AnyObject]] {
                        let set = NSMutableSet()
                        
                        for company in companies {
                            set.addObject(findOrCreateCompany(company))
                        }
                        m.productionCompanies = set
                    }
                    
                    if let seasons = dict["seasons"] as? [[String: AnyObject]] {
                        for season in seasons {
                            let n = self.findOrCreateTVSeason(season)
                            n.tvShow = m
                        }
                    }
                    
                    m.update(dict)
                    CoreDataManager.sharedInstance.savePrivateContext()
                }
            } catch let error as NSError {
                print("Error in fetch \(error), \(error.userInfo)")
            }
        }
    }
    
    func findOrCreateTVSeason(dict: [String: AnyObject]) -> TVSeason {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> TVSeason in
            return TVSeason(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "TVSeason", objectKey: "tvSeasonID", objectValue: dict[TVSeason.Keys.TVSeasonID] as! NSObject, initializer: initializer) as! TVSeason
    }
    
    func findOrCreatePerson(dict: [String: AnyObject]) -> Person {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Person in
            return Person(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Person", objectKey: "personID", objectValue: dict[Person.Keys.PersonID] as! NSObject, initializer: initializer) as! Person
    }
    
    func updatePerson(dict: [String: AnyObject]) {
        if let personID = dict[Person.Keys.PersonID] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: "Person")
            fetchRequest.predicate = NSPredicate(format: "personID == %@", personID)
            
            do {
                if let m = try privateContext.executeFetchRequest(fetchRequest).first as? Person {
                    m.update(dict)
                    CoreDataManager.sharedInstance.savePrivateContext()
                }
            } catch let error as NSError {
                print("Error in fetch \(error), \(error.userInfo)")
            }
        }
    }

    
    func findOrCreateGenre(dict: [String: AnyObject]) -> Genre {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Genre in
            return Genre(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Genre", objectKey: "genreID", objectValue: dict[Genre.Keys.GenreID] as! NSObject, initializer: initializer) as! Genre
    }
    
    func findOrCreateCompany(dict: [String: AnyObject]) -> Company {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Company in
            return Company(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Company", objectKey: "companyID", objectValue: dict[Company.Keys.CompanyID] as! NSObject, initializer: initializer) as! Company
    }
    
    func findOrCreateCountry(dict: [String: AnyObject]) -> Country {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Country in
            return Country(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Country", objectKey: "name", objectValue: dict[Country.Keys.Name] as! NSObject, initializer: initializer) as! Country
    }
    
    func findOrCreateLanguage(dict: [String: AnyObject]) -> Language {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Language in
            return Language(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Language", objectKey: "name", objectValue: dict[Language.Keys.Name] as! NSObject, initializer: initializer) as! Language
    }
    
    func findOrCreateNetwork(dict: [String: AnyObject]) -> Network {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Network in
            return Network(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Network", objectKey: "name", objectValue: dict[Network.Keys.Name] as! NSObject, initializer: initializer) as! Network
    }
    
    func findOrCreateJob(dict: [String: AnyObject]) -> Job {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Job in
            return Job(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Job", objectKey: "name", objectValue: dict[Job.Keys.Name] as! NSObject, initializer: initializer) as! Job
    }
    
    func findOrCreateImage(dict: [String: AnyObject], imageType: ImageType, forObject object: AnyObject) -> Image {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Image in
            return Image(dictionary: dict, context: context)
        }
        
        let image = findOrCreateObject(dict, entityName: "Image", objectKey: "filePath", objectValue: dict[Image.Keys.FilePath] as! NSObject, initializer: initializer) as! Image
        
        
        switch imageType {
        case .MovieBackdrop:
            image.movieBackdrop = object as? Movie
        case .MoviePoster:
            image.moviePoster = object as? Movie
        case .TVShowBackdrop:
            image.tvShowBackdrop = object as? TVShow
        case .TVShowPoster:
            image.tvShowPoster = object as? TVShow
        case .PersonProfile:
            image.personProfile = object as? Person
        }
        CoreDataManager.sharedInstance.savePrivateContext()

        
        return image
    }
    
    func findOrCreateCredit(dict: [String: AnyObject], creditType: CreditType, creditParent: CreditParent, forObject object: AnyObject) -> Credit {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Credit in
            return Credit(dictionary: dict, context: context)
        }
        
        let credit = findOrCreateObject(dict, entityName: "Credit", objectKey: "creditID", objectValue: dict[Credit.Keys.CreditID] as! NSObject, initializer: initializer) as! Credit

        switch creditParent {
        case .Job:
            // TODO: ...
            credit.job = object as? Job
        case .Movie:
            credit.movie = object as? Movie
            switch creditType {
            case .Cast:
                var personDict = [
                    Person.Keys.PersonID: dict[Person.Keys.PersonID] as! NSNumber,
                    Person.Keys.Name: dict[Person.Keys.Name] as! String]
                if let profilePath = dict[Person.Keys.ProfilePath] as? String {
                    personDict[Person.Keys.ProfilePath] = profilePath
                }
                credit.person = findOrCreatePerson(personDict)
            case .Crew:
                let jobDict = [
                    Job.Keys.Department: dict[Job.Keys.Department] as! String,
                    Job.Keys.Name: dict[Job.Keys.Job] as! String]
                var personDict = [
                    Person.Keys.PersonID: dict[Person.Keys.PersonID] as! NSNumber,
                    Person.Keys.Name: dict[Person.Keys.Name] as! String]
                if let profilePath = dict[Person.Keys.ProfilePath] as? String {
                    personDict[Person.Keys.ProfilePath] = profilePath
                }
                credit.job = findOrCreateJob(jobDict)
                credit.person = findOrCreatePerson(personDict)
            case .GuestStar:
                print("x")
            }
        case .Person:
            if let mediaType = dict["media_type"] as? String {
                if mediaType == "movie" {
                    var movieDict = [
                        Movie.Keys.MovieID: dict[Movie.Keys.MovieID] as! NSNumber,
                        Movie.Keys.Title: dict[Movie.Keys.Title] as! String]
                    if let originalTitle = dict[Movie.Keys.OriginalTitle] as? String {
                        movieDict[Movie.Keys.OriginalTitle] = originalTitle
                    }
                    if let posterPath = dict[Movie.Keys.PosterPath] as? String {
                        movieDict[Movie.Keys.PosterPath] = posterPath
                    }
                    if let releaseDate = dict[Movie.Keys.ReleaseDate] as? String {
                        movieDict[Movie.Keys.ReleaseDate] = releaseDate
                    }
                    credit.movie = findOrCreateMovie(movieDict)
                } else if mediaType == "tv" {
                    var tvDict = [
                        TVShow.Keys.TVShowID: dict[TVShow.Keys.TVShowID] as! NSNumber,
                        TVShow.Keys.Name: dict[TVShow.Keys.Name] as! String]
                    if let firstAirDate = dict[TVShow.Keys.FirstAirDate] as? String {
                        tvDict[TVShow.Keys.FirstAirDate] = firstAirDate
                    }
                    if let originalName = dict[TVShow.Keys.OriginalName] as? String {
                        tvDict[TVShow.Keys.OriginalName] = originalName
                    }
                    if let posterPath = dict[TVShow.Keys.PosterPath] as? String {
                        tvDict[TVShow.Keys.PosterPath] = posterPath
                    }
                    credit.tvShow = findOrCreateTVShow(tvDict)
                }
            }
            
            if creditType == .Crew {
                let jobDict = [
                    Job.Keys.Department: dict[Job.Keys.Department] as! String,
                    Job.Keys.Name: dict[Job.Keys.Job] as! String]
                credit.job = findOrCreateJob(jobDict)
            }
            
            credit.person = object as? Person
            
        case .TVEpisode:
            // TODO: ...
            credit.tvEpisode = object as? TVEpisode
        case .TVSeason:
            // TODO: ...
            credit.tvSeason = object as? TVSeason
        case .TVShow:
            credit.tvShow = object as? TVShow
            switch creditType {
            case .Cast:
                var personDict = [
                    Person.Keys.PersonID: dict[Person.Keys.PersonID] as! NSNumber,
                    Person.Keys.Name: dict[Person.Keys.Name] as! String]
                if let profilePath = dict[Person.Keys.ProfilePath] as? String {
                    personDict[Person.Keys.ProfilePath] = profilePath
                }
                credit.person = findOrCreatePerson(personDict)
            case .Crew:
                let jobDict = [
                    Job.Keys.Department: dict[Job.Keys.Department] as! String,
                    Job.Keys.Name: dict[Job.Keys.Job] as! String]
                var personDict = [
                    Person.Keys.PersonID: dict[Person.Keys.PersonID] as! NSNumber,
                    Person.Keys.Name: dict[Person.Keys.Name] as! String]
                if let profilePath = dict[Person.Keys.ProfilePath] as? String {
                    personDict[Person.Keys.ProfilePath] = profilePath
                }
                credit.job = findOrCreateJob(jobDict)
                credit.person = findOrCreatePerson(personDict)
            case .GuestStar:
                print("x")
            }
        }
        
        credit.creditType = creditType.rawValue
        
        CoreDataManager.sharedInstance.savePrivateContext()
        
        return credit
    }
    
    func findOrCreateAccount(dict: [String: AnyObject]) -> Account {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Account in
            return Account(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Account", objectKey: "accountID", objectValue: dict[Account.Keys.AccountID] as! NSObject, initializer: initializer) as! Account
    }
    
    func findOrCreateReview(dict: [String: AnyObject]) -> Review {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> Review in
            return Review(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "Review", objectKey: "link", objectValue: dict["link"]![Review.Keys.Link] as! NSObject, initializer: initializer) as! Review
    }
    
    func findOrCreateList(dict: [String: AnyObject]) -> List {
        let initializer = { (dict: [String: AnyObject], context: NSManagedObjectContext) -> List in
            return List(dictionary: dict, context: context)
        }
        
        return findOrCreateObject(dict, entityName: "List", objectKey: "listIDInt", objectValue: dict[List.Keys.ListID] as! NSObject, initializer: initializer) as! List
    }
    
    func findOrCreateObject(dict: [String: AnyObject], entityName: String, objectKey: String, objectValue: NSObject, initializer: (dict: [String: AnyObject], context: NSManagedObjectContext) -> AnyObject) -> AnyObject {
        var object:AnyObject?
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", objectKey, objectValue)
        
        do {
            if let m = try privateContext.executeFetchRequest(fetchRequest).first {
                object = m
                
            } else {
                object = initializer(dict: dict, context: privateContext)
                CoreDataManager.sharedInstance.savePrivateContext()
            }
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
        
        return object!
    }

    func findObjects(entityName: String, predicate: NSPredicate?, sorters: [NSSortDescriptor]?) -> [AnyObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sorters
        
        var objects:[AnyObject]?
        
        do {
            objects = try privateContext.executeFetchRequest(fetchRequest)
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
        
        return objects!
    }
    
    func fetchObjects(fetchRequest: NSFetchRequest) -> [AnyObject] {
        var objects:[AnyObject]?
        
        do {
            objects = try privateContext.executeFetchRequest(fetchRequest)
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
        
        return objects!
    }
    
    func deleteObject(entityName: String, objectKey: String, objectValue: NSObject) {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", objectKey, objectValue)
        
        do {
            if let m = try privateContext.executeFetchRequest(fetchRequest).first as? NSManagedObject {
                privateContext.deleteObject(m)
                CoreDataManager.sharedInstance.savePrivateContext()
                
            }
            
        } catch let error as NSError {
            print("Error in fetch \(error), \(error.userInfo)")
        }
    }
    
    func batchUpdate(entityName: String, propertiesToUpdate: [String: AnyObject], predicate: NSPredicate) {
        // code adapted from: http://code.tutsplus.com/tutorials/core-data-and-swift-batch-updates--cms-25120
        // Initialize Batch Update Request
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: entityName)
        
        // Configure Batch Update Request
        batchUpdateRequest.resultType = .UpdatedObjectIDsResultType
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate
        batchUpdateRequest.predicate = predicate
        
        do {
            // Execute Batch Request
            let batchUpdateResult = try privateContext.executeRequest(batchUpdateRequest) as! NSBatchUpdateResult
            
            // Extract Object IDs
            let objectIDs = batchUpdateResult.result as! [NSManagedObjectID]
            
            for objectID in objectIDs {
                let managedObject = privateContext.objectWithID(objectID)
                privateContext.refreshObject(managedObject, mergeChanges: false)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(ObjectManager.BatchUpdateNotification, object: nil, userInfo: nil)
            
        } catch {}
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = ObjectManager()
}
