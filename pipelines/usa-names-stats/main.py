"""
USA Names Statistics Pipeline - BigQuery Source
This pipeline reads USA baby names data from BigQuery and aggregates statistics.
"""
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigquery import ReadFromBigQuery
import argparse
import logging


class ExtractNameDataDoFn(beam.DoFn):
    """Extract name and count from BigQuery row."""

    def process(self, element):
        """Extract name and number from element.

        Args:
            element: BigQuery row dict with 'name', 'number', 'year', 'gender' fields

        Returns:
            Tuple of (name, number).
        """
        name = element.get('name', '')
        number = element.get('number', 0)
        if name and number:
            return [(name, number)]
        return []


class FormatResultFn(beam.DoFn):
    """Format the name statistics results."""

    def process(self, element):
        """Format the output.

        Args:
            element: tuple of (name, total_count)

        Returns:
            Formatted string.
        """
        name, total_count = element
        return [f'{name}: {total_count}']


def run(argv=None):
    """Main entry point; defines and runs the name statistics pipeline."""

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--bq-table',
        dest='bq_table',
        default='bigquery-public-data:usa_names.usa_1910_current',
        help='BigQuery table to read from (project:dataset.table format).'
    )
    parser.add_argument(
        '--output',
        dest='output',
        required=False,
        help='Output file to write results to.'
    )
    parser.add_argument(
        '--year-filter',
        dest='year_filter',
        type=int,
        default=2000,
        help='Filter data for years greater than or equal to this value.'
    )

    known_args, pipeline_args = parser.parse_known_args(argv)

    # Set pipeline options
    pipeline_options = PipelineOptions(pipeline_args)

    # Build query to filter by year
    query = f"""
        SELECT name, number, year, gender
        FROM `{known_args.bq_table.replace(':', '.')}`
        WHERE year >= {known_args.year_filter}
    """

    # Run the pipeline
    with beam.Pipeline(options=pipeline_options) as p:

        # Read from BigQuery with query
        lines = (
            p
            | 'ReadFromBigQuery' >> ReadFromBigQuery(
                query=query,
                use_standard_sql=True
            )
        )

        # Aggregate total occurrences per name across all years
        totals = (
            lines
            | 'ExtractNameData' >> beam.ParDo(ExtractNameDataDoFn())
            | 'SumByName' >> beam.CombinePerKey(sum)
        )

        # Format the output
        output = totals | 'Format' >> beam.ParDo(FormatResultFn())

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
