import subprocess
import time
import os
import csv

# List of scales in GB
scales = [1, 3, 5, 7]

# List to store loading times and errors
loading_results = []

# Path to your TPC-DS schema file
tpcds_schema = "tpcds.sql"

# Output CSV file to write the results
csv_file = "data_loading_times.csv"

# Loop over each scale
for scale in scales:
    data_dir = f"{scale}GB"
    db_name = f"datawarehouse{scale}.db"

    print(f"\nProcessing scale {scale}GB")

    # Remove extra '|' from each .dat file in data_dir
    print(f"Cleaning data files in {data_dir}...")
    for file_name in os.listdir(data_dir):
        if file_name.endswith('.dat'):
            file_path = os.path.join(data_dir, file_name)
            temp_file_path = file_path + '.tmp'

            # Remove extra '|' at the end of each line
            with open(file_path, 'r', encoding='latin1') as f_in, open(temp_file_path, 'w', encoding='latin1') as f_out:
                for line in f_in:
                    line = line.rstrip('\n')
                    if line.endswith('|'):
                        line = line[:-1]
                    f_out.write(line + '\n')
            # Replace original file with cleaned file
            os.replace(temp_file_path, file_path)

    # Create the database and tables
    print(f"Creating database {db_name} and tables...")
    create_db_cmd = f"sqlite3 {db_name} < {tpcds_schema}"
    subprocess.run(create_db_cmd, shell=True)

    # Prepare the import commands
    import_commands = ".mode csv\n.separator '|'\n"
    for file_name in os.listdir(data_dir):
        if file_name.endswith('.dat'):
            file_path = os.path.join(data_dir, file_name)
            table_name = os.path.basename(file_name).replace('.dat', '')
            import_commands += f".import '{file_path}' {table_name}\n"

    # Time the data loading step
    print(f"Starting data load for scale {scale}GB...")
    start_time = time.time()

    # Execute the import commands via stdin
    process = subprocess.Popen(['sqlite3', db_name], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, stderr = process.communicate(input=import_commands)

    end_time = time.time()
    time_taken = end_time - start_time

    if process.returncode != 0:
        print(f"Error importing data for scale {scale}GB:")
        print(stderr)
        error_msg = stderr.strip()
    else:
        print(f"Data import completed for scale {scale}GB")
        error_msg = ""

    print(f"Time taken to load data for scale {scale}GB: {time_taken:.2f} seconds\n")

    # Append the result to the list
    loading_results.append({
        'ScaleGB': scale,
        'TimeTakenSeconds': time_taken,
        'Error': error_msg
    })

# Write the loading times to a CSV file
with open(csv_file, 'w', newline='') as csvfile:
    fieldnames = ['ScaleGB', 'TimeTakenSeconds', 'Error']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    for result in loading_results:
        writer.writerow(result)

print("Data loading times have been written to", csv_file)
