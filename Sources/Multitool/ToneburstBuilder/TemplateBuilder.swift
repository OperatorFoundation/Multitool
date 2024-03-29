//
//  TemplateBuilder.swift
//
//
//  Created by Joseph Bragel on 3/28/24.
//

import Foundation

import Stencil

struct TemplateBuilder
{
    static func create(context: [String : Any], templateName: String) throws -> String
    {
        let loader = TemplateLoader()
        let environment = Environment(loader: loader)
        let rendered = try environment.renderTemplate(name: templateName, context: context)
        return rendered
    }
}
