#!/usr/bin/bash
#------------------------------------------------------------------------------
#
#	install_xdev68k-utils.sh
#
#	JP:
#		xdev68k で必要になるユーティリティをダウンロードしインストールします。
#		インストールはすべてカレントディレクトリ以下のフォルダに対して行われ、
#		ユーザーのシステム環境に影響を与えません。
#
#	EN:
#		This script will download and install the necessary utilities for the
#		xdev68k.
#		All installation will be done to folders under the current directory
#		and will not affect the user's system environment.
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


# エラーが起きたらそこで終了させる。
# 未定義変数を参照したらエラーにする。
set -eu

# 作業用テンポラリディレクトリ
INSTALLER_TEMP_DIR=installer_temp

# 作業用テンポラリディレクトリがすでに存在するなら削除確認
if [ -d ${INSTALLER_TEMP_DIR} ]; then
	echo "${INSTALLER_TEMP_DIR} already exists."
	echo "Do you want to remove the existing directory and proceed? (Y/n)"
	read ANS
	case $ANS in
	  "" | [Yy]* )
	    echo "Yes"
	    rm -rf ${INSTALLER_TEMP_DIR}
	    ;;
	  * )
	    echo "Aborted."
	    exit 1
	    ;;
	esac
fi

# 作業用テンポラリディレクトリの作成
mkdir -p ${INSTALLER_TEMP_DIR}
cd ${INSTALLER_TEMP_DIR}


#------------------------------------------------------------------------------
# run68 コマンドをソースからビルドしインストール
#------------------------------------------------------------------------------
ARCHIVE="master.zip"
wget -nc https://github.com/yosshin4004/run68mac/archive/refs/heads/${ARCHIVE}
unzip ${ARCHIVE}
cd run68mac-master/
mkdir build
cd build
cmake ..
make
cd ../
cd ..

# インストール
cp --preserve=timestamps run68mac-master/build/run68* ../run68/


#------------------------------------------------------------------------------
# lha コマンドをソースからビルド
#------------------------------------------------------------------------------
ARCHIVE="release-20211125.zip"
SHA512SUM="e75dc606d7637f2c506072f2f44eda69da075a57ad2dc76f54e41b1d39d34ca01410317cc6538f8ea42f4da81ca14889df1195161f4e305d2d67189ec8e60e24"
wget -nc https://github.com/jca02266/lha/archive/refs/tags/${ARCHIVE}
if [ $(sha512sum ${ARCHIVE} | awk '{print $1}') != ${SHA512SUM} ]; then
	echo "SHA512SUM verification of ${ARCHIVE} failed!"
	exit
fi
unzip ${ARCHIVE}
cd lha-release-20211125/
autoreconf -is
sh ./configure
make
cd ../

# lha コマンド
LHA=lha-release-20211125/src/lha


#------------------------------------------------------------------------------
# HAS060.X のインストール
#------------------------------------------------------------------------------
ARCHIVE="HAS06089.LZH"
SHA512SUM="2b6947ebccc422ece82cb90b27252754a89625fbac9d9806fb774d4c70763786982ec81a6394dbcf0b9aae9e72e138c822554dbe6180aeaca998fe3c6a992f71"
wget -nc http://retropc.net/x68000/software/develop/as/has060/${ARCHIVE}
if [ $(sha512sum ${ARCHIVE} | awk '{print $1}') != ${SHA512SUM} ]; then
	echo "SHA512SUM verification of ${ARCHIVE} failed!"
	exit
fi
${LHA} -x -w=${ARCHIVE%.*} ${ARCHIVE}

# インストール
mkdir -p ../x68k_bin
mkdir -p ../archive/download
cp --preserve=timestamps ${ARCHIVE%.*}/HAS060.X ../x68k_bin/
cp --preserve=timestamps ${ARCHIVE} ../archive/download


#------------------------------------------------------------------------------
# HLK evolution のインストール
# version 3.01+15 になってから Out of memory エラーが出てしまう
#------------------------------------------------------------------------------
#ARCHIVE="hlkev15.zip"
#SHA512SUM="4fb22768f38f26f40e26e0e4a33797ecfff10f4c79966a286ea8c308020f666963b521f30f3333864decb003c16ec5e8824d491653b24faa4fce2330888c7166"
#wget -nc http://retropc.net/x68000/software/develop/lk/hlkev/${ARCHIVE}
#if [ $(sha512sum ${ARCHIVE} | awk '{print $1}') != ${SHA512SUM} ]; then
#	echo "SHA512SUM verification of ${ARCHIVE} failed!"
#	exit
#fi
#unzip -x ${ARCHIVE}
#
## インストール
#mkdir -p ../x68k_bin
#mkdir -p ../archive/download
#cp --preserve=timestamps ./hlk.r ../x68k_bin/
#cp --preserve=timestamps ${ARCHIVE} ../archive/download


#------------------------------------------------------------------------------
# HLK v3.01 のインストール
#------------------------------------------------------------------------------
ARCHIVE="HLK301B.LZH"
SHA512SUM="afe6b96b6b9549cbddc1215bf534b255b840249d1d14e149a06d4b50591e1ac0842b207bb75ec0fb0f48c04dc1cf241a6e63c6c8834479ef38e470b1abbb9a7d"
wget -nc http://retropc.net/x68000/software/develop/lk/hlk/${ARCHIVE}
if [ $(sha512sum ${ARCHIVE} | awk '{print $1}') != ${SHA512SUM} ]; then
	echo "SHA512SUM verification of ${ARCHIVE} failed!"
	exit
fi
${LHA} -x -w=${ARCHIVE%.*} ${ARCHIVE}

# インストール
mkdir -p ../x68k_bin
mkdir -p ../archive/download
cp --preserve=timestamps ${ARCHIVE%.*}/hlk301.x ../x68k_bin/
cp --preserve=timestamps ${ARCHIVE} ../archive/download


#------------------------------------------------------------------------------
# C Compiler PRO-68K ver2.1（XC）から include/ lib/ AR.X をインストール
#------------------------------------------------------------------------------
ARCHIVE="XC2101.LZH"
SHA512SUM="5746f2100a7aa8428313ccb36cdba603601eaaa131f98aba2c22016b294e50fb612930ed5edd7dbdebe2d8f12d2ff0a81eb5c7c2f37e530debb44673903809e6"
wget -nc http://retropc.net/x68000/software/sharp/xc21/${ARCHIVE}
if [ $(sha512sum ${ARCHIVE} | awk '{print $1}') != ${SHA512SUM} ]; then
	echo "SHA512SUM verification of ${ARCHIVE} failed!"
	exit
fi
${LHA} -x -w=${ARCHIVE%.*} ${ARCHIVE}

ARCHIVE="XC2102_02.LZH"
SHA512SUM="c06339be8bf3251bb0b4a37365aa013a6083294edad17a3c4fafc35ab2cd2656260454642b1fa89645e3d796fe6c0ba67ce7f541d43e0a14b6529ce5aa113ede"
wget -nc http://retropc.net/x68000/software/sharp/xc21/${ARCHIVE}
if [ $(sha512sum ${ARCHIVE} | awk '{print $1}') != ${SHA512SUM} ]; then
	echo "SHA512SUM verification of ${ARCHIVE} failed!"
	exit
fi
${LHA} -x -w=${ARCHIVE%.*} ${ARCHIVE}

# ヘッダファイルを小文字に変換
# ヘッダファイル末尾の EOF（文字コード 0x1a）を除去
pushd XC2102_02/INCLUDE
		for f in * ; do mv $f `echo $f | awk '{print tolower($0)}'`; done
		for f in * ; do cat $f | sed s/^\\x1a$//g > $f.tmp && rm $f && mv $f.tmp $f; done
popd

# インストール
rm -rf ../include/xc
rm -rf ../lib/xc
mkdir -p ../include/xc
mkdir -p ../lib/xc
mkdir -p ../x68k_bin
mkdir -p ../archive/download
cp -r XC2102_02/INCLUDE/* ../include/xc
cp -r XC2102_02/LIB/* ../lib/xc
cp -r XC2101/BIN/AR.X ../x68k_bin
cp --preserve=timestamps XC2101.LZH ../archive/download
cp --preserve=timestamps XC2102_02.LZH ../archive/download


#------------------------------------------------------------------------------
# 正常終了
#------------------------------------------------------------------------------

# 作業用テンポラリディレクトリの除去
cd ..
rm -rf ${INSTALLER_TEMP_DIR}

# 正常終了した旨を TTY 出力
echo ""
echo "-----------------------------------------------------------------------------"
echo "The installation process is completed successfully."
echo "Please set the current directory path to the environment variable XDEV68K_DIR."
echo "-----------------------------------------------------------------------------"
echo ""

