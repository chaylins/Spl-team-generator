-- Table: public.team_cards

-- DROP TABLE IF EXISTS public.team_cards;

CREATE TABLE IF NOT EXISTS public.team_cards
(
    card_id bigint,
    team_id text COLLATE pg_catalog."default",
    card_position integer
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.team_cards
    OWNER to postgres;