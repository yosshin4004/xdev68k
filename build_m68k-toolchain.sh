#!/usr/bin/bash
#------------------------------------------------------------------------------
#
#	build_m68k-toolchain.sh
#
#	JP:
#		m68k-toolchain をビルドする bash シェルスクリプト
#
#	EN:
#		This is a bash script to build m68k-toolchain.
#
#------------------------------------------------------------------------------
#
#	Copyright (C) 2022 Yosshin(@yosshin4004)
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#	    http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#
#------------------------------------------------------------------------------


#
# 参考
#	How to Build a GCC Cross-Compiler
#		https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
#		https://gist.github.com/preshing/41d5c7248dea16238b60
#	newlibベースのgccツールチェインの作成
# 		https://memo.saitodev.com/home/arm/arm_gcc_newlib/
# 	Installing GCC: Configuration
# 		https://pipeline.lbl.gov/code/3rd_party/licenses.win/gcc-3.4.4-999/INSTALL/configure.html
#


#-----------------------------------------------------------------------------
# 設定
#
#	debian 系のディストリビューションで stable とされている構成に倣っている。
#-----------------------------------------------------------------------------

# gcc の ABI
GCC_ABI=m68k-elf

# binutils
BINUTILS_VERSION="2.35"
BINUTILS_ARCHIVE="binutils-${BINUTILS_VERSION}.tar.bz2"
BINUTILS_SHA512SUM="826c1fdac2dd7b2326c4fc5449a585cf0c1f979a98c6ee062bab5ebd6bc657e697c468fc3a4c3c5a7fa383a4902e8cacd27e1752707bbaf042b36b2653469947"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/${BINUTILS_ARCHIVE}"
BINUTILS_DIR="binutils-${BINUTILS_VERSION}"

# gcc
GCC_VERSION="10.2.0"
GCC_ARCHIVE="gcc-${GCC_VERSION}.tar.gz"
GCC_SHA512SUM="5118865a85e70ba58702bb3615d3d9e44dcdbc725fdb71124da78dd412388c5fc367378771bf82fed4d6e2c62fde4c7c362ec1f8ddcae762a2af957f2d605520"
GCC_URL="https://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VERSION}/${GCC_ARCHIVE}"
GCC_DIR="gcc-${GCC_VERSION}"

# newlib
NEWLIB_VERSION="3.3.0"
NEWLIB_ARCHIVE="newlib-${NEWLIB_VERSION}.tar.gz"
NEWLIB_SHA512SUM="2f0c6666487520e1a0af0b6935431f85d2359e27ded0d01d02567d0d1c6479f2f0e6bbc60405e88e46b92c2a18780a01a60fc9281f7e311cfd40b8d5881d629c"
NEWLIB_URL="ftp://sourceware.org/pub/newlib/${NEWLIB_ARCHIVE}"
NEWLIB_DIR="newlib-${NEWLIB_VERSION}"

# gcc ビルド用ワークディレクトリ
GCC_BUILD_DIR="build_gcc"


#-----------------------------------------------------------------------------
# 準備
#-----------------------------------------------------------------------------

# エラーが起きたらそこで終了させる。
# 未定義変数を参照したらエラーにする。
set -eu

CPU="m68000"
TARGET=${GCC_ABI}
PREFIX="${TARGET}-"
PROGRAM_PREFIX=${PREFIX}
NUM_PROC=$(nproc)
ROOT_DIR="${PWD}"
INSTALL_DIR="${ROOT_DIR}/m68k-toolchain"
DOWNLOAD_DIR="${ROOT_DIR}/${GCC_BUILD_DIR}/download"
BUILD_DIR="${ROOT_DIR}/${GCC_BUILD_DIR}/build"
SRC_DIR="${ROOT_DIR}/${GCC_BUILD_DIR}/src"
WITH_CPU=${CPU}

# gcc ビルド用ワークディレクトリがすでに存在するなら削除確認
if [ -d ${GCC_BUILD_DIR} ]; then
	echo "${GCC_BUILD_DIR} already exists."
	echo "Do you want to remove the existing directory and proceed? (Y/n)"
	read ANS
	case $ANS in
	  "" | [Yy]* )
	    echo "Yes"
	    echo "removing ${GCC_BUILD_DIR} ..."
	    rm -rf ${GCC_BUILD_DIR}
	    ;;
	  * )
	    echo "Aborted."
	    exit 1
	    ;;
	esac
fi

# インストール先ディレクトリがすでに存在するなら削除確認
if [ -d ${INSTALL_DIR} ]; then
	echo "${INSTALL_DIR} already exists."
	echo "Do you want to remove the existing directory and proceed? (Y/n)"
	read ANS
	case $ANS in
	  "" | [Yy]* )
	    echo "Yes"
	    echo "removing ${INSTALL_DIR} ..."
	    rm -rf ${INSTALL_DIR}
	    ;;
	  * )
	    echo "Aborted."
	    exit 1
	    ;;
	esac
fi

# ディレクトリ作成
mkdir -p ${INSTALL_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${SRC_DIR}
mkdir -p ${DOWNLOAD_DIR}


#-----------------------------------------------------------------------------
# binutils のビルド
#-----------------------------------------------------------------------------

mkdir -p ${BUILD_DIR}/${BINUTILS_DIR}

cd ${DOWNLOAD_DIR}
if ! [ -f "${BINUTILS_ARCHIVE}" ]; then
    wget ${BINUTILS_URL}
fi
if [ $(sha512sum ${BINUTILS_ARCHIVE} | awk '{print $1}') != ${BINUTILS_SHA512SUM} ]; then
	echo "SHA512SUM verification of ${BINUTILS_ARCHIVE} failed!"
	exit
fi
tar jxvf ${BINUTILS_ARCHIVE} -C ${SRC_DIR}

cd ${BUILD_DIR}/${BINUTILS_DIR}
${SRC_DIR}/${BINUTILS_DIR}/configure \
    --prefix=${INSTALL_DIR} \
    --program-prefix=${PROGRAM_PREFIX} \
    --target=${TARGET} \
    --enable-lto \
    --enable-interwork \
    --enable-multilib \

make -j${NUM_PROC} 2<&1 | tee build.binutils.1.log
make install -j${NUM_PROC} 2<&1 | tee build.binutils.2.log

export PATH=${INSTALL_DIR}/bin:${PATH}

cd ${ROOT_DIR}


#-----------------------------------------------------------------------------
# gcc のビルド（stage1）
#
#	C クロスコンパイラを構築する。
#	msys 上で起きるファイルパス問題を回避するため、configure を相対パスで
#	起動している。
#-----------------------------------------------------------------------------

mkdir -p ${BUILD_DIR}/${GCC_DIR}_stage1

cd ${DOWNLOAD_DIR}
if ! [ -f "${GCC_ARCHIVE}" ]; then
    wget ${GCC_URL}
fi
if [ $(sha512sum ${GCC_ARCHIVE} | awk '{print $1}') != ${GCC_SHA512SUM} ]; then
	echo "SHA512SUM verification of ${GCC_ARCHIVE} failed!"
	exit
fi
tar xvf ${GCC_ARCHIVE} -C ${SRC_DIR}

cd ${SRC_DIR}/${GCC_DIR}
./contrib/download_prerequisites

cd ${BUILD_DIR}/${GCC_DIR}_stage1
`realpath --relative-to=./ ${SRC_DIR}/${GCC_DIR}`/configure \
    --prefix=${INSTALL_DIR} \
    --program-prefix=${PROGRAM_PREFIX} \
    --target=${TARGET} \
    --enable-lto \
    --enable-languages=c \
    --without-headers \
    --with-arch=m68k \
    --with-cpu=${WITH_CPU} \
    --with-newlib \
    --enable-interwork \
    --enable-multilib \
    --disable-shared \
    --disable-threads \

make -j${NUM_PROC} all-gcc 2<&1 | tee build.gcc-stage1.1.log
make install-gcc 2<&1 | tee build.gcc-stage1.2.log

cd ${ROOT_DIR}


#-----------------------------------------------------------------------------
# newlib のビルド
#-----------------------------------------------------------------------------

mkdir ${BUILD_DIR}/${NEWLIB_DIR}

cd ${DOWNLOAD_DIR}
if ! [ -f "${NEWLIB_ARCHIVE}" ]; then
    wget ${NEWLIB_URL}
fi
if [ $(sha512sum ${NEWLIB_ARCHIVE} | awk '{print $1}') != ${NEWLIB_SHA512SUM} ]; then
	echo "SHA512SUM verification of ${NEWLIB_ARCHIVE} failed!"
	exit
fi
tar zxvf ${NEWLIB_ARCHIVE} -C ${SRC_DIR}

export CC_FOR_TARGET=${PROGRAM_PREFIX}gcc
export LD_FOR_TARGET=${PROGRAM_PREFIX}ld
export AS_FOR_TARGET=${PROGRAM_PREFIX}as
export AR_FOR_TARGET=${PROGRAM_PREFIX}ar
export RANLIB_FOR_TARGET=${PROGRAM_PREFIX}ranlib
#
#	次の記述は、
#		if [ ! -v newlib_cflags ]; then
#	としたいが、-v が使えない bash 環境が存在するため、代替手段を利用する。
#	"${newlib_cflags+exists}" は、newlib_cflags が未定義なら空文字（偽）、
#	そうでなければ exists（真）になる。従って -v の代替になる。
#
if [ ! "${newlib_cflags+exists}" ]; then
	newlib_cflags=""
fi
export newlib_cflags="${newlib_cflags} -DPREFER_SIZE_OVER_SPEED -D__OPTIMIZE_SIZE__"

cd ${BUILD_DIR}/${NEWLIB_DIR}
${SRC_DIR}/${NEWLIB_DIR}/configure \
    --prefix=${INSTALL_DIR} \
    --target=${TARGET} \

make -j${NUM_PROC} 2<&1 | tee build.newlib.1.log
make install | tee build.newlib.2.log

cd ${ROOT_DIR}


#-----------------------------------------------------------------------------
# gcc のビルド（stage2）
#
#	残りを一括実行する。
#
#	--with-arch=m68k を指定することで、ColdFire 用の libgcc バリエーションが
#	大量に生成されることを回避している。
#-----------------------------------------------------------------------------

mkdir -p ${BUILD_DIR}/${GCC_DIR}_stage2

cd ${BUILD_DIR}/${GCC_DIR}_stage2
`realpath --relative-to=./ ${SRC_DIR}/${GCC_DIR}`/configure \
    --prefix=${INSTALL_DIR} \
    --program-prefix=${PROGRAM_PREFIX} \
    --target=${TARGET} \
    --enable-lto \
    --enable-languages=c,c++ \
    --with-arch=m68k \
    --with-cpu=${WITH_CPU} \
    --with-newlib \
    --enable-interwork \
    --enable-multilib \
    --disable-shared \
    --disable-threads \

make -j${NUM_PROC} 2<&1 | tee build.gcc-stage2.1.log
make install 2<&1 | tee build.gcc-stage2.2.log

cd ${ROOT_DIR}


#------------------------------------------------------------------------------
# 正常終了
#------------------------------------------------------------------------------

echo ""
echo "-----------------------------------------------------------------------------"
echo "The building process is completed successfully."
echo "-----------------------------------------------------------------------------"
echo ""

