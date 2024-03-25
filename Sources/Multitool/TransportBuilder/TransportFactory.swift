//
//  TransportFactory.swift
//
//
//  Created by Mafalda on 3/11/24.
//

import Foundation

import Stencil

struct TransportFactory
{
    static func create(name: String, modes: [String], toneburstName: String) throws -> String
    {
        let context: [String:Any] = ["name": name, "modes": modes, "toneburstName": toneburstName]
        let loader = TemplateLoader()
        let environment = Environment(loader: loader)
        let rendered = try environment.renderTemplate(name: "Transport", context: context)
        return rendered
    }
}
