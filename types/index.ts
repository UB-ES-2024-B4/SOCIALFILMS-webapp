import type { GenreId } from "./genres"

export interface Film {
  id: number
  media_type: string
  poster_path: string
  backdrop_path: string
  original_title: string
  title: string
  overview: string
  adult: boolean
  genre_ids?: GenreId[]
  genres?: Genre[]
  release_date: string
  runtime: number
  vote_average: number
  vote_count: number
  popularity: number
  spoken_languages?: SpokenLanguage[]
  production_countries?: ProductionCountry[]
}

interface Genre {
  id: number
  name?: string
}

interface SpokenLanguage {
  english_name: string
  iso_639_1: string
  name: string
}

interface ProductionCountry {
  iso_3166_1: string
  name: string
}

interface Genre {
  id: number
  name?: string
}

export interface FilmsAPI {
  results: Film[]
}

export interface Review {
  id: string
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

export interface SearchFilters {
  genre?: string
  country?: string
  language?: string
  year?: string
}

export const countries = [
  { name: 'Australia', code: 'AU' },
  { name: 'Brazil', code: 'BR' },
  { name: 'China', code: 'CN' },
  { name: 'Egypt', code: 'EG' },
  { name: 'France', code: 'FR' },
  { name: 'Germany', code: 'DE' },
  { name: 'India', code: 'IN' },
  { name: 'Japan', code: 'JP' },
  { name: 'Spain', code: 'ES' },
  { name: 'United States', code: 'US' },
  { name: 'Argentina', code: 'AR' },
  { name: 'Belgium', code: 'BE' },
  { name: 'Canada', code: 'CA' },
  { name: 'Italy', code: 'IT' },
  { name: 'Mexico', code: 'MX' },
  { name: 'Netherlands', code: 'NL' },
  { name: 'Poland', code: 'PL' },
  { name: 'Russia', code: 'RU' },
  { name: 'South Korea', code: 'KR' },
  { name: 'Turkey', code: 'TR' },
  { name: 'United Kingdom', code: 'GB' },
  { name: 'Vietnam', code: 'VN' },
  { name: 'South Africa', code: 'ZA' },
  { name: 'Nigeria', code: 'NG' },
  { name: 'Colombia', code: 'CO' },
  { name: 'Thailand', code: 'TH' },
  { name: 'Saudi Arabia', code: 'SA' },
  { name: 'Sweden', code: 'SE' },
  { name: 'Switzerland', code: 'CH' },
  { name: 'Ukraine', code: 'UA' },
  { name: 'Malaysia', code: 'MY' },
  { name: 'Singapore', code: 'SG' },
  { name: 'Chile', code: 'CL' },
  { name: 'Israel', code: 'IL' },
  { name: 'Romania', code: 'RO' },
  { name: 'Norway', code: 'NO' },
  { name: 'Finland', code: 'FI' },
  { name: 'Denmark', code: 'DK' },
  { name: 'Portugal', code: 'PT' },
  { name: 'Ireland', code: 'IE' },
  { name: 'New Zealand', code: 'NZ' },
  { name: 'Philippines', code: 'PH' },
  { name: 'Indonesia', code: 'ID' },
  { name: 'Pakistan', code: 'PK' },
  { name: 'Bangladesh', code: 'BD' },
  { name: 'Peru', code: 'PE' },
  { name: 'Czech Republic', code: 'CZ' },
  { name: 'Greece', code: 'GR' },
  { name: 'Hungary', code: 'HU' },
  { name: 'Slovakia', code: 'SK' },
  { name: 'Bulgaria', code: 'BG' },
  { name: 'Croatia', code: 'HR' },
  { name: 'Slovenia', code: 'SI' },
  { name: 'Latvia', code: 'LV' },
  { name: 'Lithuania', code: 'LT' },
  { name: 'Estonia', code: 'EE' },
  { name: 'Belarus', code: 'BY' },
  { name: 'Kazakhstan', code: 'KZ' },
  { name: 'Uzbekistan', code: 'UZ' },
  { name: 'Azerbaijan', code: 'AZ' },
  { name: 'Armenia', code: 'AM' },
  { name: 'Moldova', code: 'MD' },
  { name: 'Georgia', code: 'GE' },
  { name: 'Kyrgyzstan', code: 'KG' },
  { name: 'Tajikistan', code: 'TJ' },
  { name: 'Turkmenistan', code: 'TM' },
  { name: 'Kuwait', code: 'KW' },
  { name: 'Oman', code: 'OM' },
  { name: 'Qatar', code: 'QA' },
  { name: 'Bahrain', code: 'BH' },
  { name: 'Jordan', code: 'JO' },
  { name: 'Lebanon', code: 'LB' },
  { name: 'Syria', code: 'SY' },
  { name: 'Iraq', code: 'IQ' },
  { name: 'Afghanistan', code: 'AF' },
  { name: 'Mongolia', code: 'MN' },
  { name: 'Nepal', code: 'NP' }
]

export const languages = [
  { name: 'English', code: 'en' },
  { name: 'Spanish', code: 'es' },
  { name: 'French', code: 'fr' },
  { name: 'German', code: 'de' },
  { name: 'Chinese', code: 'zh' },
  { name: 'Hindi', code: 'hi' },
  { name: 'Arabic', code: 'ar' },
  { name: 'Portuguese', code: 'pt' },
  { name: 'Russian', code: 'ru' },
  { name: 'Japanese', code: 'ja' },
  { name: 'Italian', code: 'it' },
  { name: 'Korean', code: 'ko' },
  { name: 'Dutch', code: 'nl' },
  { name: 'Turkish', code: 'tr' },
  { name: 'Swedish', code: 'sv' },
  { name: 'Polish', code: 'pl' },
  { name: 'Thai', code: 'th' },
  { name: 'Hebrew', code: 'he' },
  { name: 'Greek', code: 'el' },
  { name: 'Czech', code: 'cs' },
  { name: 'Hungarian', code: 'hu' },
  { name: 'Vietnamese', code: 'vi' },
  { name: 'Romanian', code: 'ro' },
  { name: 'Ukrainian', code: 'uk' },
  { name: 'Bengali', code: 'bn' },
  { name: 'Finnish', code: 'fi' },
  { name: 'Norwegian', code: 'no' },
  { name: 'Danish', code: 'da' },
  { name: 'Swahili', code: 'sw' },
  { name: 'Malay', code: 'ms' },
  { name: 'Indonesian', code: 'id' },
  { name: 'Tagalog', code: 'tl' },
  { name: 'Uzbek', code: 'uz' },
  { name: 'Serbian', code: 'sr' },
  { name: 'Croatian', code: 'hr' },
  { name: 'Bulgarian', code: 'bg' },
  { name: 'Slovak', code: 'sk' },
  { name: 'Slovenian', code: 'sl' },
  { name: 'Latvian', code: 'lv' },
  { name: 'Lithuanian', code: 'lt' },
  { name: 'Estonian', code: 'et' },
  { name: 'Georgian', code: 'ka' },
  { name: 'Armenian', code: 'hy' },
  { name: 'Macedonian', code: 'mk' },
  { name: 'Basque', code: 'eu' },
  { name: 'Catalan', code: 'ca' },
  { name: 'Welsh', code: 'cy' },
  { name: 'Irish', code: 'ga' },
  { name: 'Albanian', code: 'sq' },
  { name: 'Icelandic', code: 'is' },
  { name: 'Malagasy', code: 'mg' },
  { name: 'Maltese', code: 'mt' },
  { name: 'Punjabi', code: 'pa' },
  { name: 'Gujarati', code: 'gu' },
  { name: 'Tamil', code: 'ta' },
  { name: 'Telugu', code: 'te' },
  { name: 'Kannada', code: 'kn' },
  { name: 'Marathi', code: 'mr' },
  { name: 'Sinhala', code: 'si' },
  { name: 'Nepali', code: 'ne' },
  { name: 'Khmer', code: 'km' },
  { name: 'Lao', code: 'lo' },
  { name: 'Burmese', code: 'my' },
  { name: 'Pashto', code: 'ps' },
  { name: 'Farsi', code: 'fa' },
  { name: 'Somali', code: 'so' },
  { name: 'Haitian Creole', code: 'ht' },
  { name: 'Mongolian', code: 'mn' },
  { name: 'Quechua', code: 'qu' },
  { name: 'Xhosa', code: 'xh' },
  { name: 'Zulu', code: 'zu' },
  { name: 'Tagalog', code: 'tl' }
]

export const genres = [
  { name: 'Action', code: 28 },
  { name: 'Adventure', code: 12 },
  { name: 'Animation', code: 16 },
  { name: 'Comedy', code: 35 },
  { name: 'Crime', code: 80 },
  { name: 'Documentary', code: 99 },
  { name: 'Drama', code: 18 },
  { name: 'Family', code: 10751 },
  { name: 'Fantasy', code: 14 },
  { name: 'History', code: 36 },
  { name: 'Horror', code: 27 },
  { name: 'Music', code: 10402 },
  { name: 'Mystery', code: 9648 },
  { name: 'Romance', code: 10749 },
  { name: 'Science Fiction', code: 878 },
  { name: 'TV Movie', code: 10770 },
  { name: 'Thriller', code: 53 },
  { name: 'War', code: 10752 },
  { name: 'Western', code: 37 }
]
