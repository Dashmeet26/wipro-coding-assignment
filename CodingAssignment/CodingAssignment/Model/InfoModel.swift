//
//  InfoModel.swift
//  CodingAssignment
//
//  Created by FT User on 14/10/20.
//  Copyright © 2020 FT User. All rights reserved.
//

import UIKit


struct HeaderData: Decodable {
    let title: String?
    let rows: [DescriptionData]
}

struct DescriptionData: Decodable {
    let title: String?
    let description: String?
    let imageHref: String?
}
