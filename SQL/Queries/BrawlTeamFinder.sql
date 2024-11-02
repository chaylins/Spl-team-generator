SELECT *
FROM
	(SELECT wr.TEAM_ID,
		wr.color,
		wr.ruleset,
		(wr.games_won::decimal) / (games_won::decimal + games_lost::decimal) * 100 AS WIN_RATE,
	 	t.MANA_COST,
		tc.CARD_ID,
		tc.CARD_POSITION,
		c.NAME,
	 	wr.GAMES_WON
FROM WIN_RATES wr
INNER JOIN TEAM_CARDS tc ON tc.TEAM_ID = wr.TEAM_ID
INNER JOIN SPL_CARDS c ON c.CARD_ID = tc.CARD_ID
INNER JOIN TEAMS t on t.TEAM_ID = tc.TEAM_ID
LEFT OUTER JOIN
	(SELECT TEAM_ID
	FROM TEAM_CARDS tc1
	INNER JOIN SPL_CARDS c1 ON c1.CARD_ID = tc1.CARD_ID
	WHERE c1.OWNED = false) anti_join ON anti_join.TEAM_ID = tc.TEAM_ID
WHERE WR.GAMES_WON > 1
AND anti_join.TEAM_ID IS NULL) final_table
WHERE MANA_COST < 53
AND RULESET LIKE '%League%'
--AND RULESET LIKE '%Entertained%'
AND RULESET LIKE '%Counterspell%'
ORDER BY MANA_COST DESC, final_table.WIN_RATE DESC, final_table.TEAM_ID, final_table.CARD_POSITION
