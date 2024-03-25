//
//  ToneburstTemplate.swift
//
//
//  Created by Mafalda on 3/11/24.
//

import Foundation

import Stencil

struct ToneBurstMode
{
    let name: String
    let function: String
}

struct ToneBurstTemplate
{
    let name: String
    let modes: [ToneBurstMode]
    
    static func create(toneburst: ToneBurstTemplate) throws -> String
    {
        let context = ["toneburst": toneburst]
        let loader = TemplateLoader()
        let environment = Environment(loader: loader)
        let rendered = try environment.renderTemplate(name: "Toneburst", context: context)
        return rendered
    }
}
