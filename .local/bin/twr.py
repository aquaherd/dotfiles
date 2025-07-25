#!/usr/bin/python3

###############################################################################
#
# Copyright 2016, 2018 - 2021, Thomas Lauf, Paul Beckingham, Federico Hernandez.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# https://www.opensource.org/licenses/mit-license.php
#
###############################################################################

import datetime
import json
import os
import re
from urllib.error import HTTPError
from urllib.request import urlopen

import argparse


def enumerate(path):
    if not os.path.exists(path):
        raise Exception("Directory '{}' does not exist".format(path))

    found = []
    for path, dirs, files in os.walk(path, topdown=True, onerror=None, followlinks=False):
        found.extend([os.path.join(path, x) for x in files])
    return found


def holidata(locale, year):
    return "https://holidata.net/{}/{}.json".format(locale, year)


def update_locales(locales, regions, years):
    now = datetime.datetime.now()

    if not years:
        years = [now.year, now.year + 1]

    for locale in locales:
        with open("holidays.{}".format(locale), "w") as fh:
            fh.write("# Holiday data provided by holidata.net\n")
            fh.write("#   Generated {:%Y-%m-%dT%H:%M:%S}\n\n".format(now))
            fh.write("define holidays:\n")
            fh.write("  {}:\n".format(locale))

            for year in years:
                holidays = dict()
                url = holidata(locale, year)
                print(url)
                try:
                    lines = urlopen(url).read().decode("utf-8")

                    for line in lines.split('\n'):
                        if line:
                            j = json.loads(line)
                            if not j['region'] or not regions or j['region'] in regions:
                                day = j['date'].replace("-", "_")
                                desc = j['description']
                                holidays[day] = desc

                    for date, desc in holidays.items():
                        fh.write("    {} = {}\n".format(date, desc))

                    fh.write('\n')

                except HTTPError as e:
                    if e.code == 404:
                        print("holidata.net does not have data for {}, for {}.".format(locale, year))
                    else:
                        print(e.code, e.read())


def main(args):
    if args.locale:
        update_locales(args.locale, args.region, args.year)
    else:
        # Enumerate all holiday files in the current directory.
        locales = []
        re_holiday_file = re.compile(r"/holidays.([a-z]{2}-[A-Z]{2}$)")
        for file in enumerate('.'):
            result = re_holiday_file.search(file)
            if result:
                # Extract the locale name.
                locales.append(result.group(1))

        update_locales(locales, args.region, args.year)


if __name__ == "__main__":
    usage = """See https://holidata.net for details of supported locales and regions."""
    parser = argparse.ArgumentParser(
        description="Update holiday data files. Simply run 'refresh' to update all of them.")
    parser.add_argument('--locale', nargs='+', help='Specific locale to update.')
    parser.add_argument('--region', nargs='+', help='Specific locale region to update.', default=[])
    parser.add_argument('--year', nargs='+', help='Specific year to fetch.', type=int, default=[])
    args = parser.parse_args()

    try:
        main(args)
    except Exception as msg:
        print('Error:', msg)
