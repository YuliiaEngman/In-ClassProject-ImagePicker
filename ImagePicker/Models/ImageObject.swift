//
//  ImageObject.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

struct ImageObject: Codable {
  let imageData: Data // we cannot use UIImage directly, we have to work through Data
  let date: Date
  let identifier = UUID().uuidString // this will help us to create a unique identifier, creates authomatically
}
