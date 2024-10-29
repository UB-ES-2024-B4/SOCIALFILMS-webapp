import type { GenreId } from "./genres";

export interface Film {
    poster: string
    title: string
    overview: string
    isAdult: boolean
    genre: GenreId[]
    releaseDate: string
    voteAverage: number
    voteCount: number
  }