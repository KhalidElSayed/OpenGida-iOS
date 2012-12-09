#!/usr/bin/env python
"""Reads input files and compares missing translations.

Files are to be expected in the Localizable.strings xcode format, where there
is a common key pair for each value.
"""

from __future__ import with_statement
from contextlib import closing

import sys
import re

PAIR_REGEX = re.compile(r'"([^"]+)"[^"]+"(.+)";.*')


def read_pairs(filename):
	"""f(string) -> {string: string, ...}

	Reads a file and returns a dictionary with all the key/value pairs.
	"""
	d = {}
	with closing(open(filename, "rt")) as input_file:
		line = input_file.readline()
		while line:
			m = PAIR_REGEX.search(line)
			if m:
				d[m.group(1)] = m.group(2)
			line = input_file.readline()

	return d


def show_differences(source, others):
	"""f([string, {}], ([string, {}], ...)) -> None

	Shows the missing keys in source which are in others. All pairs should be
	in the format string, dict, where dict is the format returned by
	read_pairs().
	"""
	different = {}
	master_set = set(source[1].keys())
	for dummy, other_dict in others:
		other_set = set(other_dict.keys())
		for value in other_set.difference(master_set):
			different[value] = 1
	if len(different.keys()):
		print "Missing keys for %s" % (source[0])
		for value in different.keys():
			print "\t", value
	else:
		print "No missing keys for %s" % (source[0])


def main():
	"""Main application entry point."""
	input_files = sys.argv[1:]
	if not input_files:
		print "Please specify some Localizable.strings files as parameters"
		return

	# First read all input files.
	input_dicts = []
	for filename in input_files:
		pairs = read_pairs(filename)
		input_dicts.append((filename, pairs))

	# Get the differences between sets.
	f = 0
	while f < len(input_dicts):
		source = input_dicts[f]
		others = input_dicts[:]
		others.remove(source)
		show_differences(source, others)
		f += 1


if "__main__" == __name__:
	main()

# vim:tabstop=4 shiftwidth=4
