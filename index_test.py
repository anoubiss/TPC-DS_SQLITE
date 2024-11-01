import os
import sqlite3
import time
from multiprocessing import Process, Queue
import matplotlib.pyplot as plt

# Configuration
queries_dir = 'query'
index_file = 'create_index.sql'  # SQL file containing index creation statements
drop_index_file = 'drop_index.sql'  # SQL file containing index drop statements


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
        end_time = time.time()  # End timing immediately after query execution
        status = 'success'
    except sqlite3.Error as e:
        end_time = time.time()  # Ensure end_time is recorded even if an error occurs
        status = f'error: {e}'
    finally:
        cursor.close()
        connection.close()
    execution_time = end_time - start_time
    result_queue.put((status, execution_time))


def execute_script(connection, script_path):
    with open(script_path, 'r') as file:
        script = file.read()
    cursor = connection.cursor()
    cursor.executescript(script)
    cursor.close()


def plot_results(no_index_times, index_times):
    query_files = list(no_index_times.keys())
    no_index_vals = [no_index_times[q] for q in query_files]
    index_vals = [index_times[q] for q in query_files]

    # Plot without index
    plt.figure(figsize=(10, 6))
    plt.barh(query_files, no_index_vals, color='skyblue')
    plt.xlabel("Execution Time (s)")
    plt.title("Execution Time of Queries Without Indexes")
    plt.gca().invert_yaxis()  # Invert y-axis for better readability
    plt.tight_layout()
    plt.show()

    # Plot with index
    plt.figure(figsize=(10, 6))
    plt.barh(query_files, index_vals, color='salmon')
    plt.xlabel("Execution Time (s)")
    plt.title("Execution Time of Queries With Indexes")
    plt.gca().invert_yaxis()  # Invert y-axis for better readability
    plt.tight_layout()
    plt.show()


def index_test(db_path, timeout_seconds, output_file):
    queries = [f for f in os.listdir(queries_dir) if f.endswith('.sql')]
    queries.sort()  # Optional: sort the queries to run them in order

    # Step 1: Execute queries without indexes
    no_index_times = {}
    with open(output_file, 'w') as out_file:
        out_file.write("Query,Without Index,With Index\n")

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
                status = 'timeout'
                execution_time = timeout_seconds
                print(f"{query_file}: Execution time without index = {execution_time} seconds (timeout)")
                no_index_times[query_file] = execution_time
            else:
                if not result_queue.empty():
                    status, execution_time = result_queue.get()
                    print(f"{query_file}: Execution time without index = {execution_time:.2f} seconds")
                    no_index_times[query_file] = execution_time
                else:
                    print(f"{query_file}: No result returned.")
                    no_index_times[query_file] = 0

        # Step 2: Apply indexes
        connection = sqlite3.connect(db_path)
        execute_script(connection, index_file)
        connection.commit()
        connection.close()

        # Step 3: Execute queries with indexes
        index_times = {}
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
                status = 'timeout'
                execution_time = timeout_seconds
                print(f"{query_file}: Execution time with index = {execution_time} seconds (timeout)")
                index_times[query_file] = execution_time
            else:
                if not result_queue.empty():
                    status, execution_time = result_queue.get()
                    print(f"{query_file}: Execution time with index = {execution_time:.2f} seconds")
                    index_times[query_file] = execution_time
                else:
                    print(f"{query_file}: No result returned.")
                    index_times[query_file] = 0

            # Write comparison to output file
            out_file.write(f"{query_file},{no_index_times[query_file]},{index_times[query_file]}\n")

        # Step 4: Drop indexes after test
        connection = sqlite3.connect(db_path)
        execute_script(connection, drop_index_file)
        connection.commit()
        connection.close()

    # Plot results
    plot_results(no_index_times, index_times)


# Run the Index Test
if __name__ == '__main__':
    db_path = 'datawarehouse.db'  # Specify the path to your database
    timeout_seconds = 180# Timeout in seconds for each query
    output_file = 'index_test_results.csv'  # Output file to store the results

    print(f"Running index test on {db_path} with timeout {timeout_seconds} seconds")
    index_test(db_path, timeout_seconds, output_file)
    print(f"Results written to {output_file}")
