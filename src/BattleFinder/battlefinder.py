import src.Database.dbConnector as dbConnector
import json
import requests
import time

dbc = dbConnector.Database()

def update_card_collection():
    print('Updating card collection first...')
    response = requests.get('https://api.splinterlands.com/cards/collection/wanfortheboyz', headers={'accept': 'application/json'})
    json_response = json.loads(response.text)

    for item in json_response['cards']:
        params = [ int(item['card_detail_id']) ]
        dbc.execute_query(" UPDATE public.spl_cards SET owned=true where card_id = %s ;", params)

    print('Card collection updated')

def CalculateTeams():
    available_cards = dbc.execute_query("SELECT CARD_ID FROM publicSPL_CARDS WHERE OWNED=True ; ")

    possible_teams = dbc.execute_query("SELECT TEAM_ID, (GAMES_WON)/(GAMES_WON + GAMES_LOST) * 100 AS WIN_RATE FROM WIN_RATES")


def main():
     update_card_collection()

     rules_list = ['Standard']
     inactive_list = ['Black']
     mana_cap = 40

     # possible_teams = CalculateTeams()

if __name__ == "__main__":
    main()