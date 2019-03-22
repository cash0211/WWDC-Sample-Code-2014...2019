/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The Earthquake model object.
*/

import Foundation
import CoreData
import CoreLocation

/*
    An `NSManagedObject` subclass to model basic earthquake properties. This also
    contains some convenience methods to aid in formatting the information.
*/
class Earthquake: NSManagedObject {
    // MARK: Static Properties

    static let entityName = "Earthquake"
    
    // MARK: Formatters

    static let timestampFormatter: NSDateFormatter = {
        let timestampFormatter = NSDateFormatter()
        
        timestampFormatter.dateStyle = .MediumStyle
        timestampFormatter.timeStyle = .MediumStyle

        return timestampFormatter
    }()
    
    static let magnitudeFormatter: NSNumberFormatter = {
        let magnitudeFormatter = NSNumberFormatter()
        
        magnitudeFormatter.numberStyle = .DecimalStyle
        magnitudeFormatter.maximumFractionDigits = 1
        magnitudeFormatter.minimumFractionDigits = 1

        return magnitudeFormatter
    }()
    
    static let depthFormatter: NSLengthFormatter = {
        
        let depthFormatter = NSLengthFormatter()
        depthFormatter.forPersonHeightUse = false

        return depthFormatter
    }()
    
    static let distanceFormatter: NSLengthFormatter = {
        let distanceFormatter = NSLengthFormatter()

        distanceFormatter.forPersonHeightUse = false
        distanceFormatter.numberFormatter.maximumFractionDigits = 2
        
        return distanceFormatter
    }()

    // MARK: Properties
    
    @NSManaged var identifier: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var name: String
    @NSManaged var magnitude: Double
    @NSManaged var timestamp: NSDate
    @NSManaged var depth: Double
    @NSManaged var webLink: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        return CLLocation(coordinate: coordinate, altitude: -depth, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timestamp)
    }
}
