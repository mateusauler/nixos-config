#!/usr/bin/env python3

import argparse
import atexit
import concurrent.futures
import csv
import hashlib
import os
import requests
import subprocess
import tempfile

def export_database(database, keyfile):
    temp_file = tempfile.NamedTemporaryFile(delete=False)
    temp_filename = temp_file.name

    line = ["keepassxc-cli", "export", database, "--format", "csv"]
    if keyfile:
        line += ["--key-file", keyfile]
    subprocess.run(line, stdout=temp_file, check=True)

    return temp_filename

def check_password(row):
    password = row["Password"]
    sha1_hash = hashlib.sha1(password.encode()).hexdigest().upper()

    prefix, suffix = sha1_hash[:5], sha1_hash[5:]

    url = f"https://api.pwnedpasswords.com/range/{prefix}"
    headers = { 'Add-Padding': True }
    response = requests.get(url)

    row["compromised_count"] = 0
    for line in response.text.splitlines():
        hash, count = line.split(":")
        if hash == suffix:
            row["compromised_count"] = int(count)
            break

    return row

def print_result(row, show_password):
    title = row["Title"]
    password = row["Password"]
    username = row["Username"]
    group = row["Group"]
    compromised_count = row["compromised_count"]

    label = f'{group}/{title}' + (f' ({username})' if username else '')

    print(f'{label}: ' + (f'"{password}" ' if show_password else '') + f'{compromised_count} times')

def main():
    parser = argparse.ArgumentParser(description="Check if passwords in a KeePassXC database have been compromised using the Have I Been Pwned API.")
    parser.add_argument("database", metavar="DATABASE", help="Path to the KeePassXC database file.")
    parser.add_argument("-k", "--key-file", help="Path to the key file for the KeePassXC database.", required=False)
    parser.add_argument("-s", "--show-password", help="Show passwords in plain text when they've been compromised.", action='store_true')
    args = parser.parse_args()

    show_password = args.show_password

    temp_filename = export_database(args.database, args.key_file)

    # Register cleanup function with atexit to ensure the temporary file is removed on exit
    atexit.register(os.remove, temp_filename)

    csvfile = open(temp_filename, "r")
    reader = csv.DictReader(csvfile)

    with concurrent.futures.ThreadPoolExecutor(max_workers = os.cpu_count()) as executor:
        results = list(executor.map(check_password, reader))
        [print_result(x, show_password) for x in results if x["compromised_count"] > 0]

if __name__ == "__main__":
    main()
