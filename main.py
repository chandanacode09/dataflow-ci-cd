"""
Sample Apache Beam Dataflow Pipeline
This pipeline reads text data, processes it, and writes the results.
"""
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, StandardOptions
import argparse
import logging


class WordExtractingDoFn(beam.DoFn):
    """Parse each line of input text into words."""

    def process(self, element):
        """Returns an iterator over the words of this element.

        Args:
            element: the element being processed

        Returns:
            The processed element.
        """
        return element.split()


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
        '--input',
        dest='input',
        default='gs://dataflow-samples/shakespeare/kinglear.txt',
        help='Input file to process.'
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

        # Read the text file or input
        lines = p | 'Read' >> beam.io.ReadFromText(known_args.input)

        # Count the occurrences of each word
        counts = (
            lines
            | 'Split' >> beam.ParDo(WordExtractingDoFn())
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
