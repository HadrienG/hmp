#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse


def create_manifest(manifest, samples):
    """
    """
    with open(manifest, "r") as f:
        headers = f.readline()
        for line in f:
            sample_name = line.split()[0]
            condition = line.split()[1]
            R1_path = samples + "/" + sample_name + "_R1.fastq.gz"
            R2_path = samples + "/" + sample_name + "_R2.fastq.gz"
            print(
                f"{condition}\t{sample_name}\t{R1_path}\t{R2_path}")
            # read names have to be of the form $sample _R{1,2}.fastq.gz


def main():
    parser = argparse.ArgumentParser(
        usage="python create_trinity_manifest.py"
    )
    parser.add_argument(
        "--manifest",
        required=True,
        help="input manifest of the form sample<tab>condition"
    )
    parser.add_argument(
        "--reads",
        required=True,
        help="directory where all the reads are stored. read names have to be\
        of the form sample_R{1, 2}.fastq.gz"
    )
    args = parser.parse_args()
    create_manifest(args.manifest, args.reads)


if __name__ == "__main__":
    main()
