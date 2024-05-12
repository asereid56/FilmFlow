//
//  Movie.swift
//  TableView
//
//  Created by JETSMobileLabMini12 on 22/04/2024.
//

import Foundation
struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Movie
struct Movie: Codable {
    let adult: Bool
    let backdropPath: String
    let genreIDS: [Int]
    let id: Int
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath, releaseDate, title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    init(id: Int, originalTitle: String, overview: String, posterPath: String, releaseDate: String, voteAverage: Double) {
        self.adult = false
        self.backdropPath = ""
        self.genreIDS = []
        self.id = id
        self.originalLanguage = ""
        self.originalTitle = originalTitle
        self.overview = overview
        self.popularity = 0.0
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.title = ""
        self.video = false
        self.voteAverage = voteAverage
        self.voteCount = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
