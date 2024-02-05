-- PROCEDURE: public.sp_get_team_mana_count(text)

-- DROP PROCEDURE IF EXISTS public.sp_get_team_mana_count(text);

CREATE OR REPLACE PROCEDURE public.sp_get_team_mana_count(
	IN team_id text,
	OUT mana_count integer)
LANGUAGE 'sql'
AS $BODY$
SELECT SUM(MANA)
FROM SPL_CARDS
WHERE CAST(CARD_ID AS TEXT) = ANY(string_to_array(team_id, ','));
$BODY$;
ALTER PROCEDURE public.sp_get_team_mana_count(text)
    OWNER TO postgres;
