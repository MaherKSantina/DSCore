//
//  DSModelView.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Vapor
import FluentMySQL

public protocol DSModelView: Migration, Content, ModelView {  }
