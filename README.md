
# TPC-DS Benchmarking Project

This project is designed to facilitate the execution and analysis of TPC-DS benchmarks using SQLite, providing tools to run power and throughput tests and generate visual insights from the results.

## Project Structure
- **`queries/`**: Contains SQL query files used for the power and throughput tests.
- **`results/`**: Stores the output results of various test runs.
- **`convert_to_limit.py`**: Script to convert queries by adding `LIMIT` clauses for testing.
- **`load_test.py`**: Script for loading data into the SQLite database.
- **`plots.ipynb`**: Jupyter notebook for generating plots and visualizations.
- **`power_test.py`**: Script to run the TPC-DS Power Test.
- **`throughput_test.py`**: Script to run the TPC-DS Throughput Test with concurrent queries.
- **`README.md`**: This file, with detailed instructions on running the project.
- **`tpcds.sql`**: SQL schema for creating TPC-DS tables in SQLite.

## Getting Started

### Prerequisites
Ensure you have the following software installed:
- **Python 3.x**
- **SQLite 3.x**
- **Jupyter Notebook** (for running `plots.ipynb` if needed)

### Installation
1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

### Generating and Loading Data

#### Generate TPC-DS Data
Use the `dsdgen` tool to create test data.
```bash
./dsdgen -scale <scale-factor> -dir <output-directory>
```
- Replace `<scale-factor>` with the desired data scale (e.g., 1, 3, 5, 7 GB).

#### Load Data into SQLite
Load the generated `.dat` files into SQLite using the `load_test.py` script:
```bash
python load_test.py
```
- This script reads the `.dat` files from your specified directory, processes them, and loads the data into SQLite databases. Loading times are logged in the `results/` directory.

## Running the Tests

### Power Test
Run the Power Test to execute all 99 queries sequentially:
```bash
python power_test.py
```
- This script records the execution time for each query and saves the results to `results/power_test_<scale>.txt`.

### Throughput Test
Run the Throughput Test to simulate a high-load environment with concurrent query execution:
```bash
python throughput_test.py
```
- This script initiates multiple clients, each executing queries concurrently, and logs the total execution time for each test in `results/throughput_test_<scale>.txt`.

## Visualizing the Results
To analyze the test results and generate visual plots:

1. Open `plots.ipynb` in Jupyter Notebook:
   ```bash
   jupyter notebook plots.ipynb
   ```
2. Run the cells to create visual representations of the data, such as total execution time comparisons between the power and throughput tests.

