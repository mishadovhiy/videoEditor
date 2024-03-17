//
//  Response.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 17.03.2024.
//

import Foundation

struct Response {
    var error:NSError?
    var response:SuccessResponse? = SuccessResponseData()

    init(error: NSError? = nil, response: SuccessResponse? = nil) {
        self.error = error
        if error == nil && response == nil {
            self.response = response
        } else {
            self.response = response
        }
    }
    
    static func success(_ response:SuccessResponse? = nil) -> Response {
        return .init(response:response)
    }
    
    static func error(_ message:MessageContent) -> Response {
        return .init(error: .init(text: message.title))
    }
    
    static func error(_ text:String?) -> Response {
        return Response.error(.init(title: text))
    }
    
    var videoExportResponse:VideoExport? {
        return response as? VideoExport
    }
}

extension Response {
    struct SuccessResponseData: SuccessResponse {
        var data: Any = ""
    }
    struct VideoExport:VideoProccessingExportResponse {
        var data: Any = ""
        var url:URL?
    }
}

protocol SuccessResponse {
    var data:Any {get set}
}
 

protocol VideoProccessingExportResponse:SuccessResponse {
    var url:URL? { get set}
}


