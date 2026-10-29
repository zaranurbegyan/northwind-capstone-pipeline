# Northwind Data Warehouse & Analytics Pipeline

A robust, student-friendly data warehouse and end-to-end ELT pipeline built using MySQL, Python, and Jupyter Notebooks based on the classic Northwind database.

## 🚀 Project Overview

This capstone project implements a modern dimensional data warehouse following a star schema design. It automates raw CSV data ingestion, handles idempotency via SQL upserts, and delivers analytical insights and formal statistical hypothesis testing on sales performance, customer concentration, and employee productivity.

## 📁 Repository Structure

```
northwind-capstone-pipeline/
│
├── .gitignore
├── README.md
├── requirements.txt
├── run_pipeline.py                 # Master pipeline entry-point script
│
├── data/
│   └── raw/                        # Raw CSV files (orders, customers, products, etc.)
│
├── sql/
│   ├── 01_create_db_and_schemas.sql    # DDL for database and staging/dw schemas
│   ├── 02_create_staging.sql           # DDL for 1:1 staging tables
│   ├── 03_create_warehouse.sql         # DDL for Star Schema & Date dimension generator
│   ├── 04_upsert_dimensions.sql        # Idempotent MERGE/UPSERT scripts for dimensions
│   └── 05_upsert_fact_sales.sql        # Idempotent MERGE/UPSERT script for fact table
│
├── src/
│   ├── __init__.py
│   ├── config.py                   # Database connection parameters & configuration
│   ├── db_connector.py             # Database engine wrapper & connection logic
│   ├── stage_raw_data.py           # Ingests raw CSVs 1:1 into the staging schema
│   └── transform_warehouse.py      # Executes idempotent SQL scripts for the DW schema
│
└── notebooks/
    └── statistical_analysis.ipynb  # EDA, data distributions, and hypothesis testing

```

## ⚙️ How to Run the Pipeline

1. **Clone the Repository & Install Dependencies:**

   ```
   git clone <your-repository-url>
   cd northwind-capstone-pipeline
   pip install -r requirements.txt
   
   ```

2. **Configure Database Settings:**
   Update your MySQL connection parameters inside `src/config.py`.

3. **Execute the Master Pipeline:**
   Run the master script to automatically create schemas, stage raw CSV data, and execute idempotent dimension/fact upserts:

   ```
   python run_pipeline.py
   
   ```

4. **Explore the Analytics & Statistics:**
   Open the Jupyter Notebook to review exploratory data analysis, distributions, and formal hypothesis testing:

   ```
   jupyter notebook notebooks/statistical_analysis.ipynb
   
   ```

## 📊 Key Analytical Highlights & Findings

* **Revenue Distribution & Skewness:** Financial metrics (order revenue and freight costs) exhibit heavy right-skewness, driven by high-value "whale" orders reaching up to \$17,250.

* **Product Pareto Analysis:** Demonstrated that a fraction of products drive the majority of sales volume, identifying core revenue flagships as well as slow-moving "dead stock."

* **Customer Concentration:** Top-tier VIP accounts account for a disproportionate share of lifetime value.

* **Hypothesis Test 1 (Discount Impact):** Confirmed that discounted order lines drive higher average transaction volumes ($T = 3.1721, p = 0.0015$), indicating effective strategic discounting by sales reps.

* **Hypothesis Test 2 (Top Tier vs. Regular Customer Spending):** Statistically proved that top-tier VIP customers generate a significantly higher mean order revenue per transaction compared to regular customers ($T = 8.8446, p = 0.0000$), validating focused VIP account management.