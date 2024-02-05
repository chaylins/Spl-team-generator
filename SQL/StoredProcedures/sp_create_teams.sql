-- PROCEDURE: public.sp_create_teams()

-- DROP PROCEDURE IF EXISTS public.sp_create_teams();

CREATE OR REPLACE PROCEDURE public.sp_create_teams(
	)
LANGUAGE 'sql'
AS $BODY$
-- Create teams
INSERT INTO TEAMS (TEAM_ID, COLOR, MANA_COST)
SELECT tmp.PLAYER_TEAM, tmp.PLAYER_COLOUR, tmp.TEAM_MANA
FROM (
SELECT PLAYER_1_TEAM AS PLAYER_TEAM,
		PLAYER_1_COLOUR AS PLAYER_COLOUR,
		SUM(spl_cards.mana) AS TEAM_MANA
FROM
	(SELECT PLAYER_1_TEAM,
	 		PLAYER_1_COLOUR,
 			unnest(string_to_array(PLAYER_1_TEAM, ',')) AS "card_id"--
		FROM spl_games) as split_ids
INNER JOIN spl_cards on spl_cards.card_id = CAST(split_ids.card_id AS integer)
GROUP BY PLAYER_1_TEAM, PLAYER_1_COLOUR
UNION ALL
SELECT PLAYER_2_TEAM AS PLAYER_TEAM,
		PLAYER_2_COLOUR AS PLAYER_COLOUR,
		SUM(spl_cards.mana) AS TEAM_MANA
FROM
	(SELECT PLAYER_2_TEAM,
	 		PLAYER_2_COLOUR,
 			unnest(string_to_array(PLAYER_2_TEAM, ',')) AS "card_id"--
		FROM spl_games) as split_ids
INNER JOIN spl_cards on spl_cards.card_id = CAST(split_ids.card_id AS integer)
GROUP BY PLAYER_2_TEAM, PLAYER_2_COLOUR) as tmp
GROUP BY tmp.PLAYER_TEAM, tmp.PLAYER_COLOUR, tmp.TEAM_MANA
ORDER BY 1
ON CONFLICT DO NOTHING;

-- Create teams_cards
INSERT INTO TEAM_CARDS (TEAM_ID, CARD_ID, CARD_POSITION)
SELECT PLAYER_TEAM,
		CARD_ID,
		CARD_POSITION
FROM(
	SELECT PLAYER_1_TEAM AS PLAYER_TEAM,
			CARD_ID,
			array_position(string_to_array(PLAYER_1_TEAM, ','), CAST(CARD_ID AS TEXT)) AS CARD_POSITION
		FROM (
			SELECT PLAYER_1_TEAM,
				CAST(unnest(string_to_array(PLAYER_1_TEAM, ',')) as INTEGER) AS "card_id"
			FROM SPL_GAMES)
	UNION ALL
	SELECT PLAYER_2_TEAM AS PLAYER_TEAM,
		CARD_ID,
		array_position(string_to_array(PLAYER_2_TEAM, ','), CAST(CARD_ID AS TEXT)) AS CARD_POSITION
		FROM (
			SELECT PLAYER_2_TEAM,
				CAST(unnest(string_to_array(PLAYER_2_TEAM, ',')) as INTEGER) AS "card_id"
			FROM SPL_GAMES))
WHERE PLAYER_TEAM NOT IN (SELECT TEAM_ID FROM TEAM_CARDS GROUP BY 1)
GROUP BY PLAYER_TEAM, CARD_ID, CARD_POSITION;
$BODY$;
ALTER PROCEDURE public.sp_create_teams()
    OWNER TO postgres;
