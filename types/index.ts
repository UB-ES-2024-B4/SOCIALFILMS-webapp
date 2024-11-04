import type { GenreId } from "./genres"

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

export interface Review {
  id: number
  author: string
  datetime: Date
  content: string
  rating: number
}

interface CreditsAPI {
  id: number
  cast: CastMember[]
  crew: CrewMember[]
}

interface CastMember {
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

interface CrewMember {
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