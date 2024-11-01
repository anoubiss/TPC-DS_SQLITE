import os
import sqlite3
import time
from multiprocessing import Process, Queue

# Configuration
queries_dir = 'queries'  # Directory containing the .sql files with the 99 queries

def run_query(db_path, query, result_queue):
    """
    Function to run a query in a separate process.
    """
    connection = sqlite3.connect(db_path)
    cursor = connection.cursor()
    try:
        start_time = time.time()  # Start timing immediately before query execution
        cursor.executescript(query)
        connection.commit()
        end_time = time.time()    # End timing immediately after query execution
        status = 'success'
    except sqlite3.Error as e:
        end_time = time.time()    # Ensure end_time is recorded even if an error occurs
        status = f'error: {e}'
    except Exception as e:
        end_time = time.time()
        status = f'error: {e}'
    finally:
        cursor.close()
        connection.close()
    execution_time = end_time - start_time
    result_queue.put((status, execution_time))

def power_test(db_path, timeout_seconds, output_file):
    queries = [f for f in os.listdir(queries_dir) if f.endswith('.sql')]
    queries.sort()  # Optional: sort the queries to run them in order

    with open(output_file, 'w') as out_file:
        for query_file in queries:
            with open(os.path.join(queries_dir, query_file), 'r') as file:
                query = file.read()

            result_queue = Queue()
            process = Process(target=run_query, args=(db_path, query, result_queue))
            process.start()
            process.join(timeout=timeout_seconds)
            if process.is_alive():
                process.terminate()
                process.join()
                # If query times out, write the timeout as the execution time
                status = 'timeout'
                execution_time = timeout_seconds
                message = f"{query_file}: Execution time = {execution_time} seconds (timeout)"
                print(message)
                # Write only the query filename and execution time to the file
                out_file.write(f"{query_file},{execution_time}\n")
            else:
                if not result_queue.empty():
                    status, execution_time = result_queue.get()
                    if status == 'success':
                        message = f"{query_file}: Execution time = {execution_time:.2f} seconds"
                        print(message)
                        out_file.write(f"{query_file},{execution_time:.2f}\n")
                    else:
                        message = f"{query_file}: Error during execution: {status}"
                        print(message)
                        # Write the query filename and execution time (as 0) to the file
                        out_file.write(f"{query_file},0\n")
                else:
                    message = f"{query_file}: No result returned."
                    print(message)
                    # Write the query filename and execution time (as 0) to the file
                    out_file.write(f"{query_file},0\n")

# Run the Power Test
if __name__ == '__main__':
    datawarehouses = [
        'datawarehouse1.db',
        'datawarehouse3.db',
        'datawarehouse5.db',
        'datawarehouse7.db'
    ]  # List of your data warehouse databases

    timeouts = [180, 300, 420, 540]  # Timeouts in seconds: 3, 5, 7, 9 minutes
    output_files = [
        'results_scale_1.txt',
        'results_scale_3.txt',
        'results_scale_5.txt',
        'results_scale_7.txt'
    ]  # Output files for each data warehouse

    for db_path, timeout_seconds, output_file in zip(datawarehouses, timeouts, output_files):
        print(f"\nRunning power test on {db_path} with timeout {timeout_seconds} seconds")
        power_test(db_path, timeout_seconds, output_file)
        print(f"Results written to {output_file}")
