//
//  CenturiesService.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

class CenturiesService: HarvardArtMuseumService<CenturiesServiceResponse> {
    
    init() {
        super.init(resource: "century")
        self.mockProvider = self
    }
    
}

extension CenturiesService: MockProvider {
    
    var mockedData: DataConvertible {
        return """
{"info":{"totalrecordsperquery":10,"totalrecords":47,"pages":5,"page":1,"next":"https://api.harvardartmuseums.org/century?apikey=19222fd0-6a57-11e8-a0b5-c949d872863d&page=2"},"records":[{"id":37525365,"objectcount":81,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":2,"name":"Unidentified century"},{"id":37525536,"objectcount":643,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":17,"name":"10th century BCE"},{"id":37525554,"objectcount":661,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":19,"name":"8th century BCE"},{"id":37525563,"objectcount":504,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":20,"name":"7th century BCE"},{"id":37525590,"objectcount":3340,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":23,"name":"4th century BCE"},{"id":37525608,"objectcount":2856,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":24,"name":"3rd century BCE"},{"id":37525635,"objectcount":2647,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":27,"name":"1st century CE"},{"id":37525698,"objectcount":997,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":33,"name":"7th century"},{"id":37525725,"objectcount":672,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":36,"name":"10th century"},{"id":37525743,"objectcount":1430,"lastupdate":"2018-10-12T03:22:01-0400","temporalorder":38,"name":"12th century"}]}
"""
    }
    
    
}

struct CenturiesServiceResponse: ServiceResponse, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case centuries = "records"
    }
    
    let centuries: [Century]
    
}
