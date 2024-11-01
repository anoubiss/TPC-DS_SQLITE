import os
import random
import sqlite3
import time
from multiprocessing import Process, Manager
from concurrent.futures import ThreadPoolExecutor, as_completed

# Configuration
queries_dir = 'mytask'  # Directory containing the .sql files with the queries


def progress_handler(start_time, timeout_seconds):
    """
    Progress handler to check for query timeout.
    """
    elapsed_time = time.time() - start_time
    if elapsed_time > timeout_seconds:
        return 1  # Abort query by returning a non-zero value
    return 0  # Continue execution


def execute_query(db_path, query_file, timeout_seconds, client_id):
    """
    Execute a single query with a timeout using SQLite's progress handler.
    """
    start_time = time.time()
    connection = sqlite3.connect(db_path)
    cursor = connection.cursor()

    # Set progress handler with a frequency
    connection.set_progress_handler(lambda: progress_handler(start_time, timeout_seconds), 1000)

    try:
        with open(os.path.join(queries_dir, query_file), 'r') as file:
            query = file.read()

        cursor.executescript(query)
        connection.commit()
        status = 'success'
    except sqlite3.OperationalError as e:
        status = 'timeout' if 'interrupted' in str(e).lower() else f'error: {e}'
    except sqlite3.Error as e:
        status = f'error: {e}'
    except Exception as e:
        status = f'error: {e}'
    finally:
        cursor.close()
        connection.close()

    execution_time = min(time.time() - start_time, timeout_seconds)

    if status == 'timeout':
        print(f"Client {client_id}, {query_file}: Execution time = {execution_time:.2f} seconds (timeout)")
    elif status == 'success':
        print(f"Client {client_id}, {query_file}: Execution time = {execution_time:.2f} seconds")
    else:
        print(f"Client {client_id}, {query_file}: Error during execution: {status}")

    return (client_id, query_file, status, execution_time)


def execute_client_queries(db_path, queries, timeout_seconds, client_id, result_queue):
    """
    Execute queries for a single client using threading.
    """
    args_list = [(db_path, query_file, timeout_seconds, client_id) for query_file in queries]

    with ThreadPoolExecutor() as executor:
        futures = [executor.submit(execute_query, *args) for args in args_list]
        for future in as_completed(futures):
            result = future.result()
            result_queue.put(result)


def throughput_test(db_path, nb_clients, timeout_seconds, output_file):
    """
    Execute the throughput test with multiple clients.
    """
    # Load the queries
    queries = [f for f in os.listdir(queries_dir) if f.endswith('.sql')]
    print(f"Loaded {len(queries)} queries for the throughput test.")

    manager = Manager()
    result_queue = manager.Queue()
    client_processes = []
    start_time = time.time()  # Start timing

    # Start client processes
    for client_id in range(nb_clients):
        client_queries = queries.copy()
        random.shuffle(client_queries)
        client_process = Process(target=execute_client_queries,
                                 args=(db_path, client_queries, timeout_seconds, client_id, result_queue))
        client_processes.append(client_process)
        client_process.start()
        print(f"Started client {client_id}.")

    # Wait for all client processes to finish
    for client_process in client_processes:
        client_process.join()
        print(f"Client process {client_process.pid} has finished.")

    duration = time.time() - start_time  # End timing
    print(f"Total throughput test duration: {duration:.2f} seconds.")

    # Collect results
    results = []
    while not result_queue.empty():
        results.append(result_queue.get())

    # Write the throughput test duration and individual query results to the output file
    with open(output_file, 'w') as out_file:
        out_file.write(f"Total duration: {duration:.2f} seconds\n")
        out_file.write("ClientID,QueryFile,Status,ExecutionTime\n")
        for client_id, query_file, status, exec_time in results:
            out_file.write(f"{client_id},{query_file},{status},{exec_time}\n")
    print(f"Results written to {output_file}")


if __name__ == '__main__':
    # List of data warehouse databases
    datawarehouses = [
        'datawarehouse1.db',
        'datawarehouse3.db',
        'datawarehouse5.db',
        'datawarehouse7.db'
    ]

    # Number of clients for each data warehouse
    nb_clients_list = [4, 4, 4, 4]

    # Timeout per query in seconds
    timeout_seconds_list = [180, 300, 420, 540]

    # Output files for each data warehouse
    output_files = [
        'throughput_scale_1.txt',
        'throughput_scale_3.txt',
        'throughput_scale_5.txt',
        'throughput_scale_7.txt'
    ]

    for db_path, nb_clients, timeout_seconds, output_file in zip(datawarehouses, nb_clients_list, timeout_seconds_list,
                                                                 output_files):
        print(
            f"\nRunning throughput test on {db_path} with {nb_clients} clients and timeout {timeout_seconds} seconds per query")
        throughput_test(db_path, nb_clients, timeout_seconds, output_file)
