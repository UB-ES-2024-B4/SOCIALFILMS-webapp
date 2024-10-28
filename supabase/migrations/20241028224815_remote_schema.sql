SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";
COMMENT ON SCHEMA "public" IS 'standard public schema';
CREATE EXTENSION IF NOT EXISTS "http" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";
CREATE TYPE "public"."Reactions" AS ENUM (
    'Like',
    'Dislike'
);
ALTER TYPE "public"."Reactions" OWNER TO "postgres";
COMMENT ON TYPE "public"."Reactions" IS 'Reacciones';
SET default_tablespace = '';
SET default_table_access_method = "heap";
CREATE TABLE IF NOT EXISTS "public"."Movies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" character varying NOT NULL,
    "description" character varying NOT NULL,
    "release_year" integer NOT NULL,
    "director" character varying NOT NULL
);
ALTER TABLE "public"."Movies" OWNER TO "postgres";
COMMENT ON TABLE "public"."Movies" IS 'Peliculas';
CREATE TABLE IF NOT EXISTS "public"."Review-Reactions" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "review_id" "uuid" NOT NULL,
    "reaction" "public"."Reactions" NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);
ALTER TABLE "public"."Review-Reactions" OWNER TO "postgres";
COMMENT ON TABLE "public"."Review-Reactions" IS 'Reacciones de usuarios a reseñas';
CREATE TABLE IF NOT EXISTS "public"."Reviews" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "movie_id" "uuid" NOT NULL,
    "rating" integer NOT NULL,
    "comment" character varying,
    "likes" integer DEFAULT 0 NOT NULL,
    "dislikes" integer DEFAULT 0 NOT NULL,
    "shared_count" integer DEFAULT 0 NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);
ALTER TABLE "public"."Reviews" OWNER TO "postgres";
COMMENT ON TABLE "public"."Reviews" IS 'Reseñas';
ALTER TABLE ONLY "public"."Movies"
    ADD CONSTRAINT "Movies_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."Review-Reactions"
    ADD CONSTRAINT "Review-Reactions_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."Reviews"
    ADD CONSTRAINT "Reviews_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."Review-Reactions"
    ADD CONSTRAINT "unique_user_review" UNIQUE ("user_id", "review_id");
ALTER TABLE ONLY "public"."Review-Reactions"
    ADD CONSTRAINT "Review-Reactions_review_id_fkey" FOREIGN KEY ("review_id") REFERENCES "public"."Reviews"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."Review-Reactions"
    ADD CONSTRAINT "Review-Reactions_user_id_fkey1" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."Reviews"
    ADD CONSTRAINT "Reviews_movie_id_fkey" FOREIGN KEY ("movie_id") REFERENCES "public"."Movies"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."Reviews"
    ADD CONSTRAINT "Reviews_user_id_fkey1" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
CREATE POLICY "Administradores pueden actualizar peliculas" ON "public"."Movies" FOR UPDATE USING (("auth"."role"() = 'admin'::"text"));
CREATE POLICY "Administradores pueden añadir peliculas" ON "public"."Movies" FOR INSERT TO "authenticated" WITH CHECK (("auth"."role"() = 'admin'::"text"));
CREATE POLICY "Administradores pueden eliminar peliculas" ON "public"."Movies" FOR DELETE USING (("auth"."role"() = 'admin'::"text"));
CREATE POLICY "Administradores pueden eliminar reseñas" ON "public"."Reviews" FOR DELETE USING (("auth"."role"() = 'admin'::"text"));
ALTER TABLE "public"."Movies" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."Review-Reactions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."Reviews" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios pueden actualizar sus propias reseñas" ON "public"."Reviews" FOR UPDATE USING (("user_id" = "auth"."uid"()));
CREATE POLICY "Usuarios pueden crear reseñas" ON "public"."Reviews" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "auth"."uid"()));
CREATE POLICY "Usuarios pueden eliminar sus propias reseñas" ON "public"."Reviews" FOR DELETE USING (("user_id" = "auth"."uid"()));
CREATE POLICY "Usuarios pueden insertar una reaccion" ON "public"."Review-Reactions" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "auth"."uid"()));
ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT ALL ON TABLE "public"."Movies" TO "anon";
GRANT ALL ON TABLE "public"."Movies" TO "authenticated";
GRANT ALL ON TABLE "public"."Movies" TO "service_role";
GRANT ALL ON TABLE "public"."Review-Reactions" TO "anon";
GRANT ALL ON TABLE "public"."Review-Reactions" TO "authenticated";
GRANT ALL ON TABLE "public"."Review-Reactions" TO "service_role";
GRANT ALL ON TABLE "public"."Reviews" TO "anon";
GRANT ALL ON TABLE "public"."Reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."Reviews" TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";
RESET ALL;
