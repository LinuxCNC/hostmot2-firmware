import sys
import tarfile
import gzip
import os

tarname, pattern, replacement = sys.argv[1:4]
members = sys.argv[4:]

gz = gzip.open(tarname+".tmp", 'wb')
z = tarfile.TarFile(tarname, 'w', fileobj=gz)
for m in members:
    zfn = m.replace(pattern, replacement)
    z.add(m, zfn)
z.close()
gz.close()
os.rename(tarname+".tmp", tarname)
