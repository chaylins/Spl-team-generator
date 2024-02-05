-- Table: public.spl_games

-- DROP TABLE IF EXISTS public.spl_games;

CREATE TABLE IF NOT EXISTS public.spl_games
(
    battle_queue_id_1 text COLLATE pg_catalog."default" NOT NULL,
    battle_queue_id_2 text COLLATE pg_catalog."default" NOT NULL,
    player_1_name text COLLATE pg_catalog."default",
    player_2_name text COLLATE pg_catalog."default",
    player_1_colour text COLLATE pg_catalog."default",
    player_2_colour text COLLATE pg_catalog."default",
    winner text COLLATE pg_catalog."default",
    ruleset text COLLATE pg_catalog."default",
    inactive text COLLATE pg_catalog."default",
    match_date text COLLATE pg_catalog."default",
    mana_cap integer,
    player_1_team text COLLATE pg_catalog."default",
    player_2_team text COLLATE pg_catalog."default",
    CONSTRAINT spl_games_pkey PRIMARY KEY (battle_queue_id_1, battle_queue_id_2)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.spl_games
    OWNER to postgres;