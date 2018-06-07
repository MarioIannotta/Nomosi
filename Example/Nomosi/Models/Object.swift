//
//  Object.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

struct Object: Decodable {
    
    struct SeeAlso: Decodable {
        let id, type, format, profile: String?
    }
    
    struct Worktype: Decodable {
        let worktypeid, worktype: String?
    }
    
    let accessionyear: Int?
    let technique: String?
    let mediacount: Int?
    let edition: String?
    let totalpageviews, groupcount: Int?
    let people: [Person]?
    let objectnumber: String?
    let colorcount: Int?
    let lastupdate: String?
    let rank, imagecount: Int?
    let description, dateoflastpageview, dateoffirstpageview: String?
    let primaryimageurl, dated: String?
    let contextualtextcount: Int?
    let copyright, period: String?
    let accessionmethod, url: String?
    let provenance: String?
    let images: [Image]?
    let publicationcount, objectid: Int?
    let culture, verificationleveldescription: String?
    let standardreferencenumber: String?
    let worktypes: [Worktype]?
    let department: String?
    let state: String?
    let markscount: Int?
    let contact: String?
    let titlescount, id: Int?
    let title: String?
    let verificationlevel: Int?
    let division: String?
    let style, commentary: String?
    let relatedcount, datebegin: Int?
    let labeltext: String?
    let totaluniquepageviews: Int?
    let dimensions: String?
    let exhibitioncount, techniqueid, dateend: Int?
    let creditline: String?
    let imagepermissionlevel: Int?
    let signed, periodid: String?
    let century: String?
    let classificationid: Int?
    let medium: String?
    let peoplecount, accesslevel: Int?
    let classification: String?
    let seeAlso: [SeeAlso]?
    
}
