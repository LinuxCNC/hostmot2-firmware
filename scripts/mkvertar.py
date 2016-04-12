#!/usr/bin/python
import tarfile
import sys
import StringIO
import time

tarname, version = sys.argv[1:]

tardata = sys.stdin.read()
tarstream = StringIO.StringIO(tardata)

verstream = StringIO.StringIO(version+"\n")
verinfo = tarfile.TarInfo("%sVERSION" % tarname)
verinfo.mode = 0664
verinfo.size = len(verstream.getvalue())
verinfo.mtime = time.time()

tar = tarfile.TarFile(mode='a', fileobj=tarstream)
tar.addfile(verinfo, verstream)
tar.close()

sys.stdout.write(tarstream.getvalue())
