#!/usr/bin/env python3
"""
setup_project_structure.py

Creates the following project structure for "customer-shopping-analytics/":

customer-shopping-analytics/
├── data/
│   ├── raw/
│   │   └── customer_shopping_behavior.csv
│   └── processed/
│       └── customer_cleaned.csv
│
├── notebooks/
│   ├── 01_data_cleaning_and_eda.ipynb
│   ├── 02_advanced_analytics.ipynb
│   ├── 03_predictive_modeling.ipynb
│   └── 04_statistical_analysis.ipynb
│
├── sql/
│   ├── 01_schema_creation.sql
│   ├── 02_basic_queries.sql
│   ├── 03_advanced_business_queries.sql
│   └── 04_insights_queries.sql
│
├── powerbi/
│   ├── customer_behavior_dashboard.pbix
│   └── screenshots/
│
├── reports/
│   ├── technical_report.md
│   ├── executive_summary.md
│   └── presentation.pdf
│
├── src/
│   ├── __init__.py
│   ├── config.py
│   └── database_connection.py
│
├── .gitignore
├── requirements.txt
└── README.md
"""

from pathlib import Path
import json
import sys

# Define project root
PROJECT_NAME = "customer-shopping-analytics"
ROOT = Path.cwd() / PROJECT_NAME

# Directory and file structure
structure = {
    "data/raw": {
        "customer_shopping_behavior.csv": None
    },
    "data/processed": {
        "customer_cleaned.csv": None
    },
    "notebooks": {
        "01_data_cleaning_and_eda.ipynb": "notebook",
        "02_advanced_analytics.ipynb": "notebook",
        "03_predictive_modeling.ipynb": "notebook",
        "04_statistical_analysis.ipynb": "notebook",
    },
    "sql": {
        "01_schema_creation.sql": "-- SQL: schema creation\n-- Add CREATE TABLE statements here\n",
        "02_basic_queries.sql": "-- Basic queries for EDA and reporting\n",
        "03_advanced_business_queries.sql": "-- Joins, window functions, cohort analysis queries\n",
        "04_insights_queries.sql": "-- Business insights queries\n",
    },
    "powerbi/screenshots": {},
    "powerbi/customer_behavior_dashboard.pbix": b"%PDF-1.4\n%placeholder pbix-like file\n",
    "reports": {
        "technical_report.md": "# Technical report\n\nDescribe methods, data pipeline, models, and results.\n",
        "executive_summary.md": "# Executive summary\n\nHigh level summary for business stakeholders.\n",
        "presentation.pdf": b"%PDF-1.4\n%placeholder PDF presentation\n",
    },
    "src": {
        "__init__.py": "# src package\n",
        "config.py": "# Configuration variables\nDB_PATH = 'data/processed/customer_cleaned.db'\n",
        "database_connection.py": """# Simple sqlite database connection helper
import sqlite3
from pathlib import Path

DB_FILE = Path(__file__).resolve().parents[1] / 'data' / 'processed' / 'customer_cleaned.db'

def get_connection(db_path: str = None):
    \"\"\"Return a sqlite3 connection. If db_path is None, a file in data/processed will be used.\"\"\"
    path = DB_FILE if db_path is None else Path(db_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(path))
    return conn
"""
    },
    ".gitignore": """# Python artifacts
__pycache__/
*.pyc
*.pyo
*.pyd
env/
.venv/
venv/
.Python
# Jupyter
.ipynb_checkpoints/
# Data and outputs
data/raw/*
!data/raw/customer_shopping_behavior.csv
data/processed/*
# VSCode
.vscode/
""",
    "requirements.txt": "pandas\nnumpy\nscikit-learn\nmatplotlib\nnotebook\n",
    "README.md": f"# {PROJECT_NAME}\n\nProject skeleton for customer shopping analytics.\n\n## Structure\nSee folders for data, notebooks, SQL, reports and src.\n",
}

# Minimal Jupyter notebook template
nb_skeleton = {
    "nbformat": 4,
    "nbformat_minor": 5,
    "metadata": {},
    "cells": [
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": ["# Notebook\n\nThis is a generated notebook skeleton. Replace with your content."]
        }
    ]
}

# Sample CSV headers
raw_csv_header = "customer_id,visit_date,product_id,category,quantity,price,total_spent\n"
cleaned_csv_header = "customer_id,visit_date,product_id,category,quantity,price,total_spent,cleaned_flag\n"


def create_file(path: Path, content, binary=False):
    """Utility to create file and write content."""
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = "wb" if binary else "w"
    with open(path, mode) as f:
        if binary:
            if isinstance(content, bytes):
                f.write(content)
            else:
                f.write(str(content).encode("utf-8"))
        else:
            f.write(content)


def main():
    print(f"📁 Creating project skeleton at: {ROOT}")
    for rel_path, value in structure.items():
        target = ROOT / rel_path
        if isinstance(value, dict):
            target.mkdir(parents=True, exist_ok=True)
            for fname, fcontent in value.items():
                file_path = target / fname
                if fcontent is None:
                    file_path.touch()
                elif fcontent == "notebook":
                    file_path.write_text(json.dumps(nb_skeleton, indent=2))
                elif isinstance(fcontent, bytes):
                    create_file(file_path, fcontent, binary=True)
                else:
                    create_file(file_path, fcontent, binary=False)
        else:
            if isinstance(value, bytes):
                create_file(target, value, binary=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                create_file(target, value, binary=False)

    # Add CSV files with headers
    raw_csv = ROOT / "data" / "raw" / "customer_shopping_behavior.csv"
    processed_csv = ROOT / "data" / "processed" / "customer_cleaned.csv"
    if not raw_csv.exists() or raw_csv.stat().st_size == 0:
        create_file(raw_csv, raw_csv_header)
    if not processed_csv.exists() or processed_csv.stat().st_size == 0:
        create_file(processed_csv, cleaned_csv_header)

    # Ensure src package init file exists
    init_py = ROOT / "src" / "__init__.py"
    if not init_py.exists():
        create_file(init_py, "# src package\n")

    print("✅ Project skeleton created successfully!")
    print(f"➡ Open '{ROOT}' in VS Code to start working on your project.\n")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("❌ Error while creating project:", e)
        sys.exit(1)
