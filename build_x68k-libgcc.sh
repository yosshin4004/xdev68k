#!/usr/bin/bash
#------------------------------------------------------------------------------
#
#	build_x68k-libgcc.sh
#
#	JP:
#		m68k-toolchain を利用して X68K 用の libgcc.a を作成する。
#		build_m68k-toolchain.sh を実行した後に本スクリプトを実行する。
#
#	EN:
#		libgcc.a builder for X68K using m68k-toolchain.
#		Run this script After build_m68k-toolchain.sh has finished.
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


#-----------------------------------------------------------------------------
# 設定
#
#	build_m68k-toolchain.sh 側の設定と整合性が取れていること。
#-----------------------------------------------------------------------------

# gcc の ABI
GCC_ABI="m68k-elf"

# gcc のバージョン
GCC_VERSION="10.2.0"

# gcc ビルドディレクトリ
GCC_BUILD_DIR="build_gcc"

# libgcc ビルドディレクトリ
LIBGCC_BUILD_DIR="build_libgcc"

# m68k ツールチェインのディレクトリ
M68K_TOOLCHAIN_DIR="m68k-toolchain"

# m68k gas -> X68K has 変換
GAS2HAS="perl ./util/x68k_gas2has.pl"


#-----------------------------------------------------------------------------
# 引数の確認
#-----------------------------------------------------------------------------

# 引数無しだとヘルプメッセージを出して終了
if [ $# -eq 0 ];
then
	echo "build_x68k-libgcc.sh"
	echo ""
	echo "[usage]"
	echo "	build_x68k-libgcc.sh [options]"
	echo ""
	echo "	options:"
	echo "		-m68000"
	echo "			generate libgcc.a for m68000."
	echo ""
	echo "		-m68020"
	echo "			generate libgcc.a for m68020."
	echo ""
	echo "		-m68040"
	echo "			generate libgcc.a for m68040."
	echo ""
	echo "		-m68060"
	echo "			generate libgcc.a for m68060."
	echo ""
	echo "		--reuse-old-libgcc <filename>"
	echo "			Extract lb1sf68 objs from the specified libgcc.a file,"
	echo "			instead of assembling them from lb1sf68.S."
	echo ""
	echo "	example:"
	echo "		build_x68k-libgcc.sh -m68000 -m68020 -m68040 -m68060"
	echo ""
	exit 1
fi

# 引数解析
#	OPTIONS[オプション]=引数
OPTION="-"
declare -A OPTIONS
while [ $# -gt 0 ]
do
	case $1 in
		-m68000)
			OPTION=$1;
			OPTIONS[$OPTION]="1"
			;;
		-m68020)
			OPTION=$1;
			OPTIONS[$OPTION]="1"
			;;
		-m68040)
			OPTION=$1;
			OPTIONS[$OPTION]="1"
			;;
		-m68060)
			OPTION=$1;
			OPTIONS[$OPTION]="1"
			;;
		--reuse-old-libgcc)
			OPTION=$1;
			OPTIONS[$OPTION]=""
			;;
		-*)
			echo "ERROR: invalid option."
			exit 1
			;;
		*)
			if [ $OPTION = "-" ]; then
				echo "ERROR: invalid option."
				exit 1
			fi
			OPTIONS[$OPTION]=$1
			;;
	esac
	shift
done

# オプション指定一覧
#for OPTION in ${!OPTIONS[@]}
#do
#	echo "	${OPTION}=${OPTIONS[${OPTION}]}"
#done

# 旧 libgcc.a ファイルの再利用指定
OLD_LIBGCC_FILE_NAME=${OPTIONS["--reuse-old-libgcc"]}


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


# ターゲットとする CPU の型番
TARGETS=()
if [ -n "${OPTIONS["-m68000"]-}" ]; then
	TARGETS+=(68000)
fi
if [ -n "${OPTIONS["-m68020"]-}" ]; then
	TARGETS+=(68020)
fi
if [ -n "${OPTIONS["-m68040"]-}" ]; then
	TARGETS+=(68040)
fi
if [ -n "${OPTIONS["-m68060"]-}" ]; then
	TARGETS+=(68060)
fi

# ターゲット一覧の確認
#for TARGET in ${TARGETS[@]}
#do
#	echo "	TARGET $TARGET"
#done


# gcc の ABI 名（X68K のパス名として使える文字列で表現）
GCC_ABI_IN_X68K=`echo $GCC_ABI | sed -e "s/-/_/g"`

# ターゲットごとの分類用ディレクトリ名
TARGET_DIRS=(
	[68000]=m68000
	[68020]=m68020
	[68040]=m68040
	[68060]=m68060
)

# libgcc のビルド時に利用する include パス
INCLUDE_PATHS=(
	[68000]=${GCC_BUILD_DIR}/build/gcc-${GCC_VERSION}_stage2/${GCC_ABI}/libgcc
	[68020]=${GCC_BUILD_DIR}/build/gcc-${GCC_VERSION}_stage2/${GCC_ABI}/m68020/libgcc
	[68040]=${GCC_BUILD_DIR}/build/gcc-${GCC_VERSION}_stage2/${GCC_ABI}/m68040/libgcc
	[68060]=${GCC_BUILD_DIR}/build/gcc-${GCC_VERSION}_stage2/${GCC_ABI}/m68060/libgcc
)


# libgcc ビルド用ワークディレクトリがすでに存在するなら削除確認
if [ -d ${LIBGCC_BUILD_DIR} ]; then
	echo "${LIBGCC_BUILD_DIR} already exists."
	echo "Do you want to remove the existing directory and proceed the building process? (Y/n)"
	read ANS
	case $ANS in
	  "" | [Yy]* )
	    echo "Yes"
	    echo "removing ${LIBGCC_BUILD_DIR} ..."
	    rm -rf ${LIBGCC_BUILD_DIR}
	    ;;
	  * )
	    echo "Aborted."
	    exit 1
	    ;;
	esac
fi

# gcc ビルド用ワークディレクトリが存在しないならエラー
if [ ! -e ${GCC_BUILD_DIR} ];
then
	echo "ERROR: Can not found directory '${GCC_BUILD_DIR}'. please run build_m68k-toolchain.sh."
	exit 1
fi

# libgcc ビルド用ワークディレクトリを作成
mkdir -p ${LIBGCC_BUILD_DIR}
mkdir -p ${LIBGCC_BUILD_DIR}/src

# 旧 libgcc.a ファイルの再利用が指定されている場合
if [ -n "${OPTIONS["--reuse-old-libgcc"]-}" ]; then
	# 旧 libgcc.a ファイルが存在するなら
	if [ -e ${OLD_LIBGCC_FILE_NAME} ]; then
		# 旧 libgcc.a をワークディレクトリの src 以下にコピー
		cp ${OLD_LIBGCC_FILE_NAME} ${LIBGCC_BUILD_DIR}/src/libgcc.a
	else
		# エラー
		echo "ERROR: Can not found '${OLD_LIBGCC_FILE_NAME}'."
		exit 1
	fi
fi

# X68K のコマンド
RUN68="${XDEV68K_DIR}/run68/run68.exe"
AS="${RUN68} ${XDEV68K_DIR}/x68k_bin/HAS060.X"
AR="${RUN68} ${XDEV68K_DIR}/x68k_bin/AR.X"


#-----------------------------------------------------------------------------
# 全てのターゲット環境に対して
#-----------------------------------------------------------------------------
for TARGET in ${TARGETS[@]}
do
	echo "generating libgcc.a for ${TARGET}."
	TARGET_DIR=${TARGET_DIRS[$TARGET]}

	# ターゲットのソースディレクトリ名
	LIBGCC_TARGET_SRC_DIR=${LIBGCC_BUILD_DIR}/src/${GCC_ABI_IN_X68K}/${TARGET_DIR}

	# ディレクトリ生成
	mkdir -p ${LIBGCC_TARGET_SRC_DIR}
	mkdir -p ${LIBGCC_TARGET_SRC_DIR}/dep


	#-----------------------------------------------------------------------------
	# lb1sf68.S から HAS 形式のソースファイル群を生成する
	#-----------------------------------------------------------------------------

	# lb1sf68.S から生成するオブジェクトファイル名
	#	[オブジェクトファイル名]=ソースファイル名
	#	X68K のファイル名規則に違反する場合はここでリネームする。
	declare -A SRC_FILES_EMIT_FROM_LB1SF68
	# 旧 libgcc.a ファイルの再利用が指定されていない場合のみ有効
	if [ ! -n "${OPTIONS["--reuse-old-libgcc"]-}" ]; then
		SRC_FILES_EMIT_FROM_LB1SF68=(
			[_mulsi3]=_mulsi3
			[_udivsi3]=_udivsi3
			[_divsi3]=_divsi3
			[_umodsi3]=_umodsi3
			[_modsi3]=_modsi3
			[_double]=_double
			[_float]=_float
			[_floatex]=_floatex
			[_eqdf2]=_eqdf2
			[_nedf2]=_nedf2
			[_gtdf2]=_gtdf2
			[_gedf2]=_gedf2
			[_ltdf2]=_ltdf2
			[_ledf2]=_ledf2
			[_eqsf2]=_eqsf2
			[_nesf2]=_nesf2
			[_gtsf2]=_gtsf2
			[_gesf2]=_gesf2
			[_ltsf2]=_ltsf2
			[_lesf2]=_lesf2
		)
	fi

	# lb1sf68.S をプリプロセスして得られたソースファイルを HAS 形式に変換
	for OBJ in ${!SRC_FILES_EMIT_FROM_LB1SF68[@]}
	do
		SRC=${SRC_FILES_EMIT_FROM_LB1SF68[$OBJ]}
		echo "	generating ${OBJ}.s from lb1sf68.S."
		${M68K_TOOLCHAIN_DIR}/bin/${GCC_ABI}-cpp -E -DL${OBJ} -o ${LIBGCC_TARGET_SRC_DIR}/${OBJ}_.s ${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/config/m68k/lb1sf68.S
		${GAS2HAS} -i ${LIBGCC_TARGET_SRC_DIR}/${OBJ}_.s -o ${LIBGCC_TARGET_SRC_DIR}/${OBJ}.s -cpu ${TARGET}
		rm ${LIBGCC_TARGET_SRC_DIR}/${OBJ}_.s
	done

	# 依存ファイルを収集
	cp ${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/config/m68k/lb1sf68.S ${LIBGCC_TARGET_SRC_DIR}/dep


	#-----------------------------------------------------------------------------
	# libgcc2.c からソースファイル群を生成
	#-----------------------------------------------------------------------------

	# コンパイルオプション
	CFLAGS="\
		-B${XDEV68K_DIR}/build_gcc/build/gcc-${GCC_VERSION}_stage2/./gcc/\
		-B${M68K_TOOLCHAIN_DIR}/${GCC_ABI}/bin/\
		-B${M68K_TOOLCHAIN_DIR}/${GCC_ABI}/lib/\
		-isystem ${M68K_TOOLCHAIN_DIR}/${GCC_ABI}/include\
		-isystem ${M68K_TOOLCHAIN_DIR}/${GCC_ABI}/sys-include\
		-O2 -DIN_GCC -DCROSS_DIRECTORY_STRUCTURE\
		-W -Wall -Wwrite-strings -Wcast-qual -Wstrict-prototypes -Wold-style-definition\
		-Wno-narrowing -Wno-missing-prototypes -Wno-implicit-function-declaration\
		-DIN_LIBGCC2 -fbuilding-libgcc -fno-stack-protector\
		-Dinhibit_libc\
		-isystem ${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/include\
		-isystem ${GCC_BUILD_DIR}/build/gcc-${GCC_VERSION}_stage2/gcc\
		-I${INCLUDE_PATHS[$TARGET]}\
		-I${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc\
		-I${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/.\
		-I${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/../gcc\
		-I${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/../include\
		-DHAVE_CC_TLS\
		-fvisibility=hidden\
		-DHIDE_EXPORTS\
		-m${TARGET}\
		 -fcall-used-d2 -fcall-used-a2\
    "

	# libgcc2.c から生成するオブジェクトファイル名
	#	[オブジェクトファイル名]=ソースファイル名
	#	X68K のファイル名規則に違反する場合はここでリネームする。
	declare -A SRC_FILES_EMIT_FROM_LIBGCC2
	SRC_FILES_EMIT_FROM_LIBGCC2=(
		[_muldi3]=_muldi3
		[_negdi2]=_negdi2
		[_lshrdi3]=_lshrdi3
		[_ashldi3]=_ashldi3
		[_ashrdi3]=_ashrdi3
		[_cmpdi2]=_cmpdi2
		[_ucmpdi2]=_ucmpdi2
		[_clear_cache]=_clear_cache
		[_trampoline]=_trampoline
		[__main]=__main
		[_absvsi2]=_absvsi2
		[_absvdi2]=_absvdi2
		[_addvsi3]=_addvsi3
		[_addvdi3]=_addvdi3
		[_subvsi3]=_subvsi3
		[_subvdi3]=_subvdi3
		[_mulvsi3]=_mulvsi3
		[_mulvdi3]=_mulvdi3
		[_negvsi2]=_negvsi2
		[_negvdi2]=_negvdi2
		[_ctors]=_ctors
		[_ffssi2]=_ffssi2
		[_ffsdi2]=_ffsdi2
		[_clz]=_clz
		[_clzsi2]=_clzsi2
		[_clzdi2]=_clzdi2
		[_ctzsi2]=_ctzsi2
		[_ctzdi2]=_ctzdi2
		[_popcount_tab]=_popcount_tab
		[_popcountsi2]=_popcountsi2
		[_popcountdi2]=_popcountdi2
		[_paritysi2]=_paritysi2
		[_paritydi2]=_paritydi2
		[_powisf2]=_powisf2
		[_powidf2]=_powidf2
		[_powixf2]=_powixf2
		[_powitf2]=_powitf2
		[_mulhc3]=_mulhc3
		[_mulsc3]=_mulsc3
		[_muldc3]=_muldc3
		[_mulxc3]=_mulxc3
		[_multc3]=_multc3
		[_divhc3]=_divhc3
		[_divsc3]=_divsc3
		[_divdc3]=_divdc3
		[_divxc3]=_divxc3
		[_divtc3]=_divtc3
		[_bswapsi2]=_bswapsi2
		[_bswapdi2]=_bswapdi2
		[_clrsbsi2]=_clrsbsi2
		[_clrsbdi2]=_clrsbdi2
		[_fixunssfsi]=_fixunssfsi
		[_fixunsdfsi]=_fixunsdfsi
		[_fixunsxfsi]=_fixunsxfsi
		[_fixsfdi]=_fixsfdi
		[_fixdfdi]=_fixdfdi
		[_fixxfdi]=_fixxfdi
		[_fixtfdi]=_fixtfdi
		[_fixunssfdi]=_fixunssfdi
		[_fixunsdfdi]=_fixunsdfdi
		[_fixunsxfdi]=_fixunsxfdi
		[_fixunstfdi]=_fixunstfdi
		[_floatdisf]=_floatdisf
		[_floatdidf]=_floatdidf
		[_floatdixf]=_floatdixf
		[_floatditf]=_floatditf
		[_floatundisf]=_floatundisf
		[_floatundidf]=_floatundidf
		[_floatundixf]=_floatundixf
		[_floatunditf]=_floatunditf
		[_eprintf]=_eprintf
		[__gcc_bcmp]=__gcc_bcmp
		[_divdi3]=_divdi3
		[_moddi3]=_moddi3
		[_divmoddi4]=_divmoddi4
		[_udivdi3]=_udivdi3
		[_umoddi3]=_umoddi3
		[_udivmoddi4]=_udivmoddi4
		[_udiv_w_sdiv]=_udiv_w_sdiv
	)

	# libgcc2.c からソースファイルを生成する
	for OBJ in ${!SRC_FILES_EMIT_FROM_LIBGCC2[@]}
	do
		SRC=${SRC_FILES_EMIT_FROM_LIBGCC2[$OBJ]}
		echo "	generating ${OBJ}.s from libgcc2.c."
		${M68K_TOOLCHAIN_DIR}/bin/${GCC_ABI}-gcc ${CFLAGS} -S -o ${LIBGCC_TARGET_SRC_DIR}/${OBJ}_.s -DL${SRC} -c ${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/libgcc2.c
		${GAS2HAS} -i ${LIBGCC_TARGET_SRC_DIR}/${OBJ}_.s -o ${LIBGCC_TARGET_SRC_DIR}/${OBJ}.s -cpu ${TARGET} -inline-asm-syntax gas
		rm ${LIBGCC_TARGET_SRC_DIR}/${OBJ}_.s

		# 依存ファイルを収集
		${M68K_TOOLCHAIN_DIR}/bin/${GCC_ABI}-gcc ${CFLAGS} -c -M ${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/libgcc2.c -MF ${LIBGCC_TARGET_SRC_DIR}/${OBJ}.d
		DEP_FILES=(`cat ${LIBGCC_TARGET_SRC_DIR}/${OBJ}.d`)
		for DEP_FILE in ${DEP_FILES[@]}
		do
			if [ -e ${DEP_FILE} ]; then
				cp ${DEP_FILE} ${LIBGCC_TARGET_SRC_DIR}/dep
			fi
		done
		rm ${LIBGCC_TARGET_SRC_DIR}/${OBJ}.d
	done


	#-----------------------------------------------------------------------------
	# その他のソースファイル群を生成
	#-----------------------------------------------------------------------------

	# _xfgnulib.c を生成する
	echo '#define EXTFLOAT' > ${LIBGCC_TARGET_SRC_DIR}/_xfgnulib.c
	cat ${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/config/m68k/fpgnulib.c >> ${LIBGCC_TARGET_SRC_DIR}/_xfgnulib.c

	# libgcc2.c 以外のファイルから生成するオブジェクトファイル名
	#	[オブジェクトファイル名]=ソースファイル名
	#	X68K のファイル名規則に違反する場合はここでリネームする。
	declare -A SRC_FILES_EMIT_NOT_FROM_LIBGCC2
	SRC_FILES_EMIT_NOT_FROM_LIBGCC2=(
		[_xfgnulib]=${LIBGCC_TARGET_SRC_DIR}/_xfgnulib
		[_fpgnulib]=${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/config/m68k/fpgnulib
		[_en_exe_stack]=${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/enable-execute-stack-empty
		[_unwind_dw2]=${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/unwind-dw2
		[_unwind_dw2_fde]=${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/unwind-dw2-fde
		[_unwind_sjlj]=${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/unwind-sjlj
		[_unwind_c]=${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/unwind-c
		[_emutls]=${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libgcc/emutls
	)

	# libgcc2.c 以外のファイルに由来するソースファイルを生成する
	for OBJ in ${!SRC_FILES_EMIT_NOT_FROM_LIBGCC2[@]}
	do
		SRC=${SRC_FILES_EMIT_NOT_FROM_LIBGCC2[$OBJ]}
		echo "	generating ${OBJ}.s from ${SRC}.c."
		${M68K_TOOLCHAIN_DIR}/bin/${GCC_ABI}-gcc ${CFLAGS} -S -o ${LIBGCC_TARGET_SRC_DIR}/${OBJ}_.s -c ${SRC}.c
		${GAS2HAS} -i ${LIBGCC_TARGET_SRC_DIR}/${OBJ}_.s -o ${LIBGCC_TARGET_SRC_DIR}/${OBJ}.s -cpu ${TARGET} -inline-asm-syntax gas
		rm ${LIBGCC_TARGET_SRC_DIR}/${OBJ}_.s

		# 依存ファイルを収集
		${M68K_TOOLCHAIN_DIR}/bin/${GCC_ABI}-gcc ${CFLAGS} -c -M ${SRC}.c -MF ${LIBGCC_TARGET_SRC_DIR}/${OBJ}.d
		DEP_FILES=(`cat ${LIBGCC_TARGET_SRC_DIR}/${OBJ}.d`)
		for DEP_FILE in ${DEP_FILES[@]}
		do
			if [ -e ${DEP_FILE} ]; then
				cp ${DEP_FILE} ${LIBGCC_TARGET_SRC_DIR}/dep
			fi
		done
		rm ${LIBGCC_TARGET_SRC_DIR}/${OBJ}.d
	done

	# _xfgnulib.c を除去する
	rm ${LIBGCC_TARGET_SRC_DIR}/_xfgnulib.c


	#-----------------------------------------------------------------------------
	# アセンブルとアーカイブファイルの作成
	#-----------------------------------------------------------------------------

	# ディレクトリ移動
	pushd ${LIBGCC_TARGET_SRC_DIR}

	# lb1sf68.S から生成されたソースファイルのアセンブル
	for OBJ in ${!SRC_FILES_EMIT_FROM_LB1SF68[@]}
	do
		${AS} -e -u -w0 -m ${TARGET} ${OBJ}.s
	done

	# libgcc2.c から生成されたソースファイルのアセンブル
	for OBJ in ${!SRC_FILES_EMIT_FROM_LIBGCC2[@]}
	do
		${AS} -e -u -w0 -m ${TARGET} ${OBJ}.s
	done

	# libgcc2.c 以外から生成されたソースファイルのアセンブル
	for OBJ in ${!SRC_FILES_EMIT_NOT_FROM_LIBGCC2[@]}
	do
		${AS} -e -u -w0 -m ${TARGET} ${OBJ}.s
	done

	# 旧 libgcc.a から再利用可能なオブジェクトファイル名
	#	[コピー先オブジェクトファイル名]=コピー元オブジェクトファイル名
	declare -A OBJ_FILES_COPY_FROM_X68K_LIBGCC
	# 旧 libgcc.a ファイルの再利用が指定されている場合のみ有効
	if [ -n "${OPTIONS["--reuse-old-libgcc"]-}" ]; then
		OBJ_FILES_COPY_FROM_X68K_LIBGCC=(
			[_adddf3]=_adddf3
			[_divsf3]=_divsf3
			[_gesf2]=_gesf2
			[_ltdf2]=_ltdf2
			[_mulsi3]=_mulsi3
			[_subdf3]=_subdf3
			[_addsf3]=_addsf3
			[_divsi3]=_divsi3
			[_gtdf2]=_gtdf2
			[_ltsf2]=_ltsf2
			[_nedf2]=_nedf2
			[_subsf3]=_subsf3
			[_cmpdf2]=_cmpdf2
			[_eqdf2]=_eqdf2
			[_gtsf2]=_gtsf2
			[_modsi3]=_modsi3
			[_negdf2]=_negdf2
			[_udivsi3]=_udivsi3
			[_cmpsf2]=_cmpsf2
			[_eqsf2]=_eqsf2
			[_ledf2]=_ledf2
			[_muldf3]=_muldf3
			[_negsf2]=_negsf2
			[_umodsi3]=_umodsi3
			[_divdf3]=_divdf3
			[_gedf2]=_gedf2
			[_lesf2]=_lesf2
			[_mulsf3]=_mulsf3
			[_nesf2]=_nesf2
		)
	fi

	# 旧 libgcc.a からオブジェクトファイルを取り出し
	for SRC in ${!OBJ_FILES_COPY_FROM_X68K_LIBGCC[@]}
	do
		DST=${OBJ_FILES_COPY_FROM_X68K_LIBGCC[$SRC]}
		${AR} -x ${OLD_LIBGCC_FILE_NAME_FOR_X68K} ${DST}.o
		# 抽出成功を確認
		if [ ! -e ${DST}.o ]; then
			echo "Can not extract ${DST}.o"
			exit 1;
		fi
	done

	# lb1sf68.S から生成されたオブジェクトファイルをアーカイブ
	for OBJ in ${!SRC_FILES_EMIT_FROM_LB1SF68[@]}
	do
		${AR} -u libgcc.a ${OBJ}.o
	done

	# libgcc2.c から生成されたオブジェクトファイルをアーカイブ
	for OBJ in ${!SRC_FILES_EMIT_FROM_LIBGCC2[@]}
	do
		${AR} -u libgcc.a ${OBJ}.o
	done

	# libgcc2.c 以外から生成されたオブジェクトファイルをアーカイブ
	for OBJ in ${!SRC_FILES_EMIT_NOT_FROM_LIBGCC2[@]}
	do
		${AR} -u libgcc.a ${OBJ}.o
	done

	# 旧 libgcc.a から取り出したオブジェクトファイルをアーカイブ
	for OBJ in ${!OBJ_FILES_COPY_FROM_X68K_LIBGCC[@]}
	do
		${AR} -u libgcc.a ${OBJ}.o
	done

	# デプロイ
	mkdir -p ${XDEV68K_DIR}/lib/m68k_elf/${TARGET_DIR}/
	mv ./libgcc.a ${XDEV68K_DIR}/lib/m68k_elf/${TARGET_DIR}/libgcc.a

	# オブジェクトファイルは除去
	rm *.o

	# 正常終了
	echo "Successfully generated libgcc.a for ${TARGET}."

	# ディレクトリ復帰
	popd
done


#-----------------------------------------------------------------------------
# ソースコードパッケージの作成
#-----------------------------------------------------------------------------
ROOT_DIR="${PWD}"
cd ${LIBGCC_BUILD_DIR}/src/
tar -zcvf libgcc_src.tar.gz ${GCC_ABI_IN_X68K}/
mkdir -p ${XDEV68K_DIR}/archive/
mv libgcc_src.tar.gz ${XDEV68K_DIR}/archive/libgcc_src.tar.gz
cd ${ROOT_DIR}


#-----------------------------------------------------------------------------
# 次の操作を促す
#-----------------------------------------------------------------------------

echo ""
echo "-----------------------------------------------------------------------------"
echo "The building process is completed successfully."
echo "-----------------------------------------------------------------------------"
echo ""
exit 0


