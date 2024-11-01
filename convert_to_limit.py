import os
import re


def convert_top_to_limit(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        sql_content = file.read()

    # Regular expression pattern to find SELECT TOP N
    pattern = re.compile(r'(SELECT\s+(?:DISTINCT\s+)?)(TOP\s+(\d+))(.*?)(FROM\s+)', re.IGNORECASE | re.DOTALL)

    # Find all matches in the SQL content
    matches = pattern.findall(sql_content)
    if matches:
        print(f"Processing file: {file_path}")

        # Function to replace TOP N with nothing and store N
        def replace_top(match):
            select_clause = match.group(1)
            top_n = match.group(3)
            rest = match.group(4)
            from_clause = match.group(5)
            # Store N to add LIMIT N later
            nonlocal limit_n
            limit_n = top_n
            return f"{select_clause}{rest}{from_clause}"

        # Initialize limit_n
        limit_n = None

        # Remove TOP N from SELECT clause
        sql_content = pattern.sub(replace_top, sql_content)

        # Add LIMIT N at the end of each query
        # This regex finds the end of the query (assuming it ends with a semicolon)
        sql_content = re.sub(r';\s*(--.*)?\n', lambda m: f' LIMIT {limit_n};{m.group(1) if m.group(1) else ""}\n',
                             sql_content, flags=re.IGNORECASE)
        sql_content = re.sub(r';\s*$', f' LIMIT {limit_n};', sql_content, flags=re.IGNORECASE)

        # Write the modified content back to the file
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(sql_content)
    else:
        print(f"No TOP clause found in file: {file_path}")


def process_directory(directory_path):
    for filename in os.listdir(directory_path):
        if filename.endswith('.sql'):
            file_path = os.path.join(directory_path, filename)
            convert_top_to_limit(file_path)


if __name__ == "__main__":
    # Replace with the path to your SQL query files
    directory_path = '/mnt/d/ULB/419/TPC-DS_SQLITE/query'
    process_directory(directory_path)
