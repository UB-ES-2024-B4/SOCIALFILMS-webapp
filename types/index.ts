import type { GenreId } from "./genres";

export interface Film {
  id: number
  media_type: string
  poster_path: string
  title: string
  overview: string
  adult: boolean
  genre_ids: GenreId[]
  release_date: string
  vote_average: number
  vote_count: number
}

export interface FilmsAPI {
  results: Film[]
}