#!/bin/bash
###
# Redundans installer for UNIX.
# bash <(curl -Ls http://bit.ly/redundans_installer)
# version 0.1b
###

installdir="$HOME/src"
log="$installdir/redundans.install.log"
pyversion="2.7.10"

exists()
{
  command -v "$1" >/dev/null 2>&1
}

clear
echo "#######################################################################"
echo "#                                                                     #"
echo "#                         Redundans installer                         #"
echo "#                                                                     #"
echo "#    version 0.1b                           l.p.pryszcz@gmail.com     #"
echo "#######################################################################"
echo ""
echo "Redundans and its dependencies will be installed in $installdir"
echo "Necessary imports will be added to ~/.bashrc automatically. "
echo " Original file will be backed up to ~/.bashrc_bak"
echo ""
echo "This is EXPERIMENTAL software! You may want to create new user and "
echo "run installer there, to avoid data loss:"
echo "  sudo adduser test && su test"
echo ""
echo "Installation may take 2-3 minutes. "
echo "To track the installation status execute in the new terminal:"
echo "  tail -f $log"
echo ""

# YES/NO prompt
echo -n "Do you want to proceed with installation (y/n)? "
read answer
if echo "$answer" | grep -viq "^y" ; then
    echo "Aborted!"
    exit 0
fi

echo -e "\n"`date` "Checking dependencies..."

error=""
# check if all programs exists
for cmd in echo wget gcc g++ make cd ln date ldconfig unzip perl python; do
    if ! exists $cmd; then
        echo "Install $cmd first!"
        error=1
    fi
done

# check if all libs present
for lib in libz; do
    if [ -z "$(ldconfig -p | grep $lib.so)" ] ; then
        echo "Missing library $lib!"
        error=1
    fi
done

# skip if error
if [ ! -z $error ]; then
    echo -e "\nAborted due to missing dependencies (see above)"
    exit 1;
fi

# make copy of .bashrc
cp ~/.bashrc ~/.bashrc_bak

if [ ! -d $installdir ]; then mkdir -p $installdir; fi
cd $installdir

echo -e "\n###\n# redundans imports" >> ~/.bashrc
echo 'export PATH=$PATH:'$installdir/SSPACE:$installdir/bwa:$installdir/last/src:$installdir/last/scripts:$installdir >> ~/.bashrc

# export PATH 
# source ~/.bashrc # not working as not interactive shell
export PATH=$PATH:$installdir/SSPACE:$installdir/bwa:$installdir/last/src:$installdir/last/scripts:$installdir

echo `date` "Installing redundans dependencies..."
echo `date` " BWA"
# BWA
wget -q http://downloads.sourceforge.net/project/bio-bwa/bwa-0.7.12.tar.bz2
tar xpfj bwa-0.7.12.tar.bz2
ln -s bwa-0.7.12 bwa
cd bwa 
make >> $log 2>&1
cd $installdir

# LAST
echo `date` " LAST"
wget -q http://last.cbrc.jp/last-714.zip
unzip -q last-714.zip
ln -s last-714 last
cd last
make >> $log 2>&1
cd $installdir

echo `date` " SSPACE"
# SSPACE - note tar.gz and dir are different!
wget -q http://www.baseclear.com/base/download/41SSPACE-STANDARD-3.0_linux-x86_64.tar.gz
tar xpfz 41SSPACE-STANDARD-3.0_linux-x86_64.tar.gz
ln -s SSPACE-STANDARD-3.0_linux-x86_64 SSPACE
# getopts.pl https://github.com/lpryszcz/redundans/#sspace-fails-with-an-error-cant-locate-getoptspl-in-inc
wget -q -O- http://cpansearch.perl.org/src/GBARR/perl5.005_03/lib/getopts.pl > SSPACE/dotlib/getopts.pl

# GapCloser
echo `date` " GapCloser"
wget -q http://downloads.sourceforge.net/project/soapdenovo2/GapCloser/bin/r6/GapCloser-bin-v1.12-r6.tgz
tar xpfz GapCloser-bin-v1.12-r6.tgz

echo `date` " Redundans"
#git clone https://github.com/lpryszcz/redundans
wget -q -O redundans.tgz https://github.com/lpryszcz/redundans/archive/master.tar.gz
tar xpfz redundans.tgz
mv redundans-master redundans
cd redundans

# check if installed correctly
echo `date` "Checking if all dependencies are installed..."
for cmd in lastal bwa GapCloser SSPACE_Standard_v3.0.pl; do
    if ! exists $cmd; then
        echo "[WARNING] Make sure $cmd installed properly!"
    fi
done


echo "###" >> ~/.bashrc
echo `date` "Installation finished!"
echo ""
echo "To uninstall execute:"
echo " rm -rI ~/src/{*SSPACE,bwa,blat,last,GapCloser,redundans}*"
echo " cp ~/.bashrc_bak ~/.bashrc"
echo ""
echo "To try Redundans, open new terminal and execute:"
echo " cd $installdir/redundans"
echo " ./redundans.py -v -i test/*.fq.gz -f test/contigs.fa -o test/run1"
echo ""
echo "###"
echo "# Make sure to register as user of:"
echo "# - SSPACE http://www.baseclear.com/genomics/bioinformatics/basetools/SSPACE"
echo "###"

exit 0

