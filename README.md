# Dataflow CI/CD Monorepo

A monorepo containing multiple Apache Beam Dataflow pipelines with Cloud Build CI/CD automation for testing and deployment.

## Overview

This project demonstrates a complete CI/CD workflow for multiple Google Cloud Dataflow pipelines using Cloud Build in a monorepo structure. It includes:

- **Multiple Dataflow Pipelines**: Shakespeare word count and USA Names statistics pipelines
- **BigQuery Integration**: All pipelines read from BigQuery public datasets
- **Continuous Integration (CI)**: Automated testing, linting, and code quality checks for all pipelines
- **Continuous Deployment (CD)**: Automated deployment of all pipelines to Google Cloud Dataflow
- **Monorepo Architecture**: Organized structure for managing multiple related pipelines

## Project Structure

```
.
├── pipelines/
│   ├── shakespeare-wordcount/      # Shakespeare word count pipeline
│   │   ├── main.py                 # Pipeline code
│   │   ├── setup.py                # Package setup
│   │   ├── requirements.txt        # Dependencies
│   │   └── tests/
│   │       ├── __init__.py
│   │       └── test_pipeline.py
│   └── usa-names-stats/            # USA names statistics pipeline
│       ├── main.py                 # Pipeline code
│       ├── setup.py                # Package setup
│       ├── requirements.txt        # Dependencies
│       └── tests/
│           ├── __init__.py
│           └── test_pipeline.py
├── ci.yaml                         # Cloud Build CI configuration
├── cd.yaml                         # Cloud Build CD configuration
├── .flake8                         # Flake8 linting configuration
└── README.md                       # This file
```

## Pipelines Description

### 1. Shakespeare WordCount Pipeline
**Location**: `pipelines/shakespeare-wordcount/`

Processes Shakespeare text from BigQuery:
1. Reads words from `bigquery-public-data:samples.shakespeare`
2. Normalizes words to lowercase
3. Counts total occurrences across all plays
4. Outputs formatted word counts

**Key Features**:
- Source: BigQuery public dataset (Shakespeare corpus)
- Processing: Word frequency analysis
- Output: Text files with word counts

### 2. USA Names Statistics Pipeline
**Location**: `pipelines/usa-names-stats/`

Aggregates USA baby names statistics from BigQuery:
1. Reads from `bigquery-public-data:usa_names.usa_1910_current`
2. Filters by configurable year range (default: 2000+)
3. Aggregates total occurrences per name across all years
4. Outputs formatted name statistics

**Key Features**:
- Source: BigQuery public dataset (USA baby names)
- Processing: Name frequency aggregation with year filtering
- Output: Text files with name totals

## Prerequisites

- Python 3.8 or higher
- Google Cloud Project with billing enabled
- Google Cloud SDK installed
- Cloud Build API enabled
- Dataflow API enabled
- Appropriate IAM permissions

## Local Development

### Setup

```bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies for a specific pipeline
cd pipelines/shakespeare-wordcount  # or usa-names-stats
pip install -r requirements.txt
```

### Run Pipelines Locally

**Shakespeare WordCount Pipeline:**
```bash
cd pipelines/shakespeare-wordcount

# Run with DirectRunner (local execution)
python main.py --output=./output/wordcount

# With custom BigQuery table
python main.py \
  --bq-table=bigquery-public-data:samples.shakespeare \
  --output=./output/wordcount
```

**USA Names Statistics Pipeline:**
```bash
cd pipelines/usa-names-stats

# Run with DirectRunner (local execution)
python main.py --output=./output/names-stats

# With year filter
python main.py \
  --year-filter=2010 \
  --output=./output/names-stats
```

### Run Tests

**Test all pipelines:**
```bash
# Shakespeare pipeline tests
cd pipelines/shakespeare-wordcount
pytest tests/ -v --cov=. --cov-report=term-missing

# USA Names pipeline tests
cd pipelines/usa-names-stats
pytest tests/ -v --cov=. --cov-report=term-missing
```

### Code Quality Checks

**For each pipeline:**
```bash
cd pipelines/shakespeare-wordcount  # or usa-names-stats

# Format code with Black
black .

# Check formatting
black --check .

# Run linting
flake8 main.py
```

## CI/CD Setup

### 1. Configure Cloud Build Triggers

#### CI Trigger (ci.yaml)
Create a trigger that runs on pull requests and pushes:

```bash
gcloud builds triggers create github \
  --name="dataflow-ci" \
  --repo-name="your-repo" \
  --repo-owner="your-username" \
  --branch-pattern=".*" \
  --build-config="ci.yaml"
```

The CI pipeline performs for **all pipelines**:
- Dependency installation (per pipeline)
- Code formatting checks with Black (per pipeline)
- Linting with Flake8 (per pipeline)
- Unit tests with Pytest (per pipeline)
- Pipeline validation (per pipeline)

#### CD Trigger (cd.yaml)
Create a trigger for deployments (typically on main branch):

```bash
gcloud builds triggers create github \
  --name="dataflow-cd" \
  --repo-name="your-repo" \
  --repo-owner="your-username" \
  --branch-pattern="^main$" \
  --build-config="cd.yaml"
```

The CD pipeline performs for **all pipelines**:
- Pre-deployment checks (per pipeline)
- Dataflow job deployment (shakespeare-wordcount and usa-names-stats)
- Deployment verification (per pipeline)

### 2. Update Substitution Variables in cd.yaml

Edit `cd.yaml` and replace the following substitution variables:

```yaml
substitutions:
  _PROJECT_ID: 'your-gcp-project-id'           # Your GCP project ID
  _REGION: 'us-central1'                       # Preferred region
  _TEMP_LOCATION: 'gs://your-bucket/temp'      # GCS bucket for temp files
  _STAGING_LOCATION: 'gs://your-bucket/staging' # GCS bucket for staging
  _OUTPUT_LOCATION: 'gs://your-bucket/output'  # GCS bucket for output
  _SERVICE_ACCOUNT: 'dataflow-sa@your-project.iam.gserviceaccount.com'
  _NETWORK: 'default'                          # VPC network
  _SUBNETWORK: 'regions/us-central1/subnetworks/default'
```

### 3. Create Required GCS Buckets

```bash
# Create buckets for temp, staging, and output
gsutil mb -p your-gcp-project-id -l us-central1 gs://your-bucket
```

### 4. Create Service Account for Dataflow

```bash
# Create service account
gcloud iam service-accounts create dataflow-sa \
  --display-name="Dataflow Service Account"

# Grant necessary roles
gcloud projects add-iam-policy-binding your-gcp-project-id \
  --member="serviceAccount:dataflow-sa@your-gcp-project-id.iam.gserviceaccount.com" \
  --role="roles/dataflow.worker"

gcloud projects add-iam-policy-binding your-gcp-project-id \
  --member="serviceAccount:dataflow-sa@your-gcp-project-id.iam.gserviceaccount.com" \
  --role="roles/storage.objectAdmin"
```

## Manual Deployment

To manually deploy pipelines to Dataflow:

**Shakespeare WordCount Pipeline:**
```bash
cd pipelines/shakespeare-wordcount

python main.py \
  --runner=DataflowRunner \
  --project=your-gcp-project-id \
  --region=us-central1 \
  --temp_location=gs://your-bucket/temp/shakespeare \
  --staging_location=gs://your-bucket/staging/shakespeare \
  --output=gs://your-bucket/output/shakespeare/wordcount \
  --job_name=shakespeare-wordcount-manual \
  --setup_file=./setup.py
```

**USA Names Statistics Pipeline:**
```bash
cd pipelines/usa-names-stats

python main.py \
  --runner=DataflowRunner \
  --project=your-gcp-project-id \
  --region=us-central1 \
  --temp_location=gs://your-bucket/temp/usa-names \
  --staging_location=gs://your-bucket/staging/usa-names \
  --output=gs://your-bucket/output/usa-names/stats \
  --job_name=usa-names-stats-manual \
  --year-filter=2000 \
  --setup_file=./setup.py
```

## Monitoring

### View Dataflow Jobs

```bash
# List all jobs
gcloud dataflow jobs list --region=us-central1

# Describe specific job
gcloud dataflow jobs describe JOB_ID --region=us-central1
```

### View Cloud Build History

```bash
# List recent builds
gcloud builds list --limit=10
```

## Customization

### Add a New Pipeline

To add a new pipeline to the monorepo:

1. Create a new directory under `pipelines/`:
   ```bash
   mkdir -p pipelines/my-new-pipeline/tests
   ```

2. Add pipeline files:
   - `main.py` - Pipeline code
   - `setup.py` - Package setup
   - `requirements.txt` - Dependencies
   - `tests/test_pipeline.py` - Unit tests

3. Update `ci.yaml` to add CI steps for the new pipeline

4. Update `cd.yaml` to add deployment steps for the new pipeline

### Modify Existing Pipelines

Edit the `main.py` file in any pipeline directory to customize the logic. Each pipeline is independent and can be modified separately.

### Add More Tests

Add test files to the `tests/` directory within each pipeline following pytest conventions.

### Adjust CI/CD Steps

Modify `ci.yaml` and `cd.yaml` to add or remove build steps. The current configuration processes all pipelines in parallel for efficiency.

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure Cloud Build service account has necessary permissions
2. **Bucket Access Errors**: Verify GCS bucket permissions and existence
3. **Test Failures**: Check that all dependencies are installed and tests are updated

### Logs

```bash
# View Cloud Build logs
gcloud builds log BUILD_ID

# View Dataflow job logs
gcloud dataflow jobs show JOB_ID --region=us-central1
```

## Best Practices

1. **Branch Protection**: Enable branch protection on main/master branch
2. **Code Review**: Require PR reviews before merging
3. **Secrets Management**: Use Secret Manager for sensitive values
4. **Cost Monitoring**: Set up billing alerts for Dataflow jobs
5. **Resource Cleanup**: Implement job cleanup policies

## Additional Resources

- [Apache Beam Documentation](https://beam.apache.org/documentation/)
- [Google Cloud Dataflow Documentation](https://cloud.google.com/dataflow/docs)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Apache Beam Python SDK](https://beam.apache.org/documentation/sdks/python/)

## License

This is a sample project for demonstration purposes.
