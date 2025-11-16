"""Unit tests for the Dataflow pipeline."""

import unittest
import apache_beam as beam
from apache_beam.testing.test_pipeline import TestPipeline
from apache_beam.testing.util import assert_that, equal_to
import sys
import os

# Add parent directory to path to import main module
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import WordExtractingDoFn, FormatResultFn


class TestWordExtractingDoFn(unittest.TestCase):
    """Test cases for WordExtractingDoFn."""

    def test_word_extraction(self):
        """Test that words are correctly extracted from a line."""
        with TestPipeline() as p:
            input_line = "Hello world this is a test"
            expected_output = ["Hello", "world", "this", "is", "a", "test"]

            output = (
                p
                | beam.Create([input_line])
                | beam.ParDo(WordExtractingDoFn())
            )

            assert_that(output, equal_to(expected_output))

    def test_empty_line(self):
        """Test that empty lines are handled correctly."""
        with TestPipeline() as p:
            input_line = ""
            expected_output = [""]

            output = (
                p
                | beam.Create([input_line])
                | beam.ParDo(WordExtractingDoFn())
            )

            assert_that(output, equal_to(expected_output))


class TestFormatResultFn(unittest.TestCase):
    """Test cases for FormatResultFn."""

    def test_format_result(self):
        """Test that results are correctly formatted."""
        with TestPipeline() as p:
            input_data = [("hello", 5), ("world", 3)]
            expected_output = ["hello: 5", "world: 3"]

            output = (
                p
                | beam.Create(input_data)
                | beam.ParDo(FormatResultFn())
            )

            assert_that(output, equal_to(expected_output))


class TestWordCountPipeline(unittest.TestCase):
    """Integration tests for the word count pipeline."""

    def test_word_count_integration(self):
        """Test the complete word count pipeline."""
        with TestPipeline() as p:
            input_lines = ["hello world", "hello beam", "world"]
            expected_output = ["beam: 1", "hello: 2", "world: 2"]

            output = (
                p
                | beam.Create(input_lines)
                | 'Split' >> beam.ParDo(WordExtractingDoFn())
                | 'PairWithOne' >> beam.Map(lambda x: (x, 1))
                | 'GroupAndSum' >> beam.CombinePerKey(sum)
                | 'Format' >> beam.ParDo(FormatResultFn())
            )

            assert_that(output, equal_to(expected_output))


if __name__ == '__main__':
    unittest.main()
