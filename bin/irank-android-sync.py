#!/usr/bin/env python3
import optparse
import os
import sys
import subprocess
import tempfile
import shutil

def run(fn, cmd, **k):
	print(' + ' + repr(cmd))
	return fn(cmd, **k)

def irank_exe():
	# use locally-built irank, if present
	env_irank = os.environ.get('IRANK_EXE')
	if env_irank is not None:
		return env_irank
	dev_irank = os.path.expanduser('~/dev/python/irank/result/bin/irank')
	if os.path.exists(dev_irank):
		return dev_irank
	else:
		return 'irank'

def load_paths():
	ret={}
	with open(os.path.expanduser("~/.config/irank/paths")) as f:
		lines = f.readlines()
		for line in lines:
			key, value = line.split(':', 1)
			key = key.strip()
			value = value.strip()
			if key.startswith('#'): continue
			ret[key] = os.path.expanduser(value)
	return ret

def num_remote_rating_changes(local_db):
	if os.path.exists(local_db):
		out = run(subprocess.check_output, [irank_exe(), 'rating-sync', '--count', local_db])
		return int(out.decode('utf-8').strip())
	else:
		return 0

def overwrite_android_db(opts):
	# note we sync to the _music_ dest, not the DB source (that's never written to, to avoid conflicts)
	host, path = split_host(opts.music_dest)
	source = os.path.join(opts.irank_base, 'irank.sqlite')
	dest = os.path.join(opts.music_dest, 'irank.sqlite')
	print('copying %s -> %s' % (source, dest))
	ssh(dest, lambda p: 'mkdir -p %s' % os.path.dirname(p))
	if host is None:
		shutil.copyfile(source, dest)
	else:
		run(subprocess.check_call, ['scp', source, dest])

def apply_remote_rating_changes(opts, local_db):
	print("updating ratings from device")
	num_updates=num_remote_rating_changes(local_db)
	if num_updates > 0:
		print("applying %d remote updates..." % num_updates)
		run(subprocess.check_call, [irank_exe(), 'rating-sync', '--no', local_db])
			# TODO do this on failure
			# zenity --question --no-markup --text='Rating update FAILED. Do you want to continue, ERASING all failed ratings?' --cancel-label='Cancel' --ok-label='ERASE' && \
			# 	zenity --question --no-markup --text='SERIOUSLY?' --cancel-label='No!' --ok-label='Yes, ERASE ratings')
		print("updating playlists after rating update")
		if not opts.no_update_db:
			run(subprocess.check_call, [irank_exe(), 'db'])

def do_sync(opts):
	with open(os.path.expanduser('~/.config/irank/android-playlists')) as conf:
		playlists = []
		for line in conf.readlines():
			if line.startswith('#'): continue
			playlists.append(line.strip())
	
	run(subprocess.check_call, [irank_exe(), 'export', '--dest', opts.music_dest,
		'--no-checksum',
		'--limit', '4.0',
		'--merge', os.path.expanduser('~/Music/Library/Other/Phone/'),
		'--leave-ext', 'sqlite',
		'--leave-name', '.stfolder',
		'--leave-name', '.gup',
		'--'] + playlists)

	print('-------- DISK USAGE: -----------')
	size=ssh(opts.music_dest, lambda p: 'du -hs %s' % p).split()[0]
	# remaining=$(df -h "$dest" | tail -n1 | awk '{print $4}')
	run(subprocess.check_call, ['notify-send', "Android music sync finished", "%s used for %s" % (size, opts.music_dest)])

def split_host(dest):
	if ':' in dest:
		return dest.split(':', 1)
	else:
		return (None, dest)

def ssh(dest, cmd):
	(host, path) = split_host(dest)
	if host is not None:
		# remote
		host, _ = dest.split(':')
		out = run(subprocess.check_output, ['ssh', host, '--', cmd(path)])
	else:
		out = run(subprocess.check_output, ['bash', '-c', cmd(path)])
	return out.decode('utf-8').strip()

def main():
	p = optparse.OptionParser()
	p.add_option('--quick', action='store_true')
	p.add_option('--no-update-db', action='store_true')
	p.add_option('--no-read-android-ratings', action='store_true')
	p.add_option('--headless', action='store_true')
	opts, args = p.parse_args()
	paths = load_paths()
	if args:
		(opts.music_dest,) = args
	else:
		opts.music_dest = paths['android']
	opts.irank_base = paths['irank']

	opts.db_source = paths.get('android-db', opts.music_dest)
	if not opts.no_read_android_ratings:
		has_db = ssh(opts.db_source, lambda p: 'if [ -f "%s"/irank.sqlite ]; then echo YES; else echo NO; fi' % p)
		print('has_db = %r' % has_db)
		if has_db == 'YES':
			with tempfile.NamedTemporaryFile() as db:
				run(subprocess.check_call, ['scp', opts.db_source+'/irank.sqlite', db.name])
				apply_remote_rating_changes(opts, db.name)
		overwrite_android_db(opts)
	if not opts.quick:
		do_sync(opts)

main()
