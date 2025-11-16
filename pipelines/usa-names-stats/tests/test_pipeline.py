"""Unit tests for the USA Names Statistics Dataflow pipeline."""

import unittest
import apache_beam as beam
from apache_beam.testing.test_pipeline import TestPipeline
from apache_beam.testing.util import assert_that, equal_to
import sys
import os

# Add parent directory to path to import main module
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import ExtractNameDataDoFn, FormatResultFn


class TestExtractNameDataDoFn(unittest.TestCase):
    """Test cases for ExtractNameDataDoFn."""

    def test_extract_name_data(self):
        """Test that name and number are correctly extracted."""
        with TestPipeline() as p:
            input_row = {'name': 'Emma', 'number': 100, 'year': 2020, 'gender': 'F'}
            expected_output = [('Emma', 100)]

            output = (
                p
                | beam.Create([input_row])
                | beam.ParDo(ExtractNameDataDoFn())
            )

            assert_that(output, equal_to(expected_output))

    def test_empty_name(self):
        """Test that empty names are filtered out."""
        with TestPipeline() as p:
            input_row = {'name': '', 'number': 100, 'year': 2020, 'gender': 'F'}
            expected_output = []

            output = (
                p
                | beam.Create([input_row])
                | beam.ParDo(ExtractNameDataDoFn())
            )

            assert_that(output, equal_to(expected_output))

    def test_zero_number(self):
        """Test that zero numbers are filtered out."""
        with TestPipeline() as p:
            input_row = {'name': 'Emma', 'number': 0, 'year': 2020, 'gender': 'F'}
            expected_output = []

            output = (
                p
                | beam.Create([input_row])
                | beam.ParDo(ExtractNameDataDoFn())
            )

            assert_that(output, equal_to(expected_output))

    def test_missing_fields(self):
        """Test that missing fields are handled correctly."""
        with TestPipeline() as p:
            input_row = {'year': 2020, 'gender': 'F'}
            expected_output = []

            output = (
                p
                | beam.Create([input_row])
                | beam.ParDo(ExtractNameDataDoFn())
            )

            assert_that(output, equal_to(expected_output))


class TestFormatResultFn(unittest.TestCase):
    """Test cases for FormatResultFn."""

    def test_format_result(self):
        """Test that results are correctly formatted."""
        with TestPipeline() as p:
            input_data = [("Emma", 5000), ("Liam", 3000)]
            expected_output = ["Emma: 5000", "Liam: 3000"]

            output = (
                p
                | beam.Create(input_data)
                | beam.ParDo(FormatResultFn())
            )

            assert_that(output, equal_to(expected_output))


class TestNameStatsPipeline(unittest.TestCase):
    """Integration tests for the name statistics pipeline."""

    def test_name_aggregation_integration(self):
        """Test the complete name aggregation pipeline."""
        with TestPipeline() as p:
            input_rows = [
                {'name': 'Emma', 'number': 100, 'year': 2020, 'gender': 'F'},
                {'name': 'Emma', 'number': 150, 'year': 2021, 'gender': 'F'},
                {'name': 'Liam', 'number': 200, 'year': 2020, 'gender': 'M'},
                {'name': 'Liam', 'number': 180, 'year': 2021, 'gender': 'M'},
                {'name': 'Olivia', 'number': 120, 'year': 2020, 'gender': 'F'}
            ]
            expected_output = ["Emma: 250", "Liam: 380", "Olivia: 120"]

            output = (
                p
                | beam.Create(input_rows)
                | 'ExtractNameData' >> beam.ParDo(ExtractNameDataDoFn())
                | 'SumByName' >> beam.CombinePerKey(sum)
                | 'Format' >> beam.ParDo(FormatResultFn())
            )

            assert_that(output, equal_to(expected_output))


if __name__ == '__main__':
    unittest.main()
