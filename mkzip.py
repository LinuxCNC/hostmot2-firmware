import sys
import zipfile


zipname, pattern, replacement = sys.argv[1:4]
members = sys.argv[4:]

z = zipfile.ZipFile(zipname, 'w', compression=zipfile.ZIP_DEFLATED)
for m in members:
    zfn = m.replace(pattern, replacement)
    z.write(m, zfn)
z.close()
