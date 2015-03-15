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

import os
import re
import subprocess  # used by child templates


target_template_object = None


class Template:
	def __init__(self):
		self.target_name = None

	def get_target_name(self):
		while self.target_name is None:
			n = input('Target name (machine-friendly): ')
			if self.validate_target_name(n):
				self.target_name = n
		return self.target_name

	def validate_target_name(self, n):
		reg = re.compile('^[a-zA-Z0-9-]+$')
		return reg.match(n) is not None

	def get_target_dir(self):
		return None

	def do_replacements(self, s):
		return s

	def post_jobs(self):
		pass


def use_template(template_dir):
	global target_template_object

	with open(os.path.join(template_dir, '__init__.py')) as f:
		code = compile(f.read(), template_dir, 'exec')
		exec(code)

	return target_template_object
