#!/usr/bin/python

import re
import sys
import urllib
import ConfigParser

##
# Class parsing command line or .ini configuration files to generate static
# HTML pages from a skeleton and a body file, plus placeholders.
#
# @author: Bogdan Roman
# @version: 1.1.2
#
class dtgStatic:

	# defaults (should be constants)
	
#	debug = False
	debug = True
	skel_url = 'https://www.cl.cam.ac.uk/research/dtg/www/skel/'
	config = None
	maps = {}

	def __init__ (self):
		
		try:
			if len(sys.argv) < 2 or '-h' in sys.argv or '--help' in sys.argv:
				self.help()
			elif re.search('(?i)\.ini$', sys.argv[1]):
				self.parseini(sys.argv[1])
				self.makeini()
			else:
				self.parseargv()
				self.make()
		except Exception, e:
			if self.debug:
				raise
			sys.stderr.write(str(e))


	def make (self):
		"""Build one webpage using the options in self.maps"""
		if 'out' in self.maps:
			sys.stderr.write("Building {0} ...\n".format(self.maps['out']))
		self.fetch()
		self.replace()


	def makeini (self):
		"""Build all webpages in the ini file"""
		for section in self.config.sections():
			self.maps = dict(self.config.items(section))
			self.make()


	def readfile (self, filepath, die = True, list = False):
		contents = ''
		try:
			with open(filepath) as f:
				contents = f.readlines() if list else f.read()
		except:
			if die:
				raise
		return contents


	def info (self, message):
		sys.stderr.write('-> ' + message + '\n')


	def parseini (self, inifile):
		self.config = ConfigParser.ConfigParser({'skel': '<' + self.skel_url})
		self.config.readfp(open(inifile))

		for section in self.config.sections():
			if not self.config.has_option(section, 'body'):
				self.config.set(section, 'body', '<' + section)
			if not self.config.has_option(section, 'out'):
				reout = re.compile('(?i)[_.-]tpl([^a-z].*)$')
				if not reout.search(section):
					raise Exception('[{0}] Section {1} must have an option out=filename '
						'or alternatively contain "-tpl" or "_tpl" or ".tpl" in the section name, '
						'e.g. [about/index-tpl.html].'.format(inifile, section))
				self.config.set(section, 'out', reout.sub('\\1', section))

	def parseargv (self):
		"""Parse and sanitize command line arguments"""
		valid = re.compile('\w+=.+|skel=?$')
		for arg in sys.argv[1:]:
			if not valid.match(arg):
				raise Exception('Invalid command-line parameter: {0}\n'
							'See {0} -h for syntax.'.format(arg, '-h'))

		if sys.argv[1].lower() == 'skel':
			print self.fetchurl(self.skel_url)
			sys.exit(0)

		for arg in sys.argv[1:]:
			tpl, val = (arg.split('=', 2)+[''])[0:2] # trick to ensure a tuple
			self.maps[tpl.lower()] = val
		
		if not 'skel' in self.maps:
			self.maps['skel'] = '<' + self.skel_url
			self.info('Missing option "skel=<value>". Assuming skel=' + self.maps['skel'] + ' ...')
		
		if not 'out' in self.maps:
			self.info('Missing option "out=<file>". Will output to stdout ...')
		
		if not 'body' in self.maps:
			raise Exception('Missing mandatory option "body=value".')
			#self.info('Missing body=<value>. Skipping the "body" placeholder ...')
			#self.maps['body'] = ''

			
	def fetch (self):
		"""Fetch content"""
		# do skel, body and sidebar first
		self.maps['skel'] = self.fetchvalue(self.maps['skel'])
		self.maps['body'] = self.fetchvalue(self.maps['body'])
		#self.maps['sidebar'] = self.sidebar(self.maps['sidebar'])
		
		for key in self.maps:
			#if key != 'skel' and key != 'body' and key != 'sidebar':
			if key != 'skel' and key != 'body':
				self.maps[key] = self.fetchvalue(self.maps[key])
		

	def fetchvalue (self, value):
		rest = re.compile('^[<!%]\s*')
		# re.match() only matches at the start of string
		if re.match('sidebar:', value):
			return self.sidebar(self.fetchvalue(re.sub('^sidebar:\s*', '', value)))
		elif re.match('<\s*(https?|ftp)://[^>]+$', value): 
			return self.fetchurl(rest.sub('', value))
		elif re.match('<[^>]+$', value):
			return self.fetchfile(rest.sub('', value))
		elif value.find('!') == 0:
			return Popen(shlrex.split(rest.sub('', value)), stdout=PIPE).communicate()[0]
		elif value.find('%') == 0:
			return eval(rest.sub('', value))
		else:
			return re.sub('\\\\([<!%])', '\1', value) # unescape start chars 
		
	
	def fetchurl (self, url):
		self.info('Retrieving ' + url + ' ...')
		return self.readfile(urllib.urlretrieve(url)[0]) # this normally caches the file too


	def sidebar (self, contents):
		sbre = re.findall('(?m)^TPL_SB_PCRE.\d=(.*)', self.maps['skel'])
		sbrepl = re.findall('(?m)^TPL_SB_REP.\d=(.*)', self.maps['skel'])
		for n, r in zip(sbre, sbrepl):
			contents = re.sub(n, r, contents)
		contents = re.sub(r'\\,', ',', contents)
		contents = re.sub('(?m)^\s*#.*\r?\n?', '', contents)
		return contents

	def fetchfile (self, file):
		"""Read file contents and parse it according to #! header comment
		or return the contents if no #! header comment exists"""
		
		contents = self.readfile(file)
		
		if contents.find('#!sidebar') == 0:
			# csv = re.compile('\s*(?<!\\\),\s*')
			# syn = csv.split(re.search('(?m)^TPL_SB.SYN=(.*)', self.html).group(1))
			# entry = re.findall('(?m)^TPL_SB.(\d)=(.*)', self.html)
			# sidebar = ""
			# for line in re.split('(?:\r?\n)+', readfile(file)):
				# if not re.match('^\s*(?:#|//|$)', line):
					# fields = csv.split(line)
					# sidebar += multisub(syn, fields, entry[int(fields[0])][1]) + '\n'

			contents = self.sidebar(contents)
			
		return contents;


	def replace (self):
		"""Replace in placeholders"""

		outfile = self.maps.pop('out', '');
		html = self.maps.pop('skel')
		
		# replace body first since we're not sure the user put it first in the options list
		#html = re.sub('(?i)(\s*)<!--TPL_BODY-->', '\\1<div class="static-content">\n' + self.maps['body'] + '\n\\1</div>\n', html)
		html = re.sub('(?i)(\s*)<!--TPL_BODY-->', '\\1\n' + self.maps['body'] + '\n\\1\n', html)

		for key in self.maps:
			html = re.sub('(?smi)<!--TPL_{0}_START-->.*?<!--TPL_{0}_END-->'.format(key.upper()), self.maps[key], html)
			html = re.sub('(?i)<!--TPL_{0}-->'.format(key.upper()), self.maps[key], html)
		
		# delete leftovers
		html = re.sub('(?smi)<!--TPL_(\w+_)?DEL_START-->.*?<!--TPL_(\w+_)?DEL_END-->', '', html)
		html = re.sub('(?smi)<!--TPL_.*?-->', '', html)
		
		if outfile:
			try:
				with open(outfile, 'r') as rf:
					with open(outfile + '~', 'w') as wf:
						wf.write(rf.read())
			except IOError as (errno, strerror):
				if errno != 2: # file not found
					raise
			with open(outfile, 'w') as of:
				of.write(html)
		else:
			print html
	

	def help(self):
		print """
Syntax: {0} OPTION [OPTION ...]

Options are in the form "option=value" except the following:

  <ini_file>
      Filename with .ini extension, e.g. build.ini, that contains all options
      in INI format. Use this to set options and build multiple pages in one go
  
  skel[=value]
      With no value, "skel" will fetch the website skeleton from the default
      url {1} and output it to stdout.
      
  -h or --help
      This help screen.
  
You can pass the same command-line options that you can in a [section] in the
build.ini file. In command-line mode, proper quoting needs to be used so that
the shell does not interpret characters like "<" or "`" or spaces. Example:

  {0} skel="<skel.html" body="<index.tpl" updated="1 Dec 2007"

See the sample BUILD.INI file for all options, values, features and syntax. 
""".format(sys.argv[0], self.skel_url)
		sys.exit(0)

#-------------------------------------------------------------------- end class

dtgStatic()
