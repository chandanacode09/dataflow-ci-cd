"""
Shakespeare Word Count Pipeline - BigQuery Source
This pipeline reads Shakespeare text from BigQuery, processes word counts, and writes results.
"""
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigquery import ReadFromBigQuery
import argparse
import logging


class WordExtractingDoFn(beam.DoFn):
    """Parse each line of input text into words."""

    def process(self, element):
        """Returns an iterator over the words of this element.

        Args:
            element: BigQuery row dict with 'word' field

        Returns:
            The processed element (word).
        """
        # BigQuery row is a dict, extract the word field
        word = element.get('word', '')
        if word:
            return [word.lower()]
        return []


class FormatResultFn(beam.DoFn):
    """Format the word count results."""

    def process(self, element):
        """Format the output.

        Args:
            element: tuple of (word, count)

        Returns:
            Formatted string.
        """
        word, count = element
        return [f'{word}: {count}']


def run(argv=None):
    """Main entry point; defines and runs the wordcount pipeline."""

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--bq-table',
        dest='bq_table',
        default='bigquery-public-data:samples.shakespeare',
        help='BigQuery table to read from (project:dataset.table format).'
    )
    parser.add_argument(
        '--output',
        dest='output',
        required=False,
        help='Output file to write results to.'
    )

    known_args, pipeline_args = parser.parse_known_args(argv)

    # Set pipeline options
    pipeline_options = PipelineOptions(pipeline_args)

    # Run the pipeline
    with beam.Pipeline(options=pipeline_options) as p:

        # Read from BigQuery
        # The shakespeare table has columns: word, word_count, corpus, corpus_date
        lines = (
            p
            | 'ReadFromBigQuery' >> ReadFromBigQuery(
                table=known_args.bq_table,
                selected_fields='word'
            )
        )

        # Count the occurrences of each word across all plays
        counts = (
            lines
            | 'ExtractWords' >> beam.ParDo(WordExtractingDoFn())
            | 'PairWithOne' >> beam.Map(lambda x: (x, 1))
            | 'GroupAndSum' >> beam.CombinePerKey(sum)
        )

        # Format the output
        output = counts | 'Format' >> beam.ParDo(FormatResultFn())

        # Write the output
        if known_args.output:
            output | 'Write' >> beam.io.WriteToText(
                known_args.output,
                file_name_suffix='.txt'
            )
        else:
            # For testing, just print to console
            output | 'Print' >> beam.Map(logging.info)


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run()
