# CORE TELECOM CUSTOMER COMPLAINTS DATA PLATFORM

## Project Overview 

This project delivers a full containerized data pipeline that brings together customer complaints from different channels into one structured and analytics-ready platform. This would curb the current company's challenge of keeping up with customer complaints leading to loss of customers.

The aim is to give the business a complete view of:
- customer complaints
- agent performance
- issue trends across channels
- resolution patterns

The pipeline covers extraction of complaints from different sources, storage, processing, modeling, scheduling, and deployment using modern data engineering tools.

## Data Sources
- Call Center System - compliant logs
- Website Portal - complaint tables
- Social Media - Structured complaint data from different channels
- Customers Data
- Agents Data

## Source Storage Types
- AWS S3 (CSV + JSON files)
- Google sheets
- AWS PostgreSQL

## Tools And Technology Choices 
- AWS S3: Used as the landing/ingestion zone.
- Airbyte: Used for loading raw data from S3 into Snowflake
- Snowflake: Used as the main warehouse.
- DBT: Used for transformation and modelling.
- Apache Airflow: Used to orchestrate the entire pipeline.
- Terraform: Manages cloud resources such as Snowflake objects, S3 bucket, roles, and permissions, Airbtye objects (Source, Destinations, and Connectors)
- Docker: Packages Airflow, dbt, and extract scripts into containers
- Github Actions: Provides CI/CD for linting (flake8), building images, and pushing to Docker Hub.

## High-Level Architecture 
The platform follows a clean three-layer structure:
1. Ingestion Layer
   - Raw extraction from S3, Google Sheets, and PostgreSQL.
   - All files converted to Parquet and stored in AWS S3.
   - Metadata included for loading timestamps.
2. Landing (Bronze) Layer
   - Airbyte moves raw data into Snowflake Bronze Schema exactly as received.
   - Included Airbyte Metadata useful for dbt freshness logic.
3. Transformation Layers (DBT)
   - Silver Layer:
       - Cleaned and standardized data
       - Applied SCD1 on dimension tables
       - Added surrogate keys for warehouse tracking and clustering.
    - Gold Layer:
        - Final aggregated models for reporting and analysis.
The entire workflpow is automated through Airflow.

## Implementation Summary 
**A. Extraction & Ingestion**
- Created S3 bucket using Terraform
- Added Terraform backend state
- Built Python extraction functions for each data source.
  - Added logging and exception handling

**B. Loading Into Snowflake (Airbyte)**
- Created Snowflake database, schemas (Bronze and Dataops) using Terraform
- Created role and user for Airbyte
- Configured Airbyte Source with 5 Streams and 2 Snowflake destinations (Fact and Dimension tables)
- Sync behaviour:
    - Full refresh: Agents
    - Incremental + dedup: Customers
    - Incremental: Call Center, Social Media, Website complaints.

**C. Data Modelling (DBT)**
- Designed models for dimension and fact tables
- Implemented:
    - Incremental models
    - merge strategy for dimensions
    - append strategy for facts
    - surrogate keys using dbt_utils
    - SCD1 for dimension tables
    - Clustering for performance
    - Gold final table for analytics
  - All dbt tests passed (27/27)

**D. Orchestration (Airflow)**

Airflow DAG handles:
1. Running Extraction Job from all sources.
2. Triggering Airbyte syncs
3. Running dbt models and dbt tests
4. Retries, scheduling, task dependencies, and full workflow automation.

<img width="955" height="294" alt="image" src="https://github.com/user-attachments/assets/67f203c4-435e-4eda-ac1e-5c278fe43371" />

**E. Containerization**
- Generated requirements.txt file using pip freeze
- Built Dockerfile including Airflow dags, configs, dbt folders, and Python Scripts.
- Pushed Image to Docker Hub
- Configured docker-compose for local orchestration
- .env file used for AWS credentials.

**F. CI/CD**

Github Actions pipeline includes:
- flake8 linting
- Docker image build
- Push image to Docker Hub
- Repo-level secrets for secure authentication.

##  Set Up And Run 

**Prerequisites**
- Docker Desktop
- Access to Snowflake
- Access to Airbyte Cloud
- AWS credentials

1. Clone the repository
   ```bash
   git clone https://github.com/<your-repo>
   cd coretelecom
   ```
2. Create a .env file
   Include your AWS keys (local only):
   ```ini
   AWS_ACCESS_KEY_ID=XXXX
   AWS_SECRET_ACCESS_KEY=XXXX
   ```
3. Build and start containers
   ```nginx
   docker compose up -d
   ```

4. Open Airflow UI
   Go to: http://localhost:8080 to view Dag Runs 
