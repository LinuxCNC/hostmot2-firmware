import glob
import os
import re
import string
import sys
import time

settings_sh = None

def subst(in_, out, **kw):
    def rfn(m):
        g = m.group(1)
        if g == '': return '@'
        return kw[g.upper()]
    r = re.compile("@([^@]*)@")
    s = open(in_).read()
    s = r.sub(rfn, s)
    open(out, "w").write(s)

_sq_whitelist = string.lowercase + string.uppercase + string.digits + ".-_/"
def sq(a):
    if not a.strip(_sq_whitelist):
        return a
    return "'" + a.replace("'", "'\\''") + "'"

timing = []

def run(*args):
    cmd = " ".join(sq(a) for a in args)
    if settings_sh is None:
        raise RuntimeError, "Must call use_ise() before run()"
    # xilinx 13.3's settings32.sh uses bashisms
    cmd = "bash -c '. %s; %s'" % (settings_sh, cmd)
    print "#", cmd
    sys.stdout.flush()
    t0 = time.time()
    r = os.system(cmd)
    print "# exited with", r; sys.stdout.flush()
    t1 = time.time()
    timing.append((args[0], (t1-t0)))
    if r:
        raise SystemExit, os.WEXITSTATUS(r) or 1

def guess_ise_version():
    with os.popen("map -h | head -1") as p:
        info = p.read()
        info = info.split()[1].split(".")[0]
        try:
            return int(info)
        except:
            return None

def use_ise(iseversions):
    global settings_sh
    # Xilinx Webpack 10.1 and 13.3 both install into /opt/Xilinx/,
    # into 10.1/ and 13.3/.
    # 10.1's settings are in ISE/settings32.sh
    # 13.3's settings are in ISE_DS/settings32.sh
    for ise in iseversions:
        localsettings = os.path.abspath("settings%d.sh" % ise)
        if os.path.exists(localsettings):
            if os.path.islink(localsettings): localsettings = os.readlink(localsettings)
            settings_sh = localsettings
            break

        files = glob.glob('/opt/Xilinx/%s/*/settings64.sh' % ise)
        if len(files) > 1:
            print "multiple settings files found!", files
            raise SystemExit, 1
        if len(files) == 1:
            settings_sh = files[0]
            break

        files = glob.glob('/opt/Xilinx/%s.*/*/settings64.sh' % ise)
        if len(files) == 1:
            settings_sh = files[0]
            break
        if len(files) > 1:
            # use the newest one: sort by minor version since the major versions are all the same
            files = sorted(files, key=lambda f: int((f.split('/')[3]).split('.')[1]))
            settings_sh = files[-1]
            break

    else:
        raise SystemExit("Firmware requires one of these ise major versions to build: %s"
                % " ".join(map(str, iseversions)))

    print "using Xilinx Webpack settings '%s'" % settings_sh

def report_timing():
    t =  m =  s = 0
    for k, v in timing:
        t += v
        m, s = divmod(v, 60)
        print "%d:%04.1f-%-11s" % (m, s, k),
    print "%d:%04.1f-total" % (m, s)
    print

