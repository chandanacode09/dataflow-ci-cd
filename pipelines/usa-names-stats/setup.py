"""Setup file for the USA Names Statistics Dataflow pipeline package."""

import setuptools

REQUIRED_PACKAGES = [
    'apache-beam[gcp]==2.53.0',
    'google-cloud-bigquery==3.14.0',
]

setuptools.setup(
    name='usa-names-stats-pipeline',
    version='0.1.0',
    description='USA Names Statistics Dataflow pipeline reading from BigQuery',
    author='Your Name',
    author_email='your.email@example.com',
    install_requires=REQUIRED_PACKAGES,
    packages=setuptools.find_packages(),
    python_requires='>=3.8',
)
