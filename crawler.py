import time
import psycopg2

import requests
import json
import dbConnector
import queue
import threading
from datetime import datetime, timezone

dbc = dbConnector.Database()
data_lock = threading.Lock()
params_list = list()
processed_users = list()


def prepare_database():

    prepare_db = True

    if prepare_db:
        response = requests.get('https://api.splinterlands.com/players/leaderboard?format=modern', headers={'accept': 'application/json'})
        json_response = json.loads(response.text)

        for item in json_response:
            dbc.execute_query(" INSERT INTO public.spl_users VALUES(%s, %s) ; ", [item['player'], '1900-01-01 00:00:00'])
        
        dbc.execute_query(" INSERT INTO public.SPL_USERS VALUES (%s, %s) ;", ['wanfortheboyz', '1900-01-01 00:00:00'])
        dbc.execute_query(" INSERT INTO public.SPL_USERS VALUES (%s, %s) ;", ['jmaan', '1900-01-01 00:00:00'])

        response = requests.get('https://api.splinterlands.com/cards/get_details', headers={'accept': 'application/json'})
        json_response = json.loads(response.text)
        
        for item in json_response:
            params = [ int(item['id']),
                            item['name'],
                            item['type'],
                            item['color'],
                            False,
                            item['stats']['mana'][0] if isinstance(item['stats']['mana'], list) else item['stats']['mana']
                    ]
            
            dbc.execute_query(" INSERT INTO public.spl_cards VALUES(%s, %s, %s, %s, %s, %s); ", params)


def getGameHistory(thread_id, work_queue):
    while True:
        user_name = work_queue.get()

        if user_name == 'shutdown':
            print(f'Shutdown notice received. Shutting down thread {thread_id}')
            return
        
        response = requests.get(f'https://api.splinterlands.com/battle/history2?player={user_name[0]}&limit=100', headers={'accept': 'application/json'})

        print(f'Thead: {thread_id} starting to process {user_name[0]}')

        try:
            json_response = json.loads(response.text)
        except json.JSONDecodeError:
            return

        if len(json_response['battles']) == 0:
            print(f'No battles found for user {user_name[0]}')
            continue

        if user_name[1] > datetime.strptime(json_response['battles'][0]['created_date'], '%Y-%m-%dT%H:%M:%S.%fZ'):
            battle_time = {json_response['battles'][0]['created_date']}
            print(f'user: {user_name[1]}, battle_time: {battle_time}')
            print(f'No new battles. Skipped user {user_name[0]}')
            continue

        try:
            print(f'New battle found for user: {user_name[0]}')
            for item in json_response['battles']:
                # Identify surrenders and draws and ignore
                try:
                    if item['details']['type'] == 'Surrender' or item['winner'] == 'DRAW':
                        continue
                except KeyError:
                    pass

                if user_name[1] > datetime.strptime(item['created_date'], '%Y-%m-%dT%H:%M:%S.%fZ'):
                    print(f'No more new battles. Skipped user {user_name[0]}')
                    continue

                params = (item['battle_queue_id_1'],
                        item['battle_queue_id_2'],
                        item['player_1'],
                        item['player_2'],
                        item['details']['team1']['color'],
                        item['details']['team2']['color'],
                        item['winner'],
                        item['ruleset'],
                        item['inactive'],
                        item['created_date'],
                        item['mana_cap'],
                        str(item['details']['team1']['summoner']['card_detail_id']) + ',' + ','.join(str(monsters['card_detail_id']) for monsters in item['details']['team1']['monsters']),
                        str(item['details']['team2']['summoner']['card_detail_id']) + ',' + ','.join(str(monsters['card_detail_id']) for monsters in item['details']['team2']['monsters']))

                with data_lock:
                    params_list.append(params)

        except KeyError:
            print('Limit hit, clear queue and stop scraping')
            with work_queue.mutex:
                work_queue.queue.clear()
                work_queue.all_tasks_done.notify_all()
                work_queue.unfinished_tasks = 0
            return
        else:
            with data_lock:
                processed_users.append(user_name[0])
        

        print(f'Thead: {thread_id} Finished processing {user_name}')
        work_queue.task_done()


def crawl_games():
    users = dbc.execute_select(" SELECT PLAYER_NAME, CHECKED_TIMESTAMP FROM SPL_USERS ORDER BY 2 DESC LIMIT 100 ;")

    thread_list = ["Thread-1", "Thread-2", "Thread-3", "Thread-4", "Thread-5", "Thread-6", "Thread-7", "Thread-8", "Thread-9"]
    workQueue = queue.Queue()
    threads = []
    threadID = 1

    # Create new threads
    for thread_name in thread_list:
        thread = threading.Thread(target=getGameHistory, args=(threadID, workQueue,))
        thread.setDaemon(True)
        thread.start()
        threads.append(thread)
        threadID += 1
    
    # Fill the queue
    for user in users:
        workQueue.put(user)
    
    while not workQueue.empty():
        pass

    for t in threads:
        workQueue.put("shutdown")

    # Wait for all threads to complete
    for t in threads:
        t.join()

    dbc.execute_batch(" INSERT INTO public.spl_games VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,%s, %s) ON CONFLICT DO NOTHING; ", params_list)


def update_user_processed_times():
    print(f'Users to update: {processed_users}')
    print('---Starting user update---')
    if len(processed_users) > 0:
         dbc.execute_query('UPDATE SPL_USERS SET CHECKED_TIMESTAMP = %s WHERE PLAYER_NAME IN %s', [datetime.now().strftime('%Y-%m-%d %H:%M:%S'), tuple(user for user in processed_users)])
    print('---Users updated---')

def process_teams():
    print('---Creating teams---')
    dbc.execute_proc('sp_create_teams')
    print('---Created new teams---')


def process_game_stats():
    print('---Processing new games---')
    dbc.execute_proc('sp_process_games')
    print('---Game stats processed---')


def finish_tasks():
    print('---Starting run cleanup---')
    dbc.execute_proc('sp_cleanup')
    print('---Cleanup done---')


def main():
    prepare_database()

    run_number = 1

    while True:
        print(f'Starting processing run: {run_number}')

        crawl_games()
        process_teams()
        process_game_stats()
        update_user_processed_times()
        finish_tasks()

        processed_users.clear()
        print('Finished processing. Sleeping 5 minutes now')
        run_number =+ 1
        time.sleep(720)


if __name__ == "__main__":
    main()