#!/usr/bin/env python3
from __future__ import print_function

import os
import sys
import json
import struct
import subprocess

VERSION = '7.2.6'

try:
	sys.stdin.buffer

	# Python 3.x version
	# Read a message from stdin and decode it.
	def getMessage():
		rawLength = sys.stdin.buffer.read(4)
		if len(rawLength) == 0:
			sys.exit(0)
		messageLength = struct.unpack('@I', rawLength)[0]
		message = sys.stdin.buffer.read(messageLength).decode('utf-8')
		return json.loads(message)

	# Send an encoded message to stdout
	def sendMessage(messageContent):
		encodedContent = json.dumps(messageContent).encode('utf-8')
		encodedLength = struct.pack('@I', len(encodedContent))

		sys.stdout.buffer.write(encodedLength)
		sys.stdout.buffer.write(encodedContent)
		sys.stdout.buffer.flush()

except AttributeError:
	# Python 2.x version (if sys.stdin.buffer is not defined)
	print('Python 3.2 or newer is required.')
	sys.exit(-1)


def _read_desktop_file(path):
	with open(path, 'r') as desktop_file:
		current_section = None
		name = None
		command = None
		for line in desktop_file:
			if line[0] == '[':
				current_section = line[1:-2]
			if current_section != 'Desktop Entry':
				continue

			if line.startswith('Name='):
				name = line[5:].strip()
			elif line.startswith('Exec='):
				command = line[5:].strip()

		return {
			'name': name,
			'command': command
		}


def find_browsers():
	apps = [
		'Chrome',
		'Chromium',
		'chromium',
		'chromium-browser',
		'firefox',
		'Firefox',
		'Google Chrome',
		'google-chrome',
		'opera',
		'Opera',
		'SeaMonkey',
		'seamonkey',
	]
	paths = [
		os.path.join(os.getenv('HOME'), '.local/share/applications'),
		'/usr/local/share/applications',
		'/usr/share/applications'
	]
	suffix = '.desktop'

	results = []
	for p in paths:
		for a in apps:
			fp = os.path.join(p, a) + suffix
			if os.path.exists(fp):
				results.append(_read_desktop_file(fp))
	return results


def listen():
	receivedMessage = getMessage()
	if receivedMessage == 'ping':
		sendMessage({
			'version': VERSION,
			'file': os.path.realpath(__file__)
		})
	elif receivedMessage == 'find':
		sendMessage(find_browsers())
	else:
		for k, v in os.environ.items():
			if k.startswith('MOZ_'):
				try:
					os.unsetenv(k)
				except:
					os.environ[k] = ''

		devnull = open(os.devnull, 'w')
		subprocess.Popen(receivedMessage, stdout=devnull, stderr=devnull)
		sendMessage(None)


if __name__ == '__main__':
	allowed_extensions = [
		'openwith@darktrojan.net',
		'chrome-extension://cogjlncmljjnjpbgppagklanlcbchlno/',
		'chrome-extension://fbmcaggceafhobjkhnaakhgfmdaadhhg/',
	]
	for ae in allowed_extensions:
		if ae in sys.argv:
			listen()
			sys.exit(0)

	print('This is the Open With native helper, version %s.' % VERSION)
	print('Run this script again with the word "install" after the file name to install.')
