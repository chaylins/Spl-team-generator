-- Table: public.spl_cards

-- DROP TABLE IF EXISTS public.spl_cards;

CREATE TABLE IF NOT EXISTS public.spl_cards
(
    card_id integer NOT NULL,
    name text COLLATE pg_catalog."default",
    type text COLLATE pg_catalog."default",
    color text COLLATE pg_catalog."default",
    owned boolean,
    mana integer,
    CONSTRAINT spl_cards_pkey PRIMARY KEY (card_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.spl_cards
    OWNER to postgres;