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
  { name: 'Egypt', code: 'EG' },
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
  { name: 'English (US)', code: 'en-US' },
  { name: 'English (UK)', code: 'en-GB' },
  { name: 'Spanish (Spain)', code: 'es-ES' },
  { name: 'Spanish (Latin America)', code: 'es-419' },
  { name: 'French (France)', code: 'fr-FR' },
  { name: 'French (Canada)', code: 'fr-CA' },
  { name: 'German', code: 'de-DE' },
  { name: 'Chinese (Simplified)', code: 'zh-CN' },
  { name: 'Chinese (Traditional)', code: 'zh-TW' },
  { name: 'Hindi', code: 'hi-IN' },
  { name: 'Arabic (Egypt)', code: 'ar-EG' },
  { name: 'Arabic (Saudi Arabia)', code: 'ar-SA' },
  { name: 'Portuguese (Brazil)', code: 'pt-BR' },
  { name: 'Portuguese (Portugal)', code: 'pt-PT' },
  { name: 'Russian', code: 'ru-RU' },
  { name: 'Japanese', code: 'ja-JP' },
  { name: 'Italian', code: 'it-IT' },
  { name: 'Korean', code: 'ko-KR' },
  { name: 'Dutch', code: 'nl-NL' },
  { name: 'Turkish', code: 'tr-TR' },
  { name: 'Swedish', code: 'sv-SE' },
  { name: 'Polish', code: 'pl-PL' },
  { name: 'Thai', code: 'th-TH' },
  { name: 'Hebrew', code: 'he-IL' },
  { name: 'Greek', code: 'el-GR' },
  { name: 'Czech', code: 'cs-CZ' },
  { name: 'Hungarian', code: 'hu-HU' },
  { name: 'Vietnamese', code: 'vi-VN' },
  { name: 'Romanian', code: 'ro-RO' },
  { name: 'Swahili', code: 'sw-KE' },
  { name: 'Bengali', code: 'bn-IN' },
  { name: 'Tamil', code: 'ta-IN' },
  { name: 'Telugu', code: 'te-IN' },
  { name: 'Punjabi', code: 'pa-IN' },
  { name: 'Urdu', code: 'ur-PK' },
  { name: 'Malay', code: 'ms-MY' },
  { name: 'Indonesian', code: 'id-ID' },
  { name: 'Filipino', code: 'fil-PH' },
  { name: 'Ukrainian', code: 'uk-UA' },
  { name: 'Norwegian', code: 'no-NO' },
  { name: 'Finnish', code: 'fi-FI' },
  { name: 'Danish', code: 'da-DK' },
  { name: 'Bulgarian', code: 'bg-BG' },
  { name: 'Serbian', code: 'sr-RS' },
  { name: 'Croatian', code: 'hr-HR' },
  { name: 'Slovak', code: 'sk-SK' },
  { name: 'Slovenian', code: 'sl-SI' },
  { name: 'Latvian', code: 'lv-LV' },
  { name: 'Lithuanian', code: 'lt-LT' },
  { name: 'Estonian', code: 'et-EE' },
  { name: 'Georgian', code: 'ka-GE' },
  { name: 'Albanian', code: 'sq-AL' },
  { name: 'Macedonian', code: 'mk-MK' },
  { name: 'Icelandic', code: 'is-IS' },
  { name: 'Bosnian', code: 'bs-BA' },
  { name: 'Catalan', code: 'ca-ES' },
  { name: 'Basque', code: 'eu-ES' },
  { name: 'Galician', code: 'gl-ES' },
  { name: 'Welsh', code: 'cy-GB' },
  { name: 'Irish', code: 'ga-IE' }
]

export const genres = [
  { name: 'Action', code: '28' },
  { name: 'Adventure', code: '12' },
  { name: 'Animation', code: '16' },
  { name: 'Comedy', code: '35' },
  { name: 'Crime', code: '80' },
  { name: 'Documentary', code: '99' },
  { name: 'Drama', code: '18' },
  { name: 'Family', code: '10751' },
  { name: 'Fantasy', code: '14' },
  { name: 'History', code: '36' },
  { name: 'Horror', code: '27' },
  { name: 'Music', code: '10402' },
  { name: 'Mystery', code: '9648' },
  { name: 'Romance', code: '10749' },
  { name: 'Science Fiction', code: '878' },
  { name: 'TV Movie', code: '10770' },
  { name: 'Thriller', code: '53' },
  { name: 'War', code: '10752' },
  { name: 'Western', code: '37' }
]