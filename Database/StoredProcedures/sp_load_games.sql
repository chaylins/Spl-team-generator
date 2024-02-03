-- PROCEDURE: public.sp_load_games(text)

-- DROP PROCEDURE IF EXISTS public.sp_load_games(text);

CREATE OR REPLACE PROCEDURE public.sp_load_games(
	IN player_name text)
LANGUAGE 'sql'
AS $BODY$
select 1
$BODY$;
ALTER PROCEDURE public.sp_load_games(text)
    OWNER TO postgres;
