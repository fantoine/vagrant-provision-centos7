# Install start-stop-deamon

version="1.17.25"

if [ ! -f /usr/local/bin/start-stop-daemon ]; then
    # Download build dependencies
    yum install -y libselinux-devel ncurses-devel ncurses >/dev/null 2>&1
    yum groupinstall -y "Development tools" >/dev/null 2>&1

    pushd /usr/local/src >/dev/null 2>&1

    # Download dpkg
    wget -c "http://ftp.de.debian.org/debian/pool/main/d/dpkg/dpkg_${version}.tar.xz" >/dev/null 2>&1
    tar xvfJ "dpkg_${version}.tar.xz" >/dev/null 2>&1
    rm "dpkg_${version}.tar.xz" >/dev/null 2>&1
    
    # Build dpkg
    pushd "dpkg-${version}" >/dev/null 2>&1
    ./configure >/dev/null 2>&1
    make >/dev/null 2>&1
    pushd utils >/dev/null 2>&1
    make >/dev/null 2>&1
    cc start-stop-daemon.c -o start-stop-daemon >/dev/null 2>&1
    cp start-stop-daemon /sbin

    popd >/dev/null 2>&1
    popd >/dev/null 2>&1
    popd >/dev/null 2>&1
fi
