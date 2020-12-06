#!/bin/bash 
clear
echo '|==================================================================='
echo '| 4.2BSD simh builder shell script                          v. 1.0 |'
echo '|                                                                  |'
echo '| ██╗  ██╗   ██████╗     ██████╗ ███████╗██████╗                   |'
echo '| ██║  ██║   ╚════██╗    ██╔══██╗██╔════╝██╔══██╗                  |'
echo '| ███████║    █████╔╝    ██████╔╝███████╗██║  ██║                  |'
echo '| ╚════██║   ██╔═══╝     ██╔══██╗╚════██║██║  ██║                  |'
echo '|      ██║██╗███████╗    ██████╔╝███████║██████╔╝                  |'
echo '|      ╚═╝╚═╝╚══════╝    ╚═════╝ ╚══════╝╚═════╝                   |' 
echo '| based on http://plover.net/~agarvin/4.2bsd.html                  |' 
echo '| based on https://gunkies.org/wiki/Installing_4.2_BSD_on_SIMH     |' 
echo '|                                                                  |'
echo '| Tested on Ubuntu 20.04 amd64 - Debian based                      |'  
echo '|                                                                  |'
echo '| needs working gcc,curl,make,truncate and git                     |'
echo '|                                                                  |'
echo '| To build simh/vax780 we also need the following on Debian/Ubuntu |'  
echo '| apt-get install libpcap-dev libpcre3-dev vde2 libsdl2 libsdl2_ttf|'
echo '|                                                                  |'
echo '| by Astr0baby  https://twitter.com/astr0baby                      |' 
echo '|==================================================================|'
echo ""
read -p "Press enter to continue or break ctrl+c"

# Lame check if gcc,curl, make and git are installed - we need these 

if ! [ -x "$(command -v gcc)" ]; then
  echo '[-] Error: gcc is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo '[-] Error: curl is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v git)" ]; then
  echo '[-] Error: curl is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v make)" ]; then
  echo '[-] Error: make is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v truncate)" ]; then
  echo '[-] Error: truncate is not installed.' >&2
  exit 1
fi


# Cleanup 
rm -rf 4.2BSD-temp 

# Lets dump the README.TXT 
cat <<EOF >  README.TXT
#######################################################
## These steps are to be executed inside the simulator
#######################################################

 -> 1st stage install
----------------------------------------------------
When install.sh runs 

# cd /dev
# ./MAKEDEV ra1
# cd /
# disk=ra1 type=ra81 tape=ts xtr

# sync
# sync
# sync

CTRL+E    (stop the sim) 
sim> q    (exit the sim) 




######################################################
  -> 2nd stage install
-----------------------------------------------------
When install2.sh runs 

# disk=ra
# name=ra0h;type=ra81
# cd /dev
# ./MAKEDEV ts0;sync
# cd /
# newfs \$name \$type

# mount /dev/\$name /usr
# cd /usr
# mkdir sys
# cd sys
# mt rew
# mt fsf 3
# tar xpbf 20 /dev/rmt12
# cd ..
# mt fsf
# tar xpbf 20 /dev/rmt12
# cd /
# chmod 755 / /usr /usr/sys
# rm -rf sys
# ln -s /usr/sys sys
# umount /dev/\$name
# fsck /dev/r\$name

# cd /etc
# cp fstab.ra81 fstab
# newfs ra0g ra81
# sync
# reboot
sim> q 


#####################################################
3nd stage install
-----------------------------------------------------

when install3.sh runs
Login as root (no password is set) 

# mkdir /drivers
# cd /drivers
# mt rew
# tar xvpb 20
# cp if_de.c if_dereg.h /sys/vaxif
# cp GENERIC files.vax /sys/conf
# cd /sys/conf 
# config GENERIC 
# cd /sys/GENERIC
# make clean
# config GENERIC
# make depend
# make

# mv /vmunix /vmunix.orig
# cp vmunix /
# halt

######################################################
Final stage 
------------------------------------------------------

run boot.sh 
Login as root (no password is set - create one) 
Now lets create the network interface 
and we will connect to ARPANET :) 
Adjust accordingly 

# echo '10.0.2.100 bsd42' > /etc/hosts
# echo 'home 10.0.2' > /etc/networks 
# /bin/hostname bsd42
# /etc/ifconfig de0 up
# /etc/ifconfig de0 arp
# /etc/ifconfig de0 bsd42 

Next create pty devices in /dev 

# cd /dev
# ./MAKEDEV pty0 
# ./MAKEDEV pty1 
# ./MAKEDEV pty2 

To make network config persistent 

# echo '/bin/hostname bsd42' > /etc/network.sh
# echo '/etc/ifconfig de0 up' >> /etc/network.sh
# echo '/etc/ifconfig de0 arp' >> /etc/network.sh
# echo '/etc/ifconfig de0 bsd42' >> /etc/network.sh
# chmod +x /etc/network.sh 
# echo '/etc/network.sh' >> /etc/rc.local 

EOF

# Lets prepare the working environment
mkdir 4.2BSD-temp 
cd 4.2BSD-temp 

# Download the distribuition
echo ""
echo '[*] Downloading 4.2BSD from tuhs.org (The UNIX Heritage Society)'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.2BSD/ingres.tar.gz
echo 'ingres.tar.gz'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.2BSD/miniroot.gz
echo 'miniroot.gz'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.2BSD/new.tar.gz
echo 'new.tar.gz'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.2BSD/rootdump.gz
echo 'rootdump.gz'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.2BSD/src.tar.gz
echo 'stc.tar.gz'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.2BSD/srcsys.tar.gz
echo 'srcsys.tar.gz'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.2BSD/stand.gz
echo 'stand.gz'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.2BSD/usr.tar.gz
echo 'usr.tar.gz'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.2BSD/vfont.tar.gz
echo 'vfont.tar.gz'
echo ''
echo '[*] Unzipping...'
gzip -d *.gz 

# Dump the tape create program 
cat <<EOF >  mk-dist-tape.py
#!/usr/bin/python

# General version of mkdisttap.pl
# v. 0.1 20171026 Allen Garvin (aurvondel@gmail.com) 
# BSD license

import argparse, struct, sys

def main(args, ap):
    tape_str = ""

    for f in args.file:
        if ":" in f:
            fn = f.split(":")[0]
            bs = f.split(":")[1]
            if not bs.isdigit():
                ap.print_help()
                print("\nERROR: {0} in {1} is not positive integer for blocksize".format(bs, f))
                sys.exit(1)
            bs = int(bs)
        else:
            fn = f
            bs = args.blocksize

        try:
            fd = open(fn, "r")
        except IOError as e:
            print("{0}: errno {1}: {2}".format(fn, e.errno, e.strerror))
            sys.exit(1)
        except:
            print("{0}: unexpected error: {1}".format(fn, sys.exc_info()[0]))
            sys.exit(1)
        
        flag = True
        while flag:
            s = fd.read(bs)
            if len(s) == 0:
                break
            if len(s) < bs:
                s += b"\x00" * (bs-len(s))
                flag = False
        
            f_len = struct.pack("<I", bs)
            tape_str += f_len + s + f_len
        tape_str += b"\x00" * 4
    tape_str += b"\x00" * 4

    if args.output:
        try:
            ofd = open(args.output, "w")
        except IOError as e:
            print("{0}: errno {1}: {2}".format(args.output, e.errno, e.strerror))
            sys.exit(1)
        except:
            print("{0}: unexpected error: {1}".format(args.output, sys.exc_info()[0]))
            sys.exit(1)
        ofd.write(tape_str)
    else:
        sys.stdout.write(tape_str)

            
            

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create distribution tapes for simh")
    parser.add_argument("--blocksize", "-b", type=int, help="default block size (unset, def is 10240)", default=10240)
    parser.add_argument("-output", "-o", metavar="FILE", help="output to file (if omitted, sends to stdout)")
    parser.add_argument("file", nargs="+", help="files to add in order (append with :bs where bs is block size if diff from default)")
    args = parser.parse_args()
    main(args, parser)
EOF

echo ''
echo '[*] Creating tape image..'
python2 ./mk-dist-tape.py -o 4.2bsd.tape stand:512 miniroot rootdump srcsys.tar usr.tar vfont.tar src.tar new.tar ingres.tar

RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo '[*] Tape image created ok'  
else
  echo '[-] Something went wrong .. check output' 
  exit 
fi

rm -f *.tar
 
cat <<EOF > gzcompat.c 

#ifndef lint
static char sccsid[] = "@(#)gzcompat.c	5.2 (Berkeley) 12/21/00";
#endif

/* gzcompat converts between compress -s and gzip formats. */

#include <stdio.h>

char magic_strong[2] = {037, 0241};
char magic_gzip[2]   = {037, 0213};

struct gzheader {
	unsigned char cm;
	unsigned char flg;
	unsigned char mtime[4];
	unsigned char xfl;
	unsigned char os;
} gzheader;

#define CM_DEFLATE 0x08

#define FTEXT    0x01
#define FHCRC    0x02
#define FEXTRA   0x04
#define FNAME    0x08
#define FCOMMENT 0x10
#define FRSVD    0xE0

#define OS_UNIX 0x03

int main(argc, argv)
	char **argv;
{
	FILE *infile;
	char *inname;
	char buf[4096];
	int len;
	int mkgzip;

	if (argc == 1) {
		infile = stdin;
		inname = "stdin";
	} else if (argc == 2) {
		inname = argv[1];
		infile = fopen(inname, "r");
		if (infile == NULL) {
			perror(inname);
			exit(1);
		}
	} else {
		fprintf(stderr, "usage: %s [infile]\n", argv[0]);
		exit(1);
	}

	/* First read the input magic number. */
	len = fread(buf, 1, 2, infile);
	if (len < 0) {
		perror(inname);
		exit(1);
	}
	if (len != 2) {
		fprintf(stderr, "%s: not in compress -s or gzip format\n",
			inname);
		exit(1);
	}
	if (buf[0] == magic_strong[0] && buf[1] == magic_strong[1])
		mkgzip = 1;
	else if (buf[0] == magic_gzip[0] && buf[1] == magic_gzip[1])
		mkgzip = 0;
	else {
		fprintf(stderr, "%s: not in compress -s or gzip format\n",
			inname);
		exit(1);
	}

	/* Now read and check the gzip header if necessary. */
	if (!mkgzip) {
		len = fread(&gzheader, sizeof(struct gzheader), 1, infile);
		if (len < 0) {
			perror(inname);
			exit(1);
		}
		if (len != 1) {
			fprintf(stderr, "%s: invalid gzip header\n", inname);
			exit(1);
		}
		if (gzheader.cm != CM_DEFLATE || gzheader.flg & FRSVD) {
			fprintf(stderr, "%s: invalid gzip header\n", inname);
			exit(1);
		}
		if (gzheader.flg & FEXTRA) {
			int count;

			count = getc(infile);
			if (ferror(infile)) {
				perror(inname);
				exit(1);
			}
			if (feof(infile)) {
				fprintf(stderr, "%s: invalid gzip header\n",
					inname);
				exit(1);
			}
			while (count) {
				getc(infile);
				if (ferror(infile)) {
					perror(inname);
					exit(1);
				}
				if (feof(infile)) {
					fprintf(stderr, "%s: invalid gzip header\n", inname);
					exit(1);
				}
				count--;
			}
		}
		if (gzheader.flg & FNAME) {
			int ch;

			do {
				ch = getc(infile);
				if (ferror(infile)) {
					perror(inname);
					exit(1);
				}
				if (feof(infile)) {
					fprintf(stderr, "%s: invalid gzip header\n", inname);
					exit(1);
				}
			}
			while (ch);
		}
		if (gzheader.flg & FCOMMENT) {
			int ch;

			do {
				ch = getc(infile);
				if (ferror(infile)) {
					perror(inname);
					exit(1);
				}
				if (feof(infile)) {
					fprintf(stderr, "%s: invalid gzip header\n", inname);
					exit(1);
				}
			}
			while (ch);
		}
		if (gzheader.flg & FHCRC) {
			len = fread(buf, 1, 2, infile);
			if (len < 0) {
				perror(inname);
				exit(1);
			}
			if (len != 2) {
				fprintf(stderr, "%s: invalid gzip header\n",
					inname);
				exit(1);
			}
		}
	}

	/* Now write the output magic number. */
	if (mkgzip) {
		if (fwrite(magic_gzip, 1, 2, stdout) != 2) {
			perror("stdout");
			exit(1);
		}
	}
	else {
		if (fwrite(magic_strong, 1, 2, stdout) != 2) {
			perror("stdout");
			exit(1);
		}
	}

	/* Now write the gzip header if necessary. */
	if (mkgzip) {
		gzheader.cm = CM_DEFLATE;
		gzheader.flg = 0;
		gzheader.mtime[0] = 0;
		gzheader.mtime[1] = 0;
		gzheader.mtime[2] = 0;
		gzheader.mtime[3] = 0;
		gzheader.xfl = 0;
		gzheader.os = OS_UNIX;
		if (fwrite(&gzheader, sizeof(struct gzheader), 1, stdout) != 1) {
			perror("stdout");
			exit(1);
		}
	}

	/* Now actually copy the data! */
	for (;;) {
		len = fread(buf, 1, sizeof(buf), infile);
		if (len < 0) {
			perror(inname);
			exit(1);
		}
		if (len == 0)
			break;
		if (fwrite(buf, 1, len, stdout) != len) {
			perror("stdout");
			exit(1);
		}
	}

	/* I can't believe we're done! */
	if (argc == 2)
		fclose(infile);
	return(0);
}
EOF

gcc ./gzcompat.c -o gzcompat.exe  > ./build.log 2>&1 
ls -la gzcompat.exe 

RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo '[*] gzcompat.exe compiled ok'
  rm -f gzcompat.c 
else
  echo '[-] Something went wrong .. check build.log'
  exit
fi
echo ''
echo '[*] Downloading boot floppy'
curl -m 30 -s -O https://www.tuhs.org/Archive/Distributions/UCB/4.3BSD-Quasijarus0a/floppy.Z
echo 'floppy.Z' 
# cleanup before we build the floppy image 
echo ''
echo '[*] Converting floppy'
rm -f floppy.img
cat floppy.Z | ./gzcompat.exe | gzip -d> floppy.img

ls -al floppy.img 
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo '[*] floppy.img created ok'
  rm -f gzcompat.c
else
  echo '[-] Something went wrong .. check output'
  exit
fi

echo ''
echo '[*] Getting the DEULA drivers sources'
echo '[*] And dumping the patched GENERIC kernel config' 

# dump patched GENERIC config that includes if_de.c
# /usr/sys/conf 
cat <<EOF > GENERIC
#
# GENERIC VAX
#
machine         vax
cpu             "VAX780"
ident           GENERIC
timezone        8 dst
maxusers        8
options         QUOTA
options         INET

config          vmunix          swap generic
config          hkvmunix        root on hk
config          hpvmunix        root on hp

controller      mba0    at nexus ?
controller      mba1    at nexus ?
controller      mba2    at nexus ?
controller      mba3    at nexus ?
controller      uba0    at nexus ?
controller      uba1    at nexus ?
controller      uba2    at nexus ?
controller      uba3    at nexus ?
disk            hp0     at mba? drive 0
disk            hp1     at mba? drive ?
disk            hp2     at mba? drive ?
disk            hp3     at mba? drive ?
master          ht0     at mba? drive ?
tape            tu0     at ht0 slave 0
tape            tu1     at ht0 slave 1
master          mt0     at mba? drive ?
tape            mu0     at mt0 slave 0
tape            mu1     at mt0 slave 1
controller      hk0     at uba? csr 0177440             vector rkintr
disk            rk0     at hk0 drive 0
disk            rk1     at hk0 drive 1
controller      tm0     at uba? csr 0172520             vector tmintr
tape            te0     at tm0 drive 0
tape            te1     at tm0 drive 1
controller      ut0     at uba? csr 0172440             vector utintr
tape            tj0     at ut0 drive 0
tape            tj1     at ut0 drive 1
controller      sc0     at uba? csr 0176700             vector upintr
disk            up0     at sc0 drive 0
disk            up1     at sc0 drive 1
controller      uda0    at uba? csr 0172150             vector udintr
disk            ra0     at uda0 drive 0
disk            ra1     at uda0 drive 1
controller      idc0    at uba0 csr 0175606             vector idcintr
disk            rb0     at idc0 drive 0
disk            rb1     at idc0 drive 1
controller      hl0     at uba? csr 0174400             vector rlintr
disk            rl0     at hl0 drive 0
disk            rl1     at hl0 drive 1
device          dh0     at uba? csr 0160020             vector dhrint dhxint
device          dm0     at uba? csr 0170500             vector dmintr
device          dh1     at uba? csr 0160040             vector dhrint dhxint
device          dz0     at uba? csr 0160100 flags 0xff  vector dzrint dzxint
device          dz1     at uba? csr 0160110 flags 0xff  vector dzrint dzxint
device          dz2     at uba? csr 0160120 flags 0xff  vector dzrint dzxint
device          dz3     at uba? csr 0160130 flags 0xff  vector dzrint dzxint
device          dz4     at uba? csr 0160140 flags 0xff  vector dzrint dzxint
device          dz5     at uba? csr 0160150 flags 0xff  vector dzrint dzxint
device          dz6     at uba? csr 0160160 flags 0xff  vector dzrint dzxint
device          dz7     at uba? csr 0160170 flags 0xff  vector dzrint dzxint
controller      zs0     at uba? csr 0172520             vector tsintr
device          ts0     at zs0 drive 0
device          dmf0    at uba? csr 0160340 vector dmfsrint dmfsxint dmfdaint dmfdbint dmfrint dmfxint dmflint    
pseudo-device   pty
pseudo-device   loop
pseudo-device   inet
pseudo-device   ether 
device 		de0	at uba? csr 0174510 		vector deintr 
device          lp0     at uba? csr 0177514             vector lpintr
EOF


# dumping FILES.VAX for the patched GENERIC VAX kernel 
#/usr/sys/conf 
cat <<EOF > files.vax
vax/autoconf.c          standard device-driver
vax/clock.c             standard
vax/conf.c              standard
vax/cons.c              standard
vax/cpudata.c           standard
vax/dkbad.c             standard
vax/flp.c               standard
vax/in_cksum.c          optional inet
vax/machdep.c           standard config-dependent
vax/mem.c               standard
vax/pup_cksum.c         optional pup
vax/sys_machdep.c       standard
vax/trap.c              standard
vax/tu.c                standard
vax/udiv.s              standard
vax/ufs_machdep.c       standard
vax/urem.s              standard
vax/vm_machdep.c        standard
vaxif/if_acc.c          optional acc imp device-driver
vaxif/if_css.c          optional css imp device-driver
vaxif/if_dmc.c          optional dmc device-driver
vaxif/if_ec.c           optional ec device-driver
vaxif/if_en.c           optional en inet device-driver
vaxif/if_hy.c           optional hy device-driver
vaxif/if_il.c           optional il device-driver
vaxif/if_pcl.c          optional pcl device-driver
vaxif/if_uba.c          optional inet device-driver
vaxif/if_un.c           optional un device-driver
vaxif/if_vv.c           optional vv device-driver
vaxif/if_de.c           optional de device-driver 
vaxmba/hp.c             optional hp device-driver
vaxmba/ht.c             optional tu device-driver
vaxmba/mba.c            optional mba device-driver
vaxmba/mt.c             optional mu device-driver
vaxuba/ad.c             optional ad device-driver
vaxuba/ct.c             optional ct device-driver
vaxuba/dh.c             optional dh device-driver
vaxuba/dmf.c            optional dmf device-driver
vaxuba/dn.c             optional dn device-driver
vaxuba/dz.c             optional dz device-driver
vaxuba/gpib.c           optional gpib device-driver
vaxuba/ib.c             optional ib device-driver
vaxuba/kgclock.c        optional kg device-driver
vaxuba/idc.c            optional rb device-driver
vaxuba/ik.c             optional ik device-driver
vaxuba/lp.c             optional lp device-driver
vaxuba/lpa.c            optional lpa device-driver
vaxuba/ps.c             optional ps device-driver
vaxuba/rk.c             optional rk device-driver
vaxuba/rl.c             optional rl device-driver
vaxuba/rx.c             optional rx device-driver
vaxuba/tm.c             optional te device-driver
vaxuba/ts.c             optional ts device-driver
vaxuba/uba.c            optional uba device-driver
vaxuba/uda.c            optional ra device-driver
vaxuba/up.c             optional up device-driver
vaxuba/ut.c             optional tj device-driver
vaxuba/uu.c             optional uu device-driver
vaxuba/va.c             optional va device-driver
vaxuba/vp.c             optional vp device-driver
EOF


curl -m 30 -s -O https://raw.githubusercontent.com/csrg/original-bsd/742cc7c4035be8abae00e7cb3e8401a7bd2ca4d9/sys/vax/if/if_de.c
curl -m 30 -s -O https://raw.githubusercontent.com/csrg/original-bsd/742cc7c4035be8abae00e7cb3e8401a7bd2ca4d9/sys/vax/if/if_dereg.h
echo '' 
echo '[+] Patching if_de.c ' 
sed -i 's/\#include \"de.h\"/\#define NDE 1/g' if_de.c
tar cvf de.tar if_de.c if_dereg.h GENERIC files.vax
python2 ./mk-dist-tape.py -o de_drivers.tape de.tar

ls -al de_drivers.tape 
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo '[*] de_drivers.tape created ok'
  rm -f gzcompat.c
else
  echo '[-] Something went wrong .. check output'
  exit
fi

# Cleanup 
echo ''
echo '' 
mkdir -p ../4.2BSD 
cp * ../4.2BSD
cd .. 
rm -rf 4.2BSD-temp
cd 4.2BSD 
rm -f floppy.Z 
#rm -f GENERIC 
#rm -f files.vax
#rm -f de.tar 
cd ..

# Finish
echo "All files ready in 4.2BSD directory "
ls -la * 
echo ''
echo "------------------------------------"
echo ""
echo "[+] Getting simh and building vax780" 
git clone https://github.com/simh/simh 
cd simh 
make vax780

ls -al BIN/vax780
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo '[*] vax780 compiled ok'
else
  echo '[-] Something went wrong .. check output'
  exit
fi
cp BIN/vax780 ../4.2BSD/vax780 
cd ..
rm -rf simh 

#Creating the 4.2BSD simh disks in 4.2BSD directory

truncate -s 456M 4.2BSD/bsd.dsk

#Creating the 4.2BSD simh disks in 4.2BSD directory

truncate -s 456M 4.2BSD/bsd.dsk

# Create bootloader for 42BSD

cat <<EOF > boot42.txt 
AADaHxLQjwAABwBe0O+aFgAAUNSA0VBeGfko74wWAACfAAAAAG7Ug9FTj6zeCAAZ9dSD0VOPAAAQ
ABn1F/9mFgAA2gAR+wDvOA0AANAB7xEXAAD7AO8GAAAAF++s////AAzCBF7f75EWAADf75cWAAD7
Au/IEAAA3QDf73wWAAD7Au9dCQAA0FCt/NVQGQ3dUN1a3Vv7A+8WAAAA3+9xFgAA+wHvlxAAAPsA
73gVAAAEAAAPwiRe0KwEW9CsCFrQrAxZ3SDfreDdWfsD72kHAADQUFjRWCASHtGt4I8HAQAAEyHR
reCPCwEAABMX0a3gjwgBAAATDd/vIhYAAPsB7yoMAADRreCPCwEAABMK0a3gjwgBAAASGN0A3Y8A
BAAA3Vn7A+9dBQAA1lASAzGDAN2t5N0A3Vn7A+/8BgAA0VCt5BJv0K3krdzRreCPCwEAABMS0a3g
jwgBAAATCBEQlL3c1q3c04//AwAArdwS8N2t6N2t3N1Z+wPvvAYAANFQregSL8Ct6K3cwI8AAAEA
rezUWBEIlL3c1q3c1ljRWK3sH/LlH630APsAvfT7AO91FAAA3+9yFQAA+wHvbgsAAAQAAAAACMIE
XtCsBFviCGsA1MvIAN0B3VsyqxBQxBRQ0OA8FwcAUPsCYNBQrfzKjwD/AABr0K38UAQACMIEXtCs
BFviCWsA1MvIAN0C3VsyqxBQxBRQ0OA8FwcAUPsCYNBQrfzKjwD/AABr0K38UAQACNCsBFvdWzKr
EFDEFFDQ4EAXBwBQ+wFgBAAI0KwEW91bMqsQUMQUUNDgRBcHAFD7AWAEAAjQrARb3awM3awI3Vsy
qxBQxBRQ0OBIFwcAUPsDYAQAAAQAAADQClAEAAAADMIEXtCsCFvUy7gAx8uMIawEUMTLkCFQx8uM
IawEUcrL8CBRxMvsIFHAUVDAy+QgUMfLjCGsBFHEy4whUcNRrARRxstMIVF4yzQhUVHAUVB4yzgh
UFDBy7AAUMu8ANDLBCHLxADBj9QAAABby8AA3Vv7Ae+7/v//0FCt/MGP1AAAAFtax8tMIawEUMTL
TCFQw1CsBFB4B1BQwFpQKI+AAGCrLNCt/FAEAAAMwghe0KwEWxMElWsSEN/vGRQAAPsB7+oNAADU
UATdrAjdAvsC7yv////VUBhT3+8EFAAAEd7WW5FrLxP50FtaEQaVahMH1lqRai8S9ZBqrf+Uat2s
CN1b+wLvggEAANBQrfgTIpWt/xMv3awI3VD7Au/f/v//1VAZoZCt/2rQWluVaxMUEbHdW9/vwBMA
APsC728NAAAxgv/QrfhQBAAADMIUXtCsBFvBBFta1awIGAnf76YTAAAxWv/RrAgMGA/QrAhQ0ECq
UK3w0K3wUATQAa30wgysCNADrfgRFcTLSCGt9NGsCK30GQ3CrfSsCNet+NWt+BTm1a34EgzdrAjf
72UTAAAxh//DrfgDUNBAyoAArfASXt2sCN/vVhMAADFt/9Ct+FDQrfBA72aVAAB4Da34UJ5A71oV
AACt7MbLSCGt9Met9KwIUMfLSCFQUcTLSCFRw1FQrfzQrfxQ0EC97K3wEgzdrAjf7yYTAAAxHv/W
rfjRrfgDFQMxTf/QrfhQ0UDvDZUAAK3wE6N4yzghrfBQwcuwAFDLvAB4Da34UJ5A7+4UAADLwADQ
ywQhy8QA3Vv7Ae/P/P//0VDLBCESAzFe/9XLyAATCdDLyADvIpgBAN3LvADf76QSAAAxr/4AAA7C
DF7QrAhb1awEEgMxKf6VvAQT+MEEW1k8qShQyo//D///UNFQjwBAAAATCd/vixIAADH8/dWpMBIJ
3++OEgAAMe793awE+wHvqRAAANBQrfTUrfjQW6383634+wHvLAAAANBQWhIDMc791WoT6jyqBlDR
UK30EuDBCFp+3awE+wLviBAAANVQEs7QalAEAA7CDF7QrARb0KsEWdFrqTQZAzHBAMvJHCFrrfQT
HMGP1AAAAFlQwa30UFo8qgRQwFBr1WoT1tBaUATOySQhUHhQa6383a383Vn7Au/d/f//0FCt+NVQ
EgMxewB4yTghUFDBybAAUMm8AMGP1AAAAFnJwADRrfwMGBHBAa38UHjJJCFQUNGpNFAZB9DJBCFQ
ERbLyRwhqTRQwMkIIVDXUNLJICFRylFQ0FDJxADdWfsB72L7///VUBkDMWL/0MnIAO++lgEA3cm8
AN/vhxEAAPsC770KAADUUAQACNWsDBMh3++DEQAA+wHvpgoAANAC74+WAQARB9AB74aWAQDOAVAE
wgOsBBnv0awEBBjpxY/UQAAArARQwI/gmQcAUNBQW+ECYNLQrAjLuADHjwACAACsCMu8ANTLxADU
UAQAAA7CFF7VrAQZDtGsBAIUCPsA78kMAAAEwgOsBBkd0awEBBgXxY/UQAAArARQwI/gmQcAUNBQ
W+ACYAvQAe8ElgEAzgFQBNDLwABZ1cvEABUDMeUA4QNrc8PLuACrNK3sFeDBj9QgAABbWs6qUFB4
UMu4AK343a343Vv7Au9v/P//eKpkUFDBy7AAUMu8AMuqSMu4AK300a34DBgQwQGt+FB4qlBQUNGr
NFAZBtCqMFARE8uqSKs0UMCqNFDXUNKqTFHKUVDQUK3wERXHjwACAADLuADLvADUrfQyjwACrfDB
j9QAAABby8AA0K3wy8QA3Vv7Ae/h+f//1VAYDNDLyADvQJUBADE5/+EDax/DrfTLuABQwK3wUNFQ
qzQZCMGt9K3sy8QAwq30y8QAwY/UAAAAW1DBrfRQWdfLxADWy7gAmImt/NBZy8AA0K38UAQAAAzU
7+6UAQDVrAQZBdABUBEC1FDRrAQCFAXQAVERAtRR0lFRylFQEyXQrAxb+wDvXAsAAPZQvAjXWxMM
0KwIUNasCJFgChLlw1usDFAEwgOsBBkd0awEBBgXxY/UQAAArARQwI/gmQcAUNBQWuACYAvQAe9+
lAEAzgFQBOlq8uADakHQrAzKxADQrAjKwADHjwACAADKuABQwcqwAFDKvADdWvsB7+D4///QUFvA
rAzKuADVWxgJ0MrIAO82lAEA0FtQBMGsDMq4AFDRUKo0FQjDyrgAqjSsDNCsDFsUA9RQBMEDrAR+
+wHvwv3///ZQvAjWrAjXWxLp0KwMUAQADNTv8JMBANWsBBkr0awEAhQl0KwMWxER0KwIUNasCJhg
fvsB7wAKAADQW1DXW9VQEubQrAxQBMIDrAQZHdGsBAQYF8WP1EAAAKwEUMCP4JkHAFDQUFrgAmAL
0AHvlpMBAM4BUAThAWrx0KwMysQA0KwIysAAx48AAgAAyrgAUMHKsABQyrwA3Vr7Ae8x+P//0FBb
wKwMyrgA1VsYCdDKyADvUZMBANBbUAQAAA7CCF7V73UNAAATHdSt/MWP1EAAAK38UNTg4JkHAPIE
rfzs1O9WDQAA1K34xY/UQAAArfhQ1eDgmQcAExLyBK346t/vCg4AAPsB7/oCAADFj9RAAACt+FDA
j+CZBwBQ0FBayARg0KwEWxEHkWsoEwbWW5VrEvWRaygTN9/v5A0AAPsB79MGAADUatAD77qSAQAR
G8AUWREj3+/TDQAA+wHvtgYAANRq0ATvnZIBAM4BUASUi97vmQwAAFnVaRPZ3WndrAT7Au98CwAA
1VASxPYoq//DjzgXBwBZUMYUUPdQqhCYi1DDMFDKrACRazAZF5FrORQSxQrKrABQmItRwFBRwzBR
yqwA1cqsABkH0cqsAB8VGd/vZw0AAPsB7zoGAADUatAF7yGSAQAxgf+RiywTGd/vXQ0AAPsB7xwG
AADUatAC7wOSAQAxY//dW/sB738KAADQUMqwABEElYsT05FrKRL33Vr7Ae/e9v//1luVaxIWwQGs
CFDIUGrUysQA1Mq4AMEDrfhQBMGP1CAAAFrKwAAyjwAgysQAwRDKsADKvADUyrgA3Vr7Ae8w9v//
1VAYGdDKyADvj5EBAN/v8QwAAPsB75IFAAAx4v7dWt1b+wLvfvf//9BQrfwSDNRq0AbvZZEBADHF
/tWsCBMZ3+/XDAAA+wHvYAUAANRq0AfvR5EBADGn/t1a3a38+wLvmPb//9VQGAzQysgA7yuRAQAx
i/7UyrgA1MrEAMEBrAhQyAhQyFBqMUr/AADCBF7CA6wEGR7RrAQEGBjFj9RAAACsBFDAj+CZBwBQ
0FCt/OACYAvQAe/ikAEAzgFQBOADvfwK3a38+wHv6fX//9S9/NRQBAAACMIEXtSt/MIDrAQZHdGs
BAQYF8WP1EAAAKwEUMCP4JkHAFDQUFvgAmAL0AHvlpABAM4BUATQrAhQz1CPAWQAAA1CAEgATgBU
AFkAXgBjABwAHAAcABwAHABoAG4A3awM3awI3Vv7A++P9f//0FCt/NWt/BgJ0MvIAO9JkAEA0K38
UATiCmvpEefiC2vjEeHiDGvdEdvIEGsR1soQaxHRyCBrEczKIGsRx+IHa8MRweUHa70RuwAA3++p
CwAA+wHvAQAAAAQAAMIEXtSt/MWP1EAAAK38UNXg4JkHABMK3a38+wHvzf7///IErfzg3awE3+98
CwAA+wLv2gMAAPsA70MJAAAEAADdrATf72YLAAD7Au/AAwAAEf4AAAAIwhBe3T77Ae/OBgAA0FCt
/Jqt/+8qDAAA0O8kDAAAUNFQARNB0VACE2fRUAMSAzGJADGkAHgCrfBQwO97jwEAUN1g+wHv6QgA
ANVQEhN4Aq3wUMDvYo8BAFDQYFDQAaAE1q3wEXbe7xcLAADvPo8BAN7v7AoAAO8/jwEA3u/xCgAA
7zCPAQDQBK340ASt9BFI3u8MCwAA7xOPAQDe7/EKAADvFI8BAN7v7goAAO8FjwEA0ASt+NSt9BEe
3u/yCgAA7/WOAQDe7+sKAADv5o4BANSt9NCt9K341K3w0a3wrfQYAzFP/9HvVwsAAAETC90A3Tf7
Au/ZBQAA1a30FQrQj4CEHgBb9Vv9BAAADMIEXtCsBFvV76UKAAASKniP/cusAFB4AlBQwO+KjgEA
UO8ADe+FCgAAUciPAOADAFHBUWDveQoAANXv188BABIp3u9HzwEA7yqPAQCaj4jvJo8BAN0C3+9a
jgEA+wLvfwUAANBQ76zPAQC0/0IKAADQ7zwKAABQs48ACKACE/GwjwCAoALQ7ycKAABQs48AEKAC
E/HBCO97zwEAUDJQUNDvDQoAAFH3UKEC0O8CCgAAULOPACCgAhPxwQjvVs8BAFB4j/BQUDJQUNDv
4wkAAFH3UKEC0O/YCQAAULOPAECgAhPx9wGgAsEU7yjPAQDvo84BAMGPUAAAAO8YzwEA75fOAQC0
7+POAQDdBPsB73YAAADVUBIW3++6CQAAEQbf78gJAAD7Ae9x/f//BMuP+P///8usAFD3UO+lzgEA
3Qn7Ae9CAAAA1VAT1NXLsAAZGtHLsAAHFBPQy7AAUNFA71MJAACP/////xIN3++SCQAA+wHvJf3/
/9DLsABQ0EDvMwkAAMuwAAQAAADCCF72rATvUc4BAPc87wLOAQD3PO83zgEAyI8AAADA7+jNAQDI
jwAAAMDv4c0BADL/8wgAAK34te/LzQEAEwa078PNAQC177/NAQAT6rTvt80BAN7vu80BAK380K38
UMmPgAAAAKwEUZqgDFDRUFESCtCt/FCzH6AOEwPUUATQrfxQBAAADMIEXtCsBFvdAd1b+wLvwAMA
ANBQrfze767NAQBa0Mu8AKogy4/4////y6wAUPdQqgjQy8QAqhDvABKt/FDvHASt/FF4GFFRyVFQ
qhTRrAgBEgXQIVARA9AiUN1Q+wHvFf///9BQWhId3++RCAAA+wHvKQAAAN2t/N1b+wLvEQQAAM4B
UATdrfzdW/sC7wEEAADQy8QAUAQAAADQClAEAADBCFx+3awE+wLvAgAAAAQAgA/CCF7QrARb0KwI
WhEO1VgSAQTdWPsB7/MBAACYi1jRWCUS6jFEAdFQj2IAAAATYRUDMRAB0VCPTwAAABMdFQMx8wDR
UI9EAAAAEwrABFoRy9AQWREI0ApZEQPQCFndWd1q+wLvRgEAABHh0GpZ0BhX1VcZ185XUHhQWVDv
AAdQWBMJ3Vj7Ae+DAQAAwghXEeDQilnQaq380K38UNat/Jhgft1Z+wLvBAEAANSt+NVZE5rdPPsB
71QBAADQrfxQ1q38mGBXEgzdPvsB7z8BAAAxef/DAVdQeFABUNJQUMtQWVATKdWt+BMJ3Sz7Ae8d
AQAA0AGt+Ji9/FjRWCAVvN1Y+wHvBwEAANat/BHpkb38IBWo1q38EfXQaq380K38UNat/JhgWBID
MSH/3Vj7Ae/bAAAAEebRUI9YAAAAEgMxD/8xB//RUI9kAAAAEgMxBf8UD9FQj2MAAAASAzEM/zHq
/tFQj2wAAAAS9JiLWNBYUNFQj28AAAASAzHe/hQDMaX+0VCPdQAAABIDMcj+FA/RUI9zAAAAEgMx
fP8xrf7RUI94AAAAEgMxpv4xnv4AAAjCDF7RrAgKEhPVrAQYDt0t+wHvRwAAAM6sBKwE3q31W92s
CN2sBPsC70MDAACQQO94BgAAi92sCN2sBPsC7wYDAADQUKwE1VAS1ph7fvsB7woAAADerfVQ0VtQ
FO0EAA7QrARbMo8wdVndIvsB7+oAAADgB1AE11kS79VbEgEE3SL7Ae/UAAAA0FBa3QDdIvsC774A
AACaW37dI/sC77IAAADRWwoSCd0N+wHvrv///90A+wHvpf///91a3SL7Au+QAAAABAAACN0g+wHv
iwAAAOEHUPPdIfsB734AAADvAAdQW9FbDRID0Apb3Vv7Ae9q////0FtQBAAM0KwEWxEq0VAjE0TR
UI9AAAAAEw/2WosRF9FQDRMr0VAVEuPQrARb3Qr7Ae80////+wDvlf///+8AB1Ba0FpQ0VAIEwvR
UAoS0NAKWpSLBNdb0VusBBjZEacAAADarAisBAQAANusBFAEAAAAKKwMvAS8CAQAAAAMwhRe0KwE
W9DLwABQ7wkXUK34y48A/v//y8AArfTBrfTLxABQwI//AQAAUO8JF1BQwQFQrfzRrAgCEhXQ7w0F
AACt7MCt/O8DBQAA1KwIEQPUrex4j/3LrABQeAJQUMDvZogBAFDBjwAIAABgUHgCrexRwVFQWngV
rAhQyY8AAACAUK3w1awIEwnprfQF4hmt8ADvABWt+K34EQnJrfCt+IrWrfjXrfwS8tSKeBysCFB4
Ca3sUchRUMit9FAEAAAI7xwErAhQ0FBbEgEE0O+ABAAAUNFQARML0VACEzTRUAMTAATQrARQeI/9
wKwAUHgCUFDA79KHAQBQwY9AAAAAYFB4AltRwFFQyI8AAACAYBHR0KwEUHiP/cCsAFB4AlBQwO+k
hwEAUMGPQAAAAGBQeAJbUcBRUMiPAQAAYGARowAAAAAMwgRe0KwEW9St/NRaER+RazkUNsUKrfxQ
mItRwFBRwzBRrfwRH9Za1lsRGdZbmGtQ0VAJE/bRUCAT8dFQKxPo0VAtE+GRazAYxdVaEwbOrfxQ
EQTQrfxQBAAAAAzQrARb1FoRAtZalYsS+tBaUAQAALwBAAzQrARb0KwIWpFrihIHlYsS99RQBJhr
UJh6UcJRUAQAANCsBFDQrAhSEwXRUgEVCNRRe1JQUFIEEwvRUFIeA9RQBNABUAQAAADQrARQ0KwI
UhMF0VIBFQjUUXtSUFJQBBID1FAE0VBSHwPCUlAEANBQ742GAQDOAVAEAEIABwDIGQAAAAAX71Tp
//8AANABUNCsBFPQBFKe7w4AAABi1WPUUNAEUtRiBAAAAM/v6gIAAAEDCwAGAAYA2g8mEQPaADDA
jl6e79j///9uAgAAAHJhKDAsMClib290AGxvYWRpbmcgJXMAYm9vdCBmYWlsZWQAQmFkIGZvcm1h
dAoAU2hvcnQgcmVhZAoAAGAXBwCgEAcAkA4HAIQCBwA6EQcAAAAAAAAAAAAAAAAAAAAAAAAAAABy
YQAAAQAAAG51bGwgcGF0aAoAY2FuJ3QgcmVhZCByb290IGlub2RlCgAlcyBub3QgZm91bmQKAGJu
IG5lZ2F0aXZlCgBibiBvdmYgJUQKAGJuIHZvaWQgJUQKAGJuICVEOiByZWFkIGVycm9yCgBibiB2
b2lkICVECgBub3QgYSBkaXJlY3RvcnkKAHplcm8gbGVuZ3RoIGRpcmVjdG9yeQoAYm4gJUQ6IHJl
YWQgZXJyb3IKAFNlZWsgbm90IGZyb20gYmVnaW5uaW5nIG9mIGZpbGUKAE5vIG1vcmUgZmlsZSBz
bG90cwBCYWQgZGV2aWNlCgBVbmtub3duIGRldmljZQoAQmFkIHVuaXQgc3BlY2lmaWVyCgBNaXNz
aW5nIG9mZnNldCBzcGVjaWZpY2F0aW9uCgBzdXBlciBibG9jayByZWFkIGVycm9yCgBDYW4ndCB3
cml0ZSBmaWxlcyB5ZXQuLiBTb3JyeQoARXhpdCBjYWxsZWQAJXMKAFRyYXAgJW8KAABgACAAgAAg
AKAAIADAACAAABAgAAAUIAAAGCAAABwgAAABIAAgASAAQAEgAGABIAAA8wAAIPMAAAD8AAAA+AAA
gPIAAKDyAADA8gAA4PIAAGDyAAAA/ABo9AAAAAAAAAAAAAAMPgAAAAAAAP///////////////6zA
AABMAQIAcmE6IG9wZW4gZXJyb3IsIFNUQ09OAHJhOiBvcGVuIGVycm9yLCBPTkxJTgByYTogYmFk
IHVuaXQAcmE6IEkvTyBlcnJvcgoAMDEyMzQ1Njc4OWFiY2RlZgAAAADAAAAA
EOF

base64 --decode boot42.txt > boot42
mv boot42 4.2BSD 
rm boot42.txt 


echo '[*] Dumping the simh vax780 config' 

#STAGE1 install
cat <<EOF > install.ini
set rq0 ra81
at rq0 miniroot
set rq1 ra81
at rq1 bsd.dsk
set rq1 dis
set rq2 dis
set rq3 dis
set rp dis
set lpt dis
set rl dis
set tq dis
set tu dis
att ts 4.2bsd.tape
set tti 7b
set tto 7b
set XU enable
set XU MAC=08-00-2b-00-00-05
att XU tap:tap0
set XUB enable
load -o boot42 0
d r10 9
d r11 0
run 2
EOF

mv install.ini 4.2BSD 

echo './vax780 install.ini' > 4.2BSD/install.sh 
chmod +x 4.2BSD/install.sh 

# STAGE2 install
cat <<EOF > install2.ini
set rq0 ra81
att rq0 bsd.dsk
set rq1 dis
set rq2 dis
set rq3 dis
set rp dis
set lpt dis
set rl dis
set tq dis
set tu dis
att ts 4.2bsd.tape
set tti 7b
set tto 7b
set XU enable
set XU MAC=08-00-2b-00-00-05
att XU tap:tap0
set XUB enable
load -o boot42 0
d r10 9
d r11 0
run 2
EOF

mv install2.ini 4.2BSD
echo './vax780 install2.ini' > 4.2BSD/install2.sh
chmod +x 4.2BSD/install2.sh

# STAGE3 install 
cat <<EOF > install3.ini
set rq0 ra81
att rq0 bsd.dsk
set rq1 dis
set rq2 dis
set rq3 dis
set rp dis
set lpt dis
set rl dis
set tq dis
set tu dis
att ts de_drivers.tape 
set tti 7b
set tto 7b
set XU enable
set XU MAC=08-00-2b-00-00-05
att XU tap:tap0
set XUB enable
load -o boot42 0
d r10 9
d r11 0
run 2
EOF


mv install3.ini 4.2BSD
echo './vax780 install3.ini' > 4.2BSD/install3.sh
chmod +x 4.2BSD/install3.sh
cp 4.2BSD/install3.sh 4.2BSD/boot.sh 

# END 
echo ''
echo '******************************************'
echo '* Ready to run the installer stage now   *' 
echo '* Run 4.2BSD/install.sh                  *' 
echo '* Once done, run the installer2 stage    *'
echo '* Run 4.2BSD/install2.sh                 *' 
echo '* Once done, run the last stage to setup *'
echo '* network drivers                        *' 
echo '* Run 4.2BSD/install3.sh                 *' 
echo '*                                        *'
echo '* Once done you can boot via boot.sh     *'
echo '* For details please refer to README.TXT *'
echo "* Happy hacking :)                       *" 
echo '******************************************'  
