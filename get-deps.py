"""
The MIT License (MIT)

Copyright (c) 2015 Christopher Higgins Barrett

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

import json
import os
import subprocess
from urllib import request


class Repo:
	def __repr__(self):
		return '<Repo>'


class GithubRepo(Repo):
	def __init__(self, jsn):
		self.name = jsn['name']
		self.description = jsn['description']
		self.clone_url = jsn['clone_url']

	def __repr__(self):
		return '<GithubRepo %s>' % self.name

	def to_basic_module_object(self):
		return {
			'name': self.name,
			'description': self.description,
			'type': 'git',
			'data': {
				'clone_url': self.clone_url
			}
		}


def check_source_github_user(result, src_data_jsn):
	api_url = 'https://api.github.com/users/%s/repos?type=all' % src_data_jsn['user']
	print(api_url)

	response = request.urlopen(api_url)
	response_content = response.read()
	repos_jsn = json.loads(response_content.decode())
	for repo_jsn in repos_jsn:
		r = GithubRepo(repo_jsn)
		if r is None:
			continue
		if 'codesaru-environ_src_' not in r.name:
			continue
		result.append(r)


def check_source(result, src_jsn):
	print(src_jsn)
	if src_jsn['type'] == 'githubUser':
		check_source_github_user(result, src_jsn['data'])


def walk_sources(result, sources_jsn):
	for src_jsn in sources_jsn:
		check_source(result, src_jsn)


def main():
	result = []
	with open('module-sources.json') as f:
		jsn = json.load(f)
		walk_sources(result, jsn['sources'])
	final = {'sources': []}
	for r in result:
		final['sources'].append(r.to_basic_module_object())
	# TODO : write to modules-dir.json
	print(json.dumps(final, sort_keys=True, indent=4))

if __name__ == "__main__":
	main()
