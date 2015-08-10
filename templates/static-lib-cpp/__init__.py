class StaticLibTemplate(Template):
	def get_target_dir(self):
		return os.path.join('src', self.get_target_name())

	def do_replacements(self, s):
		import uuid
		s = s.replace('LIBNAME', self.get_target_name())
		s = s.replace('CSARU_RANDOM_GUID', str(uuid.uuid4()))
		return s

	def post_jobs(self):
		# git init and initial commit
		subprocess.call(['git', 'init', '.'])
		subprocess.call(['git', 'add', '-A'])
		subprocess.call(['git', 'commit', '-m', '"Initial commit."'])

global target_template_object
target_template_object = StaticLibTemplate()
