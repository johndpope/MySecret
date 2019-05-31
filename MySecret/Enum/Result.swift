//
//  Result.swift
//  MySecret
//
//  Created by Amir lahav on 21/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation

enum Result<T>
{
    case success(T)
    case error(Error)
}
