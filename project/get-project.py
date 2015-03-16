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


repo_sources = [
	'https://api.github.com/users/Akaito/repos?type=all',
]


class Repo:
	@classmethod
	def from_github_json(cls, jsn):
		r = cls()
		r.name = jsn['name']
		r.title = r.name[len('codesaru-environ_project_'):]
		r.description = jsn['description']
		r.clone_url = jsn['clone_url']
		return r

	def __repr__(self):
		return self.title


def find_repos(jsn):
	repos = []
	for repo_jsn in jsn:
		r = Repo.from_github_json(repo_jsn)
		if r is None:
			continue
		if 'codesaru-environ_project_' not in r.name:
			continue
		repos.append(r)
	return repos


def main():
	global repo_sources

	repos = []
	for repo_source_url in repo_sources:
		response = request.urlopen(repo_source_url)
		response_content = response.read()
		repos_jsn = json.loads(response_content.decode())
		repos.extend(find_repos(repos_jsn))

	# present list of codesaru-environ/project compatible repos
	for i in range(len(repos)):
		print(i + 1, '--', repos[i].title)
		print('   ', repos[i].description)

	user_choice = 0
	while int(user_choice) < 1 or int(user_choice) > len(repos):
		user_choice = input('Enter project number to download: ')
	user_choice = int(user_choice) - 1

	repo = repos[user_choice]
	subprocess.call(['git', 'clone', repo.clone_url, repo.title])

if __name__ == "__main__":
	prior_dir = os.getcwd()
	main()
	os.chdir(prior_dir)
