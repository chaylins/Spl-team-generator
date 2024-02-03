-- Table: public.win_rates

-- DROP TABLE IF EXISTS public.win_rates;

CREATE TABLE IF NOT EXISTS public.win_rates
(
    team_id text COLLATE pg_catalog."default",
    color text COLLATE pg_catalog."default",
    ruleset text COLLATE pg_catalog."default",
    games_won bigint,
    games_lost bigint,
    CONSTRAINT key UNIQUE (team_id, color, ruleset)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.win_rates
    OWNER to postgres;