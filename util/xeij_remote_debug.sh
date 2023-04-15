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
	echo "		xeij_remote_debug.sh MAIN.X -hoge fuga -piyo geba"
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
REL_BOOT_TO_PWD=`shell realpath --relative-to=${XEIJ_BOOT_DIR} .`

# 相対パスが .. で始まる場合は、XEiJ の boot ディレクトリ以下で実行されていないのでエラー。
if [[ ${REL_BOOT_TO_PWD} =~ ^\.\. ]]; then
	echo "ERROR: Invalid relative path. Please run under \${XEIJ_BOOT_DIR}."
	exit 1
fi


# XEiJ の boot ディレクトリから見た xdev68k の相対パス
REL_BOOT_TO_XDEV68K=`shell realpath --relative-to=${XEIJ_BOOT_DIR} ${XDEV68K_DIR}`

# 相対パスが .. で始まる場合は、xdev68k が XEiJ の boot ディレクトリ以下に配置されていないのでエラー。
if [[ ${REL_BOOT_TO_XDEV68K} =~ ^\.\. ]]; then
	echo "ERROR: Invalid relative path. Please locate \${XDEV68K_DIR} under \${XEIJ_BOOT_DIR}."
	exit 1
fi


# カレントディレクトリから見た xdev68k のパス
REL_PWD_TO_XDEV68K=`shell realpath --relative-to=. ${XDEV68K_DIR}`


# DB.X のパス、および boot ディレクトリから見た相対パス
DBX=${XDEV68K_DIR}/x68k_bin/DB.X
REL_BOOT_TO_DBX=`shell realpath --relative-to=${XEIJ_BOOT_DIR} ${DBX}`

# DB.X が存在しないならエラー
if [ ! -e ${DBX} ]; then
	echo "ERROR: ${DBX} does not exist."
	exit 1
fi


# DB.X バッチスクリプトのパス、および boot ディレクトリから見た相対パス
REL_PWD_TO_DB_PUSH_STATES=${REL_PWD_TO_XDEV68K}/util/db_push_states.txt
REL_PWD_TO_DB_POP_STATES=${REL_PWD_TO_XDEV68K}/util/db_pop_states.txt
REL_PWD_TO_DB_CMD=${REL_PWD_TO_XDEV68K}/util/db_cmd.txt

# パスの / を \ に置換する（多重にエスケープシーケンスされてとても読みづらいが・・・）
REL_BOOT_TO_PWD_X68K=`echo ${REL_BOOT_TO_PWD} | sed s/\\\\//\\\\\\\\/g`
REL_BOOT_TO_XDEV68K_X68K=`echo ${REL_BOOT_TO_XDEV68K} | sed s/\\\\//\\\\\\\\/g`
REL_BOOT_TO_DBX_X68K=`echo ${REL_BOOT_TO_DBX} | sed s/\\\\//\\\\\\\\/g`
REL_PWD_TO_DB_PUSH_STATES=`echo ${REL_PWD_TO_DB_PUSH_STATES} | sed s/\\\\//\\\\\\\\/g`
REL_PWD_TO_DB_POP_STATES=`echo ${REL_PWD_TO_DB_POP_STATES} | sed s/\\\\//\\\\\\\\/g`
REL_PWD_TO_DB_CMD=`echo ${REL_PWD_TO_DB_CMD} | sed s/\\\\//\\\\\\\\/g`


# コマンド短縮名
#	msys から実行する場合、cmd.exe //c としないと、バッチファイル実行後自動で
#	exit してくれない。
XEIJ_PASTE="cmd.exe //c ${XDEV68K_DIR}/util/xeij_paste.bat"
XEIJ_CONTROL="cmd.exe //c ${XDEV68K_DIR}/util/xeij_control.bat"
XEIJ_CAT="cmd.exe //c ${XDEV68K_DIR}/util/xeij_cat.bat"


#-----------------------------------------------------------------------------
# デバッグ実行
#-----------------------------------------------------------------------------

function abort
{
	echo "$@" 1>&2
	exit 1
}


# XEiJ が利用できることを確認するため、ダミー処理を paste する（失敗したらエラー終了）
${XEIJ_PASTE} rem || abort ERROR: XEiJ is not available.

# X68K 側のカレントディレクトリを移動する
${XEIJ_PASTE} cd \\${REL_BOOT_TO_PWD_X68K}

# デバッガから実行ファイルを起動する
${XEIJ_PASTE} \\${REL_BOOT_TO_DBX_X68K} ${COMMAND_LINE}

# 割り込み周りのハードウェアステートを退避する。
# デバッガのシステム変数は Z0～Z10 の 10 個しかないので、必要最小限のステートしか
# 退避できない。ここでは、主にゲーム系で使われる割り込み設定のみを対象としている。
# db_push_interrupt_settings.txt は、以下の処理を一括で行う。
#	Z9=.sr				Z9 にステータスレジスタ退避
#	X sr				ステータスレジスタ変更
#	.sr^|700			ステータスレジスタ |= 0x700（割り込み off）
#	Z0=[E88003].b		Z0 に AER 退避
#	Z1=[E88007].b		Z1 に IERA 退避
#	Z2=[E88009].b		Z2 に IERB 退避
#	Z3=[E88013].b		Z3 に IMRA 退避
#	Z4=[E88015].b		Z4 に IMRB 退避
#	Z5=[118].l			Z5 に V-disp ベクタ退避
#	Z6=[138].l			Z6 に CRT-IRQ ベクタ退避
#	Z7=[E80012].w		Z7 に CRT-IRQ ラスタ No. 退避
${XEIJ_CAT} ${REL_PWD_TO_DB_PUSH_STATES}

# デバッグ開始
${XEIJ_PASTE} G

# ホスト側をキー入力待ちにする
read -p "Press [Enter] key to interrupt."

# デバッグ中断
${XEIJ_CONTROL} interrupt

# 操作を aux に切り替えてレジスタ情報と PC 周辺のディスアセンブルを表示する。
#	V		操作を aux に切り替え
#	X		レジスタ情報の表示
#	L.pc	プログラムカウンタの位置からディスアセンブル
#	V		操作を aux に切り替え
# aux への切り替えと復帰を一括実行する必要がある。
# デバッガのコマンドを一括実行するには、コロン区切りでコマンドを列挙する。
${XEIJ_PASTE} V:X:L.pc:L.pc:L.pc:V

# 割り込み周りのハードウェアステートを復帰する。
# db_pop_interrupt_settings.txt は、以下の処理を一括で行う。
#	X sr				ステータスレジスタ変更
#	.sr^|700			ステータスレジスタ |= 0x700（割り込み off）
#	MEsE88003.Z0		Z0 から AER 復帰
#	MEsE88007.Z1		Z1 から IERA 復帰
#	MEsE88009.Z2		Z2 から IERB 復帰
#	MEsE88013.Z3		Z3 から IMRA 復帰
#	MEsE88015.Z4		Z4 から IMRB 復帰
#	MEl118.Z5			Z5 から V-disp ベクタ復帰
#	MEl138.Z6			Z6 から CRT-IRQ ベクタ復帰
#	MEwE80012.Z7		Z7 から CRT-IRQ ラスタ No. 復帰
#	X sr				ステータスレジスタ変更
#	.Z9					ステータスレジスタ = Z9（割り込み設定復帰）
${XEIJ_CAT} ${REL_PWD_TO_DB_POP_STATES}

# デバッガを抜ける
${XEIJ_PASTE} Q

# 画面を初期化
${XEIJ_PASTE} screen

