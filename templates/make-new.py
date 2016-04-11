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
