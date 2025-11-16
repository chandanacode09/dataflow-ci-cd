# Dataflow CI/CD Sample Project

A sample Apache Beam Dataflow project with Cloud Build CI/CD pipelines for testing and deployment.

## Overview

This project demonstrates a complete CI/CD workflow for Google Cloud Dataflow pipelines using Cloud Build. It includes:

- **Sample Dataflow Pipeline**: A word count pipeline using Apache Beam
- **Continuous Integration (CI)**: Automated testing, linting, and code quality checks
- **Continuous Deployment (CD)**: Automated deployment to Google Cloud Dataflow

## Project Structure

```
.
├── main.py                 # Main Dataflow pipeline code
├── setup.py               # Package setup for Dataflow deployment
├── requirements.txt       # Python dependencies
├── ci.yaml               # Cloud Build CI configuration
├── cd.yaml               # Cloud Build CD configuration
├── .flake8               # Flake8 linting configuration
└── tests/                # Unit tests
    ├── __init__.py
    └── test_pipeline.py
```

## Pipeline Description

The sample pipeline (`main.py`) performs word count operations:
1. Reads input text (default: Shakespeare's King Lear from public GCS bucket)
2. Splits text into individual words
3. Counts word occurrences
4. Formats and writes results

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

# Install dependencies
pip install -r requirements.txt
```

### Run Locally

```bash
# Run with DirectRunner (local execution)
python main.py --output=./output/wordcount
```

### Run Tests

```bash
# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ -v --cov=. --cov-report=term-missing
```

### Code Quality Checks

```bash
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

The CI pipeline performs:
- Dependency installation
- Code formatting checks (Black)
- Linting (Flake8)
- Unit tests (Pytest)
- Pipeline validation

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

The CD pipeline performs:
- Pre-deployment checks
- Dataflow job deployment
- Deployment verification

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

To manually deploy the pipeline to Dataflow:

```bash
python main.py \
  --runner=DataflowRunner \
  --project=your-gcp-project-id \
  --region=us-central1 \
  --temp_location=gs://your-bucket/temp \
  --staging_location=gs://your-bucket/staging \
  --output=gs://your-bucket/output/wordcount \
  --job_name=dataflow-sample-manual \
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

### Modify the Pipeline

Edit `main.py` to customize the pipeline logic. The current implementation is a word count example, but you can modify it for your specific use case.

### Add More Tests

Add test files to the `tests/` directory following the pytest conventions.

### Adjust CI/CD Steps

Modify `ci.yaml` and `cd.yaml` to add or remove build steps according to your needs.

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
