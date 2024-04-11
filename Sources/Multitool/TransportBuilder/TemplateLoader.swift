//
//  TemplateLoader.swift
//
//
//  Created by Mafalda on 3/6/24.
//

import Foundation

import Stencil

class TemplateLoader: Loader
{
    func loadTemplate(name: String, environment: Stencil.Environment) throws -> Stencil.Template 
    {
        guard let fileURL = Bundle.module.url(forResource: name, withExtension: Extensions.txt.rawValue) else
        {
            throw TemplateDoesNotExist(templateNames: [name], loader: self)
        }
        
        let fileContents = try String(contentsOf: fileURL)
        return Template(templateString: fileContents, environment: environment)
    }
}
