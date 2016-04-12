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
        static let APIKey      = "api_key"
        static let APIKeyValue = "b6484c1f1ef60a8e5f5281452f964d9b"
        static let Parameters  = [APIKey: APIKeyValue]

        static let APIURL          = "https://api.themoviedb.org/3"
        static let SignupURL       = "https://www.themoviedb.org/account/signup"
        static let AuthenticateURL = "https://www.themoviedb.org/authenticate"
        static let ImageURL        = "https://image.tmdb.org/t/p"
        
        static let BackdropSizes = [
            "w300",
            "w780",
            "w1280",
            "original"]
        
        static let LogoSizes = [
            "w45",
            "w92",
            "w154",
            "w185",
            "w300",
            "w500",
            "original"]
        
        static let PosterSizes = [
            "w92",
            "w154",
            "w185",
            "w342",
            "w500",
            "w780",
            "original"]
        
        static let ProfileSizes = [
            "w45",
            "w92", // not include in TMDB configuration
            "w185",
            "h632",
            "original"]
        
        static let StillSizes = [
            "w92",
            "w185",
            "w300",
            "original"]
        
        struct iPad {
            struct Keys {
                static let RequestToken     = "request_token"
                static let RequestTokenDate = "request_token_date"
                static let SessionID        = "session_id"
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
            }
            
            struct ID {
                static let Path = "/movie/{id}"
            }
        }
        
        struct TVShows {
            struct OnTheAir {
                static let Path = "/tv/on_the_air"
            }
            struct AiringToday {
                static let Path = "/tv/airing_today"
            }
        }
        
        struct People {
            struct Popular {
                static let Path = "/person/popular"
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