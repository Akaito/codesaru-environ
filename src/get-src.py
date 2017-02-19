#!/usr/bin/python3
"""
Copyright (c) 2016 Christopher Higgins Barrett

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgement in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
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
		r.title = r.name
		if r.title.startswith('codesaru-environ_src_'):
			r.title = r.title[len('codesaru-environ_src_'):]
		elif r.title.startswith('csaru-'):
			r.title = r.title[len('csaru-'):]
		r.description = jsn['description']
		r.clone_url = jsn['clone_url']
		r.ssh_url = jsn['ssh_url']
		return r

	def __repr__(self):
		return self.title


def find_repos(jsn):
	repos = []
	for repo_jsn in jsn:
		r = Repo.from_github_json(repo_jsn)
		if r is None:
			continue
		if not r.name.startswith('codesaru-environ_src_') and not r.name.startswith('csaru-'):
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

	# present list of codesaru-environ/src compatible repos
	longest_title = 0
	for i in range(len(repos)):
            longest_title = max(longest_title, len(repos[i].title))
	for i in range(len(repos)):
	    print("{:3} -- {:<{}} {} {}".format(i+1, repos[i].title, longest_title, '--', repos[i].description))

	user_choice = 0
	while True:
		while int(user_choice) < 1 or int(user_choice) > len(repos):
			user_choice = input('Enter src number to download: ')
		repo = repos[int(user_choice) - 1]
		user_choice = 0

		#subprocess.call(['git', 'clone', repo.clone_url, repo.title])
		subprocess.call(['git', 'clone', repo.ssh_url, repo.name])

if __name__ == "__main__":
	prior_dir = os.getcwd()
	main()
	os.chdir(prior_dir)
