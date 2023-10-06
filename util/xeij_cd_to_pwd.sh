#!/usr/bin/bash
#------------------------------------------------------------------------------
#
#	xeij_cd_to_pwd.sh
#
#	JP:
#		XEiJ のカレントディレクトリをホスト環境のカレントディレクトリに
#		移動する。
#
#		使用例:
#			~/.bashrc などに以下のような関数を登録しておく。
#
#				cdx() {
#				  cd $1
#				  ${XDEV68K_DIR}/util/xeij_cd_to_pwd.sh
#				}
#
#			XEiJ 管理下のディレクトリで以下のコマンドを実行することで、
#			ホスト環境と XEiJ 環境のディレクトリ移動が同時に実行される。
#
#				cdx dirname
#
#	EN:
#		Move the current directory of XEiJ to the current directory of
#		the host environment.
#
#		Usage example:
#			Define the following function in ~/.bashrc, etc.
#
#				cdx() {
#				  cd $1
#				  ${XDEV68K_DIR}/util/xeij_cd_to_pwd.sh
#				}
#
#			By executing the following command in an XEiJ-managed
#			directory, a directory move between the host and XEiJ
#			environments will be performed simultaneously.
#
#				cdx dirname
#
#------------------------------------------------------------------------------
#
#	Copyright (C) 2023 Yosshin(@yosshin4004)
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


#-----------------------------------------------------------------------------
# 準備
#-----------------------------------------------------------------------------

# エラーが起きたらそこで終了させる。
# 未定義変数を参照したらエラーにする。
set -eu

# msys 以外の環境は未サポート
# WSL もサポートしたいが、名前付きパイプにアクセスする簡便な方法が不明。
if [ "$(expr substr $(uname -s) 1 5)" != "MINGW" ]; then
	echo "Only msys is supported as host environment. Please use msys."
	exit 1
fi


# 環境変数の確認
if [ -z ${XDEV68K_DIR-} ]; then
	echo "Please set XDEV68K_DIR environment variable."
	exit 1
fi
if [ -z ${XEIJ_BOOT_DIR-} ]; then
	echo "Please set XEIJ_BOOT_DIR environment variable."
	exit 1
fi


# msys などの場合、パス文字に C: 等のドライブ名から始まる windows フォーマット
# と、/c 等から始まる Unix フォーマットが利用できる。フォーマットが混在して
# いると相対パス作成時に問題があるので、Unix フォーマットで統一するように促す。
if [[ ! ${XDEV68K_DIR} =~ ^\/ ]]; then
	echo "ERROR:  \${XDEV68K_DIR} is not Unix format. (${XDEV68K_DIR})"
	exit 1
fi
if [[ ! ${XEIJ_BOOT_DIR} =~ ^\/ ]]; then
	echo "ERROR:  \${XEIJ_BOOT_DIR} is not Unix format. (${XEIJ_BOOT_DIR})"
	exit 1
fi


# XEiJ の boot ディレクトリから見たカレントディレクトリの相対パス
REL_BOOT_TO_PWD=`realpath --relative-to=${XEIJ_BOOT_DIR} .`

# 相対パスが .. で始まる場合は、XEiJ の boot ディレクトリ以下で実行されていないのでエラー。
if [[ ${REL_BOOT_TO_PWD} =~ ^\.\. ]]; then
	echo "ERROR: Invalid relative path. Please run under \${XEIJ_BOOT_DIR}."
	exit 1
fi

# パスの / を \ に置換する（多重にエスケープシーケンスされてとても読みづらいが・・・）
REL_BOOT_TO_PWD_X68K=`echo ${REL_BOOT_TO_PWD} | sed s/\\\\//\\\\\\\\/g`


# コマンド短縮名
#	msys から実行する場合、cmd.exe //c としないと、バッチファイル実行後自動で
#	exit してくれない。
XEIJ_PASTE="cmd.exe //c ${XDEV68K_DIR}/util/xeij_paste.bat"


# X68K 側のカレントディレクトリを移動する
${XEIJ_PASTE} cd \\${REL_BOOT_TO_PWD_X68K}

