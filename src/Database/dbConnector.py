import psycopg2
from psycopg2.extras import execute_batch

class Database(object):

    connection = None
    cursor = None

    def __init__(self):
        if Database.connection is None:
            try:
                Database.connection = psycopg2.connect(host='localhost', database='crawler_stats', user='postgres', password='Mcyi4ch2')
                Database.cursor = Database.connection.cursor()
            except Exception as error:
                print(f'Error: Connection not established {error}')
            else:
                print('Connection established')

        self.connection = Database.connection
        self.cursor = Database.cursor

    def execute_query(self, query, params = None):
        self.cursor.execute(query, params)

        self.connection.commit()
    
    def execute_select(self, query, params=None):
        self.cursor.execute(query, params)

        return self.cursor.fetchall()
    
    def execute_proc(self, proc_name, params=None):
        if params is not None:
            self.cursor.execute(f'CALL public.{proc_name}(\'{params[0]}\', null);')
            return self.cursor.fetchall()
        else:
            self.cursor.execute(f'CALL public.{proc_name}();')

        self.connection.commit()

        return

    def execute_batch(self, query, params):
        execute_batch(self.cursor, query, params)
        self.connection.commit()

        