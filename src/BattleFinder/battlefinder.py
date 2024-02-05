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


def battle_found():
     response = requests.get('https://api.splinterlands.com/battle/battle_queue?username=wanfortheboyz', headers={'accept': 'application/json'})
     json_response = json.loads(response.text)

     if len(json_response) > 0:
          return True
     
     return False

def main():
     update_card_collection()

     while True:
          if battle_found():
               pass
          else:
               print('No battle found, sleeping...')
               time.sleep(100)

if __name__ == "__main__":
    main()