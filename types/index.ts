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
  relations?: filmRelations
}

interface filmRelations {
  is_favorite: boolean
  is_watch_later: boolean
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

export interface Notification {
  sender_id: string
  receiver_id: string
  movie_id: string
  is_read: boolean
  receiver_username: string
  sender_username: string
  created_at: string
}

export interface Notifications {
  notifications: Notification[]
  unread_count: number
}


export const countries = [
  { name: 'Afganistan', code: 'AF' },
  { name: 'Albània', code: 'AL' },
  { name: 'Algèria', code: 'DZ' },
  { name: 'Andorra', code: 'AD' },
  { name: 'Angola', code: 'AO' },
  { name: 'Antigua i Barbuda', code: 'AG' },
  { name: 'Argentina', code: 'AR' },
  { name: 'Armènia', code: 'AM' },
  { name: 'Austràlia', code: 'AU' },
  { name: 'Àustria', code: 'AT' },
  { name: 'Azerbaidjan', code: 'AZ' },
  { name: 'Bahames', code: 'BS' },
  { name: 'Bahrain', code: 'BH' },
  { name: 'Bangladesh', code: 'BD' },
  { name: 'Barbados', code: 'BB' },
  { name: 'Bielorússia', code: 'BY' },
  { name: 'Bèlgica', code: 'BE' },
  { name: 'Belize', code: 'BZ' },
  { name: 'Benín', code: 'BJ' },
  { name: 'Bhutan', code: 'BT' },
  { name: 'Bolívia', code: 'BO' },
  { name: 'Bòsnia i Hercegovina', code: 'BA' },
  { name: 'Botswana', code: 'BW' },
  { name: 'Brasil', code: 'BR' },
  { name: 'Brunei', code: 'BN' },
  { name: 'Bulgària', code: 'BG' },
  { name: 'Burkina Faso', code: 'BF' },
  { name: 'Burundi', code: 'BI' },
  { name: 'Cap Verd', code: 'CV' },
  { name: 'Cambodja', code: 'KH' },
  { name: 'Camerun', code: 'CM' },
  { name: 'Canadà', code: 'CA' },
  { name: 'República Centreafricana', code: 'CF' },
  { name: 'Txad', code: 'TD' },
  { name: 'Xile', code: 'CL' },
  { name: 'Xina', code: 'CN' },
  { name: 'Colòmbia', code: 'CO' },
  { name: 'Comores', code: 'KM' },
  { name: 'Congo', code: 'CG' },
  { name: 'Costa Rica', code: 'CR' },
  { name: 'Croàcia', code: 'HR' },
  { name: 'Cuba', code: 'CU' },
  { name: 'Xipre', code: 'CY' },
  { name: 'Txèquia', code: 'CZ' },
  { name: 'Dinamarca', code: 'DK' },
  { name: 'Djibouti', code: 'DJ' },
  { name: 'Dominica', code: 'DM' },
  { name: 'República Dominicana', code: 'DO' },
  { name: 'Equador', code: 'EC' },
  { name: 'Egipte', code: 'EG' },
  { name: 'El Salvador', code: 'SV' },
  { name: 'Guinea Equatorial', code: 'GQ' },
  { name: 'Eritrea', code: 'ER' },
  { name: 'Estònia', code: 'EE' },
  { name: 'Eswatini', code: 'SZ' },
  { name: 'Etiòpia', code: 'ET' },
  { name: 'Fiji', code: 'FJ' },
  { name: 'Finlàndia', code: 'FI' },
  { name: 'França', code: 'FR' },
  { name: 'Gabon', code: 'GA' },
  { name: 'Gàmbia', code: 'GM' },
  { name: 'Geòrgia', code: 'GE' },
  { name: 'Alemanya', code: 'DE' },
  { name: 'Ghana', code: 'GH' },
  { name: 'Grècia', code: 'GR' },
  { name: 'Grenada', code: 'GD' },
  { name: 'Guatemala', code: 'GT' },
  { name: 'Guinea', code: 'GN' },
  { name: 'Guinea Bissau', code: 'GW' },
  { name: 'Guyana', code: 'GY' },
  { name: 'Haití', code: 'HT' },
  { name: 'Santa Seu', code: 'VA' },
  { name: 'Hondures', code: 'HN' },
  { name: 'Hongria', code: 'HU' },
  { name: 'Islàndia', code: 'IS' },
  { name: 'Índia', code: 'IN' },
  { name: 'Indonèsia', code: 'ID' },
  { name: 'Iran', code: 'IR' },
  { name: 'Iraq', code: 'IQ' },
  { name: 'Irlanda', code: 'IE' },
  { name: 'Israel', code: 'IL' },
  { name: 'Itàlia', code: 'IT' },
  { name: 'Jamaica', code: 'JM' },
  { name: 'Japó', code: 'JP' },
  { name: 'Jordània', code: 'JO' },
  { name: 'Kazakhstan', code: 'KZ' },
  { name: 'Kenya', code: 'KE' },
  { name: 'Kiribati', code: 'KI' },
  { name: 'Corea del Nord', code: 'KP' },
  { name: 'Corea del Sud', code: 'KR' },
  { name: 'Kuwait', code: 'KW' },
  { name: 'Kirguizistan', code: 'KG' },
  { name: 'Laos', code: 'LA' },
  { name: 'Letònia', code: 'LV' },
  { name: 'Líban', code: 'LB' },
  { name: 'Lesotho', code: 'LS' },
  { name: 'Libèria', code: 'LR' },
  { name: 'Líbia', code: 'LY' },
  { name: 'Liechtenstein', code: 'LI' },
  { name: 'Lituània', code: 'LT' },
  { name: 'Luxemburg', code: 'LU' },
  { name: 'Madagascar', code: 'MG' },
  { name: 'Malawi', code: 'MW' },
  { name: 'Malàisia', code: 'MY' },
  { name: 'Maldives', code: 'MV' },
  { name: 'Mali', code: 'ML' },
  { name: 'Malta', code: 'MT' },
  { name: 'Illes Marshall', code: 'MH' },
  { name: 'Mauritània', code: 'MR' },
  { name: 'Maurici', code: 'MU' },
  { name: 'Mèxic', code: 'MX' },
  { name: 'Micronèsia', code: 'FM' },
  { name: 'Moldàvia', code: 'MD' },
  { name: 'Mònaco', code: 'MC' },
  { name: 'Mongòlia', code: 'MN' },
  { name: 'Montenegro', code: 'ME' },
  { name: 'Marroc', code: 'MA' },
  { name: 'Moçambic', code: 'MZ' },
  { name: 'Myanmar', code: 'MM' },
  { name: 'Namíbia', code: 'NA' },
  { name: 'Nauru', code: 'NR' },
  { name: 'Nepal', code: 'NP' },
  { name: 'Països Baixos', code: 'NL' },
  { name: 'Nova Zelanda', code: 'NZ' },
  { name: 'Nicaragua', code: 'NI' },
  { name: 'Níger', code: 'NE' },
  { name: 'Nigèria', code: 'NG' },
  { name: 'Macedònia del Nord', code: 'MK' },
  { name: 'Noruega', code: 'NO' },
  { name: 'Oman', code: 'OM' },
  { name: 'Pakistan', code: 'PK' },
  { name: 'Palau', code: 'PW' },
  { name: 'Palestina', code: 'PS' },
  { name: 'Panamà', code: 'PA' },
  { name: 'Papua Nova Guinea', code: 'PG' },
  { name: 'Paraguai', code: 'PY' },
  { name: 'Perú', code: 'PE' },
  { name: 'Filipines', code: 'PH' },
  { name: 'Polònia', code: 'PL' },
  { name: 'Portugal', code: 'PT' },
  { name: 'Qatar', code: 'QA' },
  { name: 'Romania', code: 'RO' },
  { name: 'Rússia', code: 'RU' },
  { name: 'Rwanda', code: 'RW' },
  { name: 'Saint Kitts i Nevis', code: 'KN' },
  { name: 'Saint Lucia', code: 'LC' },
  { name: 'Saint Vincent i les Grenadines', code: 'VC' },
  { name: 'Samoa', code: 'WS' },
  { name: 'San Marino', code: 'SM' },
  { name: 'São Tomé i Príncipe', code: 'ST' },
  { name: 'Aràbia Saudita', code: 'SA' },
  { name: 'Senegal', code: 'SN' },
  { name: 'Sèrbia', code: 'RS' },
  { name: 'Seychelles', code: 'SC' },
  { name: 'Sierra Leone', code: 'SL' },
  { name: 'Singapur', code: 'SG' },
  { name: 'Eslovàquia', code: 'SK' },
  { name: 'Eslovènia', code: 'SI' },
  { name: 'Illes Salomó', code: 'SB' },
  { name: 'Somàlia', code: 'SO' },
  { name: 'Sud-àfrica', code: 'ZA' },
  { name: 'Sudan del Sud', code: 'SS' },
  { name: 'Espanya', code: 'ES' },
  { name: 'Sri Lanka', code: 'LK' },
  { name: 'Sudan', code: 'SD' },
  { name: 'Surinam', code: 'SR' },
  { name: 'Suècia', code: 'SE' },
  { name: 'Suïssa', code: 'CH' },
  { name: 'Síria', code: 'SY' },
  { name: 'Tadjikistan', code: 'TJ' },
  { name: 'Tanzània', code: 'TZ' },
  { name: 'Tailàndia', code: 'TH' },
  { name: 'Timor-Leste', code: 'TL' },
  { name: 'Togo', code: 'TG' },
  { name: 'Tonga', code: 'TO' },
  { name: 'Trinitat i Tobago', code: 'TT' },
  { name: 'Tunísia', code: 'TN' },
  { name: 'Turquia', code: 'TR' },
  { name: 'Turkmenistan', code: 'TM' },
  { name: 'Tuvalu', code: 'TV' },
  { name: 'Uganda', code: 'UG' },
  { name: 'Ucraïna', code: 'UA' },
  { name: 'Emirats Àrabs Units', code: 'AE' },
  { name: 'Regne Unit', code: 'GB' },
  { name: 'Estats Units', code: 'US' },
  { name: 'Uruguai', code: 'UY' },
  { name: 'Uzbekistan', code: 'UZ' },
  { name: 'Vanuatu', code: 'VU' },
  { name: 'Veneçuela', code: 'VE' },
  { name: 'Vietnam', code: 'VN' },
  { name: 'Iemen', code: 'YE' },
  { name: 'Zàmbia', code: 'ZM' },
  { name: 'Zimbàbue', code: 'ZW' },
];


export const languages = [
  { name: 'Anglès', code: 'en' },
  { name: 'Espanyol', code: 'es' },
  { name: 'Francès', code: 'fr' },
  { name: 'Alemany', code: 'de' },
  { name: 'Xinès', code: 'zh' },
  { name: 'Hindi', code: 'hi' },
  { name: 'Àrab', code: 'ar' },
  { name: 'Portuguès', code: 'pt' },
  { name: 'Rus', code: 'ru' },
  { name: 'Japonès', code: 'ja' },
  { name: 'Italià', code: 'it' },
  { name: 'Coreà', code: 'ko' },
  { name: 'Neerlandès', code: 'nl' },
  { name: 'Turc', code: 'tr' },
  { name: 'Suec', code: 'sv' },
  { name: 'Polonès', code: 'pl' },
  { name: 'Tailandès', code: 'th' },
  { name: 'Hebreu', code: 'he' },
  { name: 'Grec', code: 'el' },
  { name: 'Txec', code: 'cs' },
  { name: 'Hongarès', code: 'hu' },
  { name: 'Vietnamita', code: 'vi' },
  { name: 'Romanès', code: 'ro' },
  { name: 'Ucraïnès', code: 'uk' },
  { name: 'Bengalí', code: 'bn' },
  { name: 'Finlandès', code: 'fi' },
  { name: 'Noruec', code: 'no' },
  { name: 'Danès', code: 'da' },
  { name: 'Suahili', code: 'sw' },
  { name: 'Malai', code: 'ms' },
  { name: 'Indonesi', code: 'id' },
  { name: 'Tagal', code: 'tl' },
  { name: 'Uzbek', code: 'uz' },
  { name: 'Serbi', code: 'sr' },
  { name: 'Croat', code: 'hr' },
  { name: 'Búlgar', code: 'bg' },
  { name: 'Eslovac', code: 'sk' },
  { name: 'Eslovè', code: 'sl' },
  { name: 'Letó', code: 'lv' },
  { name: 'Lituà', code: 'lt' },
  { name: 'Estonià', code: 'et' },
  { name: 'Georgià', code: 'ka' },
  { name: 'Armeni', code: 'hy' },
  { name: 'Macedoni', code: 'mk' },
  { name: 'Basc', code: 'eu' },
  { name: 'Català', code: 'ca' },
  { name: 'Gal·lès', code: 'cy' },
  { name: 'Irlandès', code: 'ga' },
  { name: 'Albanès', code: 'sq' },
  { name: 'Islandès', code: 'is' },
  { name: 'Malgaix', code: 'mg' },
  { name: 'Maltès', code: 'mt' },
  { name: 'Panjabi', code: 'pa' },
  { name: 'Gujarati', code: 'gu' },
  { name: 'Tàmil', code: 'ta' },
  { name: 'Tèluq', code: 'te' },
  { name: 'Kannada', code: 'kn' },
  { name: 'Marathi', code: 'mr' },
  { name: 'Singalès', code: 'si' },
  { name: 'Nepalès', code: 'ne' },
  { name: 'Khmer', code: 'km' },
  { name: 'Lao', code: 'lo' },
  { name: 'Birmà', code: 'my' },
  { name: 'Paixtu', code: 'ps' },
  { name: 'Persa', code: 'fa' },
  { name: 'Somali', code: 'so' },
  { name: 'Crioll Haitiano', code: 'ht' },
  { name: 'Mongol', code: 'mn' },
  { name: 'Quechua', code: 'qu' },
  { name: 'Xhosa', code: 'xh' },
  { name: 'Zulu', code: 'zu' }
];

export const genres = [
  { name: 'Acció', code: 28 },
  { name: 'Aventura', code: 12 },
  { name: 'Animació', code: 16 },
  { name: 'Comèdia', code: 35 },
  { name: 'Crim', code: 80 },
  { name: 'Documental', code: 99 },
  { name: 'Drama', code: 18 },
  { name: 'Familiar', code: 10751 },
  { name: 'Fantasia', code: 14 },
  { name: 'Història', code: 36 },
  { name: 'Terror', code: 27 },
  { name: 'Música', code: 10402 },
  { name: 'Misteri', code: 9648 },
  { name: 'Romàntic', code: 10749 },
  { name: 'Ciència-ficció', code: 878 },
  { name: 'Pel·lícula de TV', code: 10770 },
  { name: 'Suspens', code: 53 },
  { name: 'Guerra', code: 10752 },
  { name: 'Oest', code: 37 }
];