#!/bin/bash
PKG="cbftp"
SRC_NAME="cbftp"
PKG_NAME="cbftp"
DEBFULLNAME="Ronald Record"
DEBEMAIL="ronaldrecord@gmail.com"
DESTDIR="usr"
SRC=${HOME}/src
ARCH=amd64
SUDO=sudo
GCI=

dpkg=`type -p dpkg-deb`
[ "${dpkg}" ] || {
    echo "Debian packaging tools do not appear to be installed on this system"
    echo "Are you on the appropriate Linux system with packaging requirements ?"
    echo "Exiting"
    exit 1
}

dpkg_arch=`dpkg --print-architecture`
[ "${dpkg_arch}" == "${ARCH}" ] || ARCH=${dpkg_arch}

[ -f "${SRC}/${SRC_NAME}/VERSION" ] || {
  [ -f "/builds/doctorfree/${SRC_NAME}/VERSION" ] || {
    echo "$SRC/$SRC_NAME/VERSION does not exist. Exiting."
    exit 1
  }
  SRC="/builds/doctorfree"
  GCI=1
# SUDO=
}

. "${SRC}/${SRC_NAME}/VERSION"
PKG_VER=${VERSION}
PKG_REL=${RELEASE}

umask 0022

# Subdirectory in which to create the distribution files
OUT_DIR="${SRC}/${SRC_NAME}/dist/${PKG_NAME}_${PKG_VER}"

[ -d "${SRC}/${SRC_NAME}" ] || {
    echo "$SRC/$SRC_NAME does not exist or is not a directory. Exiting."
    exit 1
}

cd "${SRC}/${SRC_NAME}"

# Build cbftp
if [ -x build ]
then
  ./build
else
  [ -f bin/cbftp ] || {
    [ -f /etc/arch-release ] && {
      NCW="src/ui/ncurseswrap.h"
      cp ${NCW} /tmp/nc_save$$
      cat ${NCW} | sed -e "s%ncursesw/curses.h%ncurses.h%" > /tmp/nc$$
      cp /tmp/nc$$ ${NCW}
      rm -f /tmp/nc$$
    }
    make
    [ -f /tmp/nc_save$$ ] && cp /tmp/nc_save$$ ${NCW}
  }
  chmod +x bin/*
fi

${SUDO} rm -rf dist
mkdir dist

[ -d ${OUT_DIR} ] && rm -rf ${OUT_DIR}
mkdir ${OUT_DIR}
mkdir ${OUT_DIR}/DEBIAN
chmod 755 ${OUT_DIR} ${OUT_DIR}/DEBIAN

echo "Package: ${PKG}
Version: ${PKG_VER}-${PKG_REL}
Section: misc
Priority: optional
Architecture: ${ARCH}
Depends: libncurses-dev, libssl-dev
Maintainer: ${DEBFULLNAME} <${DEBEMAIL}>
Installed-Size: 2000
Build-Depends: debhelper (>= 11)
Homepage: https://github.com/doctorfree/cbftp
Description: NCurses advanced multi-purpose FTP/FXP client" > ${OUT_DIR}/DEBIAN/control

chmod 644 ${OUT_DIR}/DEBIAN/control

for dir in "${DESTDIR}" "${DESTDIR}/bin" "${DESTDIR}/share" "${DESTDIR}/share/man" \
           "${DESTDIR}/share/${PKG}"
do
    [ -d ${OUT_DIR}/${dir} ] || ${SUDO} mkdir ${OUT_DIR}/${dir}
    ${SUDO} chown root:root ${OUT_DIR}/${dir}
done

${SUDO} cp bin/* ${OUT_DIR}/${DESTDIR}/bin

${SUDO} cp LICENSE ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} cp README ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} cp VERSION ${OUT_DIR}/${DESTDIR}/share/${PKG}
${SUDO} cp -a examples ${OUT_DIR}/${DESTDIR}/share/${PKG}/examples
${SUDO} cp -a man/man1 ${OUT_DIR}/${DESTDIR}/share/man/man1

${SUDO} chmod 644 ${OUT_DIR}/${DESTDIR}/share/man/*/*
${SUDO} chmod 755 ${OUT_DIR}/${DESTDIR}/bin/* \
                  ${OUT_DIR}/${DESTDIR}/bin \
                  ${OUT_DIR}/${DESTDIR}/share/man \
                  ${OUT_DIR}/${DESTDIR}/share/man/*
find ${OUT_DIR}/${DESTDIR}/share/${PKG} -type d | while read dir
do
  ${SUDO} chmod 755 "${dir}"
done
find ${OUT_DIR}/${DESTDIR}/share/${PKG} -type f | while read f
do
  ${SUDO} chmod 644 "${f}"
done
${SUDO} chown -R root:root ${OUT_DIR}/${DESTDIR}/share
${SUDO} chown -R root:root ${OUT_DIR}/${DESTDIR}/bin

cd dist
echo "Building ${PKG_NAME}_${PKG_VER} Debian package"
${SUDO} dpkg --build ${PKG_NAME}_${PKG_VER} ${PKG_NAME}_${PKG_VER}-${PKG_REL}.${ARCH}.deb
cd ${PKG_NAME}_${PKG_VER}
echo "Creating compressed tar archive of ${PKG_NAME} ${PKG_VER} distribution"
${SUDO} tar cf - usr/*/* | gzip -9 > ../${PKG_NAME}_${PKG_VER}-${PKG_REL}.${ARCH}.tgz

have_zip=`type -p zip`
[ "${have_zip}" ] || {
  ${SUDO} apt-get update
  ${SUDO} apt-get install zip -y
}
echo "Creating zip archive of ${PKG_NAME} ${PKG_VER} distribution"
${SUDO} zip -q -r ../${PKG_NAME}_${PKG_VER}-${PKG_REL}.${ARCH}.zip usr/*/*
cd ..

[ "${GCI}" ] || {
  [ -d ../releases ] || mkdir ../releases
  [ -d ../releases/${PKG_VER} ] || mkdir ../releases/${PKG_VER}
  ${SUDO} cp *.deb *.tgz *.zip ../releases/${PKG_VER}
}
