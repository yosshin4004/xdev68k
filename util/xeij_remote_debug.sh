#!/usr/bin/bash
#------------------------------------------------------------------------------
#
#	xeij_remote_debug.sh
#
#	JP:
#		指定のコマンドラインを XEiJ 上でデバッグ実行する。
#
#	EN:
#		Launch the specified command line on XEiJ with a debugger.
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
# 引数の確認
#-----------------------------------------------------------------------------

# 引数無しだとヘルプメッセージを出して終了
if [ $# -eq 0 ];
then
	echo "xeij_remote_debug.sh"
	echo ""
	echo "[usage]"
	echo "	xeij_remote_debug.sh [filename]"
	echo ""
	echo "	example:"
	echo "		xeij_remote_debug.sh MAIN.X"
	echo ""
	exit 1
fi

# コマンドライン
COMMAND_LINE=$@


#-----------------------------------------------------------------------------
# 準備
#-----------------------------------------------------------------------------

# エラーが起きたらそこで終了させる。
# 未定義変数を参照したらエラーにする。
set -eu

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
REL_PATH=`shell realpath --relative-to=${XEIJ_BOOT_DIR} .`

# 相対パスが .. で始まる場合は、XEiJ の boot ディレクトリ以下で実行されていないのでエラー。
if [[ ${REL_PATH} =~ ^\.\. ]]; then
	echo "ERROR: Invalid relative path. Please run under \${XEIJ_BOOT_DIR}."
	exit 1
fi

# DB.X のパス
DBX_PATH=${XDEV68K_DIR}/x68k_bin/DB.X

# DB.X が存在しないならエラー
if [ ! -e ${DBX_PATH} ]; then
	echo "ERROR: ${DBX_PATH} does not exist."
	exit 1
fi

# XEiJ の boot ディレクトリから見た DB.X の相対パス
DBX_REL_PATH=`shell realpath --relative-to=${XEIJ_BOOT_DIR} ${DBX_PATH}`

# 相対パスが .. で始まる場合は、XEiJ の boot ディレクトリ以下で実行されていないのでエラー。
if [[ ${DBX_REL_PATH} =~ ^\.\. ]]; then
	echo "ERROR: Invalid relative path. Please locate \${XDEV68K_DIR} under \${XEIJ_BOOT_DIR}."
	exit 1
fi

# 相対パスの / を \ に置換する（多重にエスケープシーケンスされてとても読みづらいが・・・）
REL_PATH_X68K=`echo ${REL_PATH} | sed s/\\\\//\\\\\\\\/g`
DBX_REL_PATH_X68K=`echo ${DBX_REL_PATH} | sed s/\\\\//\\\\\\\\/g`


#-----------------------------------------------------------------------------
# デバッグ実行
#-----------------------------------------------------------------------------

function abort
{
	echo "$@" 1>&2
	exit 1
}


# XEiJ が利用できることを確認するため、ダミー処理を paste する（失敗したらエラー終了）
cmd //c ${XDEV68K_DIR}/util/xeij_paste.bat rem || abort ERROR: XEiJ is not available.

# カレントディレクトリを移動する
cmd //c ${XDEV68K_DIR}/util/xeij_paste.bat cd \\${REL_PATH_X68K}

# デバッガから実行ファイルを起動する
cmd //c ${XDEV68K_DIR}/util/xeij_paste.bat \\${DBX_REL_PATH_X68K} ${COMMAND_LINE}

# デバッグ開始
cmd //c ${XDEV68K_DIR}/util/xeij_paste.bat G

# ホスト側をキー入力待ちにする
read -p "Press [Enter] key to interrupt."

# デバッグ中断
cmd //c ${XDEV68K_DIR}/util/xeij_control.bat interrupt

# DB.X へのコマンドは、以下のようにコロン区切りで複数を一括指定できる。
# 操作を aux に切り替えてレジスタ情報と PC 周辺のディスアセンブルを表示する。
cmd //c ${XDEV68K_DIR}/util/xeij_paste.bat V:X:L.pc:L.pc:L.pc:V

# デバッガを抜ける
cmd //c ${XDEV68K_DIR}/util/xeij_paste.bat Q

# 画面を初期化
cmd //c ${XDEV68K_DIR}/util/xeij_paste.bat screen

