import type { GenreId } from "./genres"

export interface Film {
  id: number
  media_type: string
  poster_path: string
  backdrop_path: string
  title: string
  overview: string
  adult: boolean
  genre_ids?: GenreId[]
  genres?: Genre[]
  release_date: string
  runtime: number
  vote_average: number
  vote_count: number
}

interface Genre {
  id: number
  name?: string
}

export interface FilmsAPI {
  results: Film[]
}

export interface Review {
  id: number
  user_id: string
  user?: string
  created_at: Date
  comment: string
  likes: number
  dislikes: number
  shared_count: number
  rating: number
  editable: boolean
  spoilers: boolean
}

export interface CreditsAPI {
  id: number
  cast: CastMember[]
  crew: CrewMember[]
}

export interface CastMember {
  adult: boolean
  gender: number
  id: number
  known_for_department: string
  name: string
  original_name: string
  popularity: number
  profile_path: string | null
  cast_id: number
  character: string
  credit_id: string
  order: number
}

export interface CrewMember {
  adult: boolean
  gender: number
  id: number
  known_for_department: string
  name: string
  original_name: string
  popularity: number
  profile_path: string | null
  credit_id: string
  department: string
  job: string
}