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

import fileinput
import os
import shutil

import templates


def copy_assets(source_dir, dest_dir):
	shutil.copytree(source_dir, dest_dir)

def new_from_template(template_dir, template):
	dest_dir = os.path.join(os.getcwd(), '..', template.get_target_dir())

	# copy whole 'assets' tree wholesale to destination
	copy_assets(os.path.join(template_dir, 'assets'), dest_dir)

	# update files in the destination
	for (dirpath, dirnames, filenames) in os.walk(dest_dir):
		for filename in filenames:
			# replace each 'replacements' in files in the destination
			for line in fileinput.input(os.path.join(dirpath, filename), inplace=True):
				print(template.do_replacements(line), end='')
				'''
				for key, val in replacements:
					line = line.replace(key, val)
				print(line, end='')
				'''

			# rename files with 'LIBNAME' using user's given machine-friendly name
			new_filename = template.do_replacements(filename)
			if new_filename != filename:
				os.rename(
					os.path.join(dirpath, filename),
					os.path.join(dirpath, new_filename)
				)

	original_dir = os.getcwd()
	os.chdir(dest_dir)
	# post jobs
	template.post_jobs()
	os.chdir(original_dir)

def main():
	template_options = []
	for (dirpath, dirnames, filenames) in os.walk(os.getcwd()):
		for dirname in dirnames:
			if not dirname.startswith('__') and not dirname.startswith('.'):
				template_options.append(dirname)
		break
	print('Select a template...')
	for i in range(len(template_options)):
		print(i + 1, '--', template_options[i])
	template_choice = 0
	while template_choice < 1 or template_choice > len(template_options):
		template_choice = int(input('Template number (%d-%d): ' % (1, len(template_options))))
	template_choice -= 1

	template = templates.use_template(template_options[template_choice])
	new_from_template(template_options[template_choice], template)

if __name__ == "__main__":
	main()
