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
  movie_id: string
  created_at: Date
  comment: string
  likes: number
  dislikes: number
  shared_count: number
  rating: number
  editable: boolean
  spoilers: boolean
  film?: Film
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

export interface Profile {
  id?: string
  email?: string
  username: string
  followers?: number
  following?: number
  birth_date: Date
  country: string
  bio: string
  real_name: string
  last_name: string
  is_following?: boolean
}

export interface Following {
  following_id: string
  following_username: string
  followed_at: Date
}

export interface Followers {
  follower_id: string
  follower_username: string
  followed_at: Date
}

export const countries = [
  { name: 'Afghanistan', code: 'AF' },
  { name: 'Albania', code: 'AL' },
  { name: 'Algeria', code: 'DZ' },
  { name: 'Andorra', code: 'AD' },
  { name: 'Angola', code: 'AO' },
  { name: 'Antigua and Barbuda', code: 'AG' },
  { name: 'Argentina', code: 'AR' },
  { name: 'Armenia', code: 'AM' },
  { name: 'Australia', code: 'AU' },
  { name: 'Austria', code: 'AT' },
  { name: 'Azerbaijan', code: 'AZ' },
  { name: 'Bahamas', code: 'BS' },
  { name: 'Bahrain', code: 'BH' },
  { name: 'Bangladesh', code: 'BD' },
  { name: 'Barbados', code: 'BB' },
  { name: 'Belarus', code: 'BY' },
  { name: 'Belgium', code: 'BE' },
  { name: 'Belize', code: 'BZ' },
  { name: 'Benin', code: 'BJ' },
  { name: 'Bhutan', code: 'BT' },
  { name: 'Bolivia', code: 'BO' },
  { name: 'Bosnia and Herzegovina', code: 'BA' },
  { name: 'Botswana', code: 'BW' },
  { name: 'Brazil', code: 'BR' },
  { name: 'Brunei', code: 'BN' },
  { name: 'Bulgaria', code: 'BG' },
  { name: 'Burkina Faso', code: 'BF' },
  { name: 'Burundi', code: 'BI' },
  { name: 'Cabo Verde', code: 'CV' },
  { name: 'Cambodia', code: 'KH' },
  { name: 'Cameroon', code: 'CM' },
  { name: 'Canada', code: 'CA' },
  { name: 'Central African Republic', code: 'CF' },
  { name: 'Chad', code: 'TD' },
  { name: 'Chile', code: 'CL' },
  { name: 'China', code: 'CN' },
  { name: 'Colombia', code: 'CO' },
  { name: 'Comoros', code: 'KM' },
  { name: 'Congo', code: 'CG' },
  { name: 'Costa Rica', code: 'CR' },
  { name: 'Croatia', code: 'HR' },
  { name: 'Cuba', code: 'CU' },
  { name: 'Cyprus', code: 'CY' },
  { name: 'Czechia', code: 'CZ' },
  { name: 'Denmark', code: 'DK' },
  { name: 'Djibouti', code: 'DJ' },
  { name: 'Dominica', code: 'DM' },
  { name: 'Dominican Republic', code: 'DO' },
  { name: 'Ecuador', code: 'EC' },
  { name: 'Egypt', code: 'EG' },
  { name: 'El Salvador', code: 'SV' },
  { name: 'Equatorial Guinea', code: 'GQ' },
  { name: 'Eritrea', code: 'ER' },
  { name: 'Estonia', code: 'EE' },
  { name: 'Eswatini', code: 'SZ' },
  { name: 'Ethiopia', code: 'ET' },
  { name: 'Fiji', code: 'FJ' },
  { name: 'Finland', code: 'FI' },
  { name: 'France', code: 'FR' },
  { name: 'Gabon', code: 'GA' },
  { name: 'Gambia', code: 'GM' },
  { name: 'Georgia', code: 'GE' },
  { name: 'Germany', code: 'DE' },
  { name: 'Ghana', code: 'GH' },
  { name: 'Greece', code: 'GR' },
  { name: 'Grenada', code: 'GD' },
  { name: 'Guatemala', code: 'GT' },
  { name: 'Guinea', code: 'GN' },
  { name: 'Guinea-Bissau', code: 'GW' },
  { name: 'Guyana', code: 'GY' },
  { name: 'Haiti', code: 'HT' },
  { name: 'Holy See', code: 'VA' },
  { name: 'Honduras', code: 'HN' },
  { name: 'Hungary', code: 'HU' },
  { name: 'Iceland', code: 'IS' },
  { name: 'India', code: 'IN' },
  { name: 'Indonesia', code: 'ID' },
  { name: 'Iran', code: 'IR' },
  { name: 'Iraq', code: 'IQ' },
  { name: 'Ireland', code: 'IE' },
  { name: 'Israel', code: 'IL' },
  { name: 'Italy', code: 'IT' },
  { name: 'Jamaica', code: 'JM' },
  { name: 'Japan', code: 'JP' },
  { name: 'Jordan', code: 'JO' },
  { name: 'Kazakhstan', code: 'KZ' },
  { name: 'Kenya', code: 'KE' },
  { name: 'Kiribati', code: 'KI' },
  { name: 'Korea North', code: 'KP' },
  { name: 'Korea South', code: 'KR' },
  { name: 'Kuwait', code: 'KW' },
  { name: 'Kyrgyzstan', code: 'KG' },
  { name: 'Laos', code: 'LA' },
  { name: 'Latvia', code: 'LV' },
  { name: 'Lebanon', code: 'LB' },
  { name: 'Lesotho', code: 'LS' },
  { name: 'Liberia', code: 'LR' },
  { name: 'Libya', code: 'LY' },
  { name: 'Liechtenstein', code: 'LI' },
  { name: 'Lithuania', code: 'LT' },
  { name: 'Luxembourg', code: 'LU' },
  { name: 'Madagascar', code: 'MG' },
  { name: 'Malawi', code: 'MW' },
  { name: 'Malaysia', code: 'MY' },
  { name: 'Maldives', code: 'MV' },
  { name: 'Mali', code: 'ML' },
  { name: 'Malta', code: 'MT' },
  { name: 'Marshall Islands', code: 'MH' },
  { name: 'Mauritania', code: 'MR' },
  { name: 'Mauritius', code: 'MU' },
  { name: 'Mexico', code: 'MX' },
  { name: 'Micronesia', code: 'FM' },
  { name: 'Moldova', code: 'MD' },
  { name: 'Monaco', code: 'MC' },
  { name: 'Mongolia', code: 'MN' },
  { name: 'Montenegro', code: 'ME' },
  { name: 'Morocco', code: 'MA' },
  { name: 'Mozambique', code: 'MZ' },
  { name: 'Myanmar', code: 'MM' },
  { name: 'Namibia', code: 'NA' },
  { name: 'Nauru', code: 'NR' },
  { name: 'Nepal', code: 'NP' },
  { name: 'Netherlands', code: 'NL' },
  { name: 'New Zealand', code: 'NZ' },
  { name: 'Nicaragua', code: 'NI' },
  { name: 'Niger', code: 'NE' },
  { name: 'Nigeria', code: 'NG' },
  { name: 'North Macedonia', code: 'MK' },
  { name: 'Norway', code: 'NO' },
  { name: 'Oman', code: 'OM' },
  { name: 'Pakistan', code: 'PK' },
  { name: 'Palau', code: 'PW' },
  { name: 'Palestine', code: 'PS' },
  { name: 'Panama', code: 'PA' },
  { name: 'Papua New Guinea', code: 'PG' },
  { name: 'Paraguay', code: 'PY' },
  { name: 'Peru', code: 'PE' },
  { name: 'Philippines', code: 'PH' },
  { name: 'Poland', code: 'PL' },
  { name: 'Portugal', code: 'PT' },
  { name: 'Qatar', code: 'QA' },
  { name: 'Romania', code: 'RO' },
  { name: 'Russia', code: 'RU' },
  { name: 'Rwanda', code: 'RW' },
  { name: 'Saint Kitts and Nevis', code: 'KN' },
  { name: 'Saint Lucia', code: 'LC' },
  { name: 'Saint Vincent and the Grenadines', code: 'VC' },
  { name: 'Samoa', code: 'WS' },
  { name: 'San Marino', code: 'SM' },
  { name: 'Sao Tome and Principe', code: 'ST' },
  { name: 'Saudi Arabia', code: 'SA' },
  { name: 'Senegal', code: 'SN' },
  { name: 'Serbia', code: 'RS' },
  { name: 'Seychelles', code: 'SC' },
  { name: 'Sierra Leone', code: 'SL' },
  { name: 'Singapore', code: 'SG' },
  { name: 'Slovakia', code: 'SK' },
  { name: 'Slovenia', code: 'SI' },
  { name: 'Solomon Islands', code: 'SB' },
  { name: 'Somalia', code: 'SO' },
  { name: 'South Africa', code: 'ZA' },
  { name: 'South Sudan', code: 'SS' },
  { name: 'Spain', code: 'ES' },
  { name: 'Sri Lanka', code: 'LK' },
  { name: 'Sudan', code: 'SD' },
  { name: 'Suriname', code: 'SR' },
  { name: 'Sweden', code: 'SE' },
  { name: 'Switzerland', code: 'CH' },
  { name: 'Syria', code: 'SY' },
  { name: 'Tajikistan', code: 'TJ' },
  { name: 'Tanzania', code: 'TZ' },
  { name: 'Thailand', code: 'TH' },
  { name: 'Timor-Leste', code: 'TL' },
  { name: 'Togo', code: 'TG' },
  { name: 'Tonga', code: 'TO' },
  { name: 'Trinidad and Tobago', code: 'TT' },
  { name: 'Tunisia', code: 'TN' },
  { name: 'Turkey', code: 'TR' },
  { name: 'Turkmenistan', code: 'TM' },
  { name: 'Tuvalu', code: 'TV' },
  { name: 'Uganda', code: 'UG' },
  { name: 'Ukraine', code: 'UA' },
  { name: 'United Arab Emirates', code: 'AE' },
  { name: 'United Kingdom', code: 'GB' },
  { name: 'United States', code: 'US' },
  { name: 'Uruguay', code: 'UY' },
  { name: 'Uzbekistan', code: 'UZ' },
  { name: 'Vanuatu', code: 'VU' },
  { name: 'Venezuela', code: 'VE' },
  { name: 'Vietnam', code: 'VN' },
  { name: 'Yemen', code: 'YE' },
  { name: 'Zambia', code: 'ZM' },
  { name: 'Zimbabwe', code: 'ZW' },
];  


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