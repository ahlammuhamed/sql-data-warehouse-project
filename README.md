# Data Warehouse and Analytics Project 🚀

Welcome to the **Data Warehouse and Analytics Project** repository!
This project showcases the design and implementation of a modern data warehouse solution using SQL Server and Medallion Architecture principles.

The project was built to strengthen my practical skills in data engineering, ETL development, and analytical data modeling.

---

# 🏗️ Data Architecture

This project follows the **Medallion Architecture** approach using Bronze, Silver, and Gold layers.
(arch diagram will be here)

### 🥉 Bronze Layer

Stores raw data directly from source systems without modifications.
Data is imported from CSV files into SQL Server.

### 🥈 Silver Layer

Includes data cleaning, standardization, transformation, and normalization processes to improve data quality and prepare it for analysis.

### 🥇 Gold Layer

Contains business-ready analytical data modeled into a Star Schema optimized for reporting and analytics.

---

# 📖 Project Overview

This project includes:

* Designing a modern Data Warehouse architecture
* Building ETL pipelines using SQL Server
* Cleaning and transforming raw datasets
* Creating fact and dimension tables
* Developing analytical SQL queries and reports
* Generating business insights from data

---

# 🎯 Skills Demonstrated

* SQL Development
* Data Warehousing
* ETL Pipelines
* Data Modeling
* Data Cleaning & Transformation
* Data Analytics
* Reporting & Insights Generation

---

# 🛠️ Tools & Technologies

* SQL Server
* SQL Server Management Studio (SSMS)
* Draw.io
* Git & GitHub
* CSV Datasets
* Notion

---

# 🚀 Project Requirements

## Building the Data Warehouse (Data Engineering)

### Objective

Build a modern data warehouse using SQL Server to consolidate and analyze sales data from multiple sources.

### Specifications

* Data Sources: Import data from two source systems (ERP and CRM) provided as CSV files.
* Data Quality: Cleanse and resolve data quality issues prior to analysis.
* Integration: Combine both sources into a single, user-friendly data model designed for analytical queries.
* Scope: Focus on the latest dataset only; historization of data is not required.
* Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

## Data Analytics

### Objective

Develop SQL-based analytics and reporting to generate insights about:

* Customer Behavior
* Product Performance
* Sales Trends

These insights help support better business decision-making.

---

# 📂 Repository Structure

```bash
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── etl.drawio                      # Draw.io file shows all different techniquies and methods of ETL
│   ├── data_architecture.drawio        # Draw.io file shows the project's architecture
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio                # Draw.io file for the data flow diagram
│   ├── data_models.drawio              # Draw.io file for data models (star schema)
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
└── requirements.txt                    # Dependencies and requirements for the project
```

---

# 🌟 About Me

Hi! I'm **Ahlam Mohamed** 👋
An aspiring Data Engineer passionate about learning, building projects, and transforming data into valuable insights.

I continuously improve my skills in SQL, Python, Power BI, and Data Engineering concepts through hands-on projects and daily learning. I believe growth is a continuous journey, and I strive every day to become a better version of myself 🚀

---

# 📫 Let's Connect

Feel free to connect with me on LinkedIn and follow my learning journey ✨

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ahlammohamed25)

---

# 🛡️ License

This project is licensed under the MIT License.
