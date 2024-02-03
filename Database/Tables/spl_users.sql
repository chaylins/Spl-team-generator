-- Table: public.spl_users

-- DROP TABLE IF EXISTS public.spl_users;

CREATE TABLE IF NOT EXISTS public.spl_users
(
    player_name text COLLATE pg_catalog."default" NOT NULL,
    checked_timestamp timestamp without time zone,
    CONSTRAINT spl_users_pkey PRIMARY KEY (player_name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.spl_users
    OWNER to postgres;