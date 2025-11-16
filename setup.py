"""Setup file for the Dataflow pipeline package."""

import setuptools

REQUIRED_PACKAGES = [
    'apache-beam[gcp]==2.53.0',
    'google-cloud-storage==2.14.0',
]

setuptools.setup(
    name='dataflow-sample-pipeline',
    version='0.1.0',
    description='Sample Dataflow pipeline with CI/CD',
    author='Your Name',
    author_email='your.email@example.com',
    install_requires=REQUIRED_PACKAGES,
    packages=setuptools.find_packages(),
    python_requires='>=3.8',
)
