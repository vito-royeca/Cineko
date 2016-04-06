//
//  Constants.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation

struct Constants {
    // Mark: The Movie Database
    struct TMDB {
        static let ApiScheme   = "https"
        static let ApiHost     = "api.themoviedb.org/3"
        static let APIKey      = "api_key"
        static let APIKeyValue = "b6484c1f1ef60a8e5f5281452f964d9b"
        static let Parameters  = [APIKey: APIKeyValue]
        
        static let SignupURL       = "https://www.themoviedb.org/account/signup"
        static let AuthenticateURL = "https://www.themoviedb.org/authenticate"
        
        struct iPad {
            struct Keys {
                static let RequestToken    = "request_token"
                static let RequestTokenDate   = "request_token_date"
                static let SessionID       = "session_id"
            }
        }
        
        struct Authentication {
            struct TokenNew {
                static let Path = "/authentication/token/new"
                struct Keys {
                    static let RequestToken = "request_token"
                }
            }
            
            struct SessionNew {
                static let Path = "/authentication/session/new"
                struct Keys {
                    static let SessionID = "session_id"
                }
            }
        }
        
        struct Movies {
            struct NowPlaying {
                static let Path = "/movie/now_playing"
                struct Keys {
                    static let Page = "page"
                    static let TotalPages = "total_page"
                    static let TotalResults = "total_results"
                    static let Results = "results"
                }
            }
        }
    }

    // MARK: Rotten Tomatoes
    struct RT {
        static let ApiScheme   = "http"
        static let ApiHost     = "hapi.rottentomatoes.com/api/public/v1.0.json"
        static let APIKey      = "api_key"
        static let APIKeyValue = "nr374sdjg6cu4frt4hfmtttg"
    }
}