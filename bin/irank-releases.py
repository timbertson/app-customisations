#!/usr/bin/env python
from __future__ import print_function
import irank
from irank.config import IrankOptionParser, IrankApp, config_file
from irank import db as irank_db
import sys, os
import time
import errno
import musicbrainzngs as mb
import itertools
import sqlite3
import logging
import datetime

def to_date(s):
	if isinstance(s, int): s = str(s)
	orig = s
	s = s.replace('/', '-')
	while(len(s)) < 10:
		s += "-01"
	if len(s) == 10:
		year, month, day = map(int, s.split('-'))
		return datetime.date(year=year, month=month, day=day)
	raise ValueError("Unknown date format: %s" % (s,))

TODAY = datetime.date.today()
EPOCH = datetime.date(year=1970, month=01, day=01)
def format_date(date):
	assert isinstance(date, datetime.date), "Not a date: %r" % (date,)
	return date.strftime('%Y-%m-%d')

def init_db(path):
	if os.path.exists(path):
		os.remove(path)
	db = sqlite3.connect(path)
	db.execute('create table artists (name string not null primary key, id string not null, checked date)')
	db.execute('create table releases (artist_id string not null, title string not null, artist string, date string, PRIMARY KEY (artist_id, title))')
	return db

def err(msg):
	print(msg, file=sys.stderr)

def load_db(path):
	if not os.path.exists(path):
		return init_db(path)
	return sqlite3.connect(path)

def make_feed(releases):
	"""
	<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">

<channel>
  <title>W3Schools Home Page</title>
  <link>http://www.w3schools.com</link>
  <description>Free web building tutorials</description>
  <item>
    <title>RSS Tutorial</title>
    <link>http://www.w3schools.com/rss</link>
    <description>New RSS tutorial on W3Schools</description>
  </item>
  <item>
    <title>XML Tutorial</title>
    <link>http://www.w3schools.com/xml</link>
    <description>New XML tutorial on W3Schools</description>
  </item>
</channel>

</rss>
"""
	from xml.dom import minidom as dom
	from urllib import quote
	doc = dom.getDOMImplementation().createDocument(None, "rss", None)
	doc.documentElement.setAttribute("version", "2.0")
	def elem(parent, tag):
		node = doc.createElement(tag)
		parent.appendChild(node)
		return node
	t = lambda s: doc.createTextNode(s.encode('utf-8'))

	channel = elem(doc.documentElement, "channel")
	elem(channel, "title").appendChild(t("Album Releases"))
	for (artist, title, date) in releases:
		item = elem(channel, "item")
		title = "%s: %s" % (artist, title)
		elem(item, "title").appendChild(t(title))
		elem(item, "guid").appendChild(t(title))
		query = quote(" ".join([artist, title]).encode('utf-8'))
		elem(item, 'link').appendChild(t("http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Dpopular&field-keywords=*&rh=n%3A5174%2Ck%3A*".replace('*', query)))
		elem(item, "description").appendChild(t("Released on %s" %(date,)))
	return doc

def populate_db(mbdb, options, irank_db):
	if options.threshold:
		artists = irank_db.execute('select artist from songs where artist <> "" group by artist having count(path) > ? order by count(path)', [options.threshold])
	else:
		artists = irank_db.execute('select artist from songs where artist <> "" group by artist')
	
	if options.target:
		assert options.max_age, "--max-age must be provided when using --target"
		min_date = TODAY - datetime.timedelta(days=options.max_age)
		logging.debug("min_date: %r" % (min_date,))
		# we're not doing all artists, just the `n` oldest
		artists = list(artists)
		logging.debug("total artists: %d", len(artists))
		def age(artist):
			checked = list(mbdb.execute('select checked from artists where name = ?', [artist]))
			if not checked: return EPOCH
			date = checked[0][0]
			if date == 'now':
				# oops...
				return to_date('2015-02-01')
			return to_date(date)
		artists_with_age = [(artist, age(artist[0])) for artist in artists]
		artists_with_age = sorted(artists_with_age, key=lambda pair:pair[1])
		if options.min_age:
			max_date = TODAY - datetime.timedelta(days=options.min_age)
			logging.debug("max_date: %r", max_date)
			artists_with_age = list(itertools.takewhile(lambda pair: pair[1] < max_date, artists_with_age))
			logging.debug(
				"there are %d artists which were checked more than %d days ago" %
				(len(artists_with_age), options.min_age))

		selection = list(itertools.takewhile(lambda pair: pair[1] < min_date, artists_with_age))
		logging.debug(
			"there are %d artists which were checked more than %d days ago" %
			(len(selection), options.max_age))

		if len(selection) > options.target:
			logging.warn(
				"processing %d artists which were checked more than %d days ago" %
				(len(selection), options.max_age))
		else:
			selection = artists_with_age[:options.target]
		artists = [pair[0] for pair in selection]
		# logging.debug('%r', selection)
		logging.debug("Processing %d artists", len(artists))

	now = format_date(TODAY)
	for (artist,) in artists:
		logging.debug("getting ID for artist %s", artist)
		results = mb.search_artists(artist=artist, strict=False, limit=10)['artist-list']
		if len(results) == 0:
			err("WARN: no such artist: %s" % artist)
			continue
		if len(results) > 1:
			logging.info("multiple artists: %s", ' / '.join(list(map(lambda artist: artist['name'], results))))
		result = results[0]
		artist_id = result['id']
		mbdb.execute('insert or replace into artists (name, id, checked) values (?,?,?)', (artist, artist_id, now))
		
		# OK, id saved to the DB now.
		offset=0
		limit=100
		releases = {}
		while True:
			logging.info("getting releases[%d:%d] for artist %s [%s]", offset, offset+limit, artist, artist_id)
			recordings = mb.browse_releases(artist=artist_id, release_type=['album', 'ep'], includes=['url-rels'], offset=offset, limit=limit)['release-list']
			# recordings = sorted(recordings, key=lambda rec: rec.get('date', ''))
			logging.info("got %d recordings", len(recordings))
			for title, recordings in itertools.groupby(recordings, lambda x: x['title']):
				recordings = list(recordings)
				dates = list(map(lambda rec: rec.get('date', ''), recordings))
				# err(repr((title, dates)))
				longest_timestamp = len(max(dates))
				if not longest_timestamp:
					continue
				earliest_date = min(filter(lambda date: len(date) == longest_timestamp, dates))
				if title in releases and releases[title] <= earliest_date:
					continue
				releases[title] = earliest_date
			if len(recordings) < limit: break # we got less than `limit`, so there aren't any more
			offset += len(recordings)

		for title, date in sorted(releases.items(), key=lambda pair:pair[1]):
			date = format_date(to_date(date))
			mbdb.execute('insert or replace into releases (artist_id, title, artist, date) VALUES (?,?,?,?)', (artist_id, title, artist, date))
			# err("%s - %s (released %s)" % (artist, title, date))
		mbdb.execute('update artists set checked=? where name=? and id=?', (now, artist, artist_id))
		mbdb.commit()

def main():
	parser = IrankOptionParser()
	parser.add_option('--threshold', default=5, type='int', help='include only artists with at least THRESHOLD files in collection')
	parser.add_option('--target', type='int', help='update only TARGET artists and then exit')
	parser.add_option('--max-age', metavar='DAYS', type='int', help='if --target is given, also update all artists which haven\'t been updated in DAYS days')
	parser.add_option('--min-age', metavar='DAYS', type='int', help='if --target is given, ignore artists which have been checked within DAYS days')
	parser.add_option('--update-only', help='don\'t print RSS feed', action='store_true')
	parser.add_option('--full', help='wipe existing DB', action='store_true')
	parser.add_option('--quick', help='don\'t update DB if it already exists', action='store_true')
	options, args = parser.parse_args()
	logging.basicConfig(level=logging.DEBUG if options.verbose else logging.WARN)

	app = IrankApp(options)
	mb_path = os.path.join(app.base_path, 'musicbrainz.sqlite')

	if options.full:
		try:
			os.unlink(mb_path)
		except OSError as e:
			if e.errno != errno.ENOENT: raise

	existing = os.path.exists(mb_path)
	mbdb = (load_db if existing else init_db)(mb_path)
	version = irank.version()
	mb.set_useragent("irank", version, "https://github.com/gfxmonk/python-irank")
	logging.debug("setting rate limit to 2/s")
	mb.set_rate_limit(new_requests = 2)
	try:
		if not (existing and options.quick):
			db = irank_db.load(app.db_path)
			populate_db(mbdb, options, db)
			db.close()

		if not options.update_only:
			releases = mbdb.execute('''select
				artist, title, date
				from releases
				order by date desc
				limit 100''')
			doc = make_feed(releases)
			print(doc.toprettyxml())
	finally:
		mbdb.close()

if __name__=='__main__':
	sys.exit(main())
