#!/usr/bin/bash
#------------------------------------------------------------------------------
#
#	build_x68k-libstdc++.sh
#
#	JP:
#		m68k-toolchain を利用して X68K 用の libstdc++.a を作成する。
#		build_m68k-toolchain.sh を実行した後に本スクリプトを実行する。
#
#	EN:
#		libstdc++.a builder for X68K using m68k-toolchain.
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

# libstdc++ ビルドディレクトリ
LIBSTDCXX_BUILD_DIR="build_libstdc++"

# m68k ツールチェインのディレクトリ
M68K_TOOLCHAIN="m68k-toolchain"

# m68k gas -> X68K has 変換
GAS2HAS="perl ./util/x68k_gas2has.pl"


#-----------------------------------------------------------------------------
# 引数の確認
#-----------------------------------------------------------------------------

# 引数無しだとヘルプメッセージを出して終了
if [ $# -eq 0 ];
then
	echo "build_x68k-libstdc++.sh"
	echo ""
	echo "[usage]"
	echo "	build_x68k-libstdc++.sh [options]"
	echo ""
	echo "	options:"
	echo "		-m68000"
	echo "			generate libstdc++.a for m68000."
	echo ""
	echo "		-m68020"
	echo "			generate libstdc++.a for m68020."
	echo ""
	echo "		-m68040"
	echo "			generate libstdc++.a for m68040."
	echo ""
	echo "		-m68060"
	echo "			generate libstdc++.a for m68060."
	echo ""
	echo "	example:"
	echo "		build_x68k-libstdc++.sh -m68000 -m68020 -m68040 -m68060"
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

# CPU 種別ごとのソースディレクトリ名
CPU_DIRS=(
	[68000]=
	[68020]=/m68020
	[68040]=/m68040
	[68060]=/m68060
)


# libstdc++ ビルド用ワークディレクトリがすでに存在するなら削除確認
if [ -d ${LIBSTDCXX_BUILD_DIR} ]; then
	echo "${LIBSTDCXX_BUILD_DIR} already exists."
	echo "Do you want to remove the existing directory and proceed the building process? (Y/n)"
	read ANS
	case $ANS in
	  "" | [Yy]* )
	    echo "Yes"
	    echo "removing ${LIBSTDCXX_BUILD_DIR} ..."
	    rm -rf ${LIBSTDCXX_BUILD_DIR}
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

# libstdc++ ビルド用ワークディレクトリを作成
mkdir -p ${LIBSTDCXX_BUILD_DIR}
mkdir -p ${LIBSTDCXX_BUILD_DIR}/src

# X68K のコマンド
RUN68="${XDEV68K_DIR}/run68/run68.exe"
AS="${RUN68} ${XDEV68K_DIR}/x68k_bin/HAS060.X"
AR="${RUN68} ${XDEV68K_DIR}/x68k_bin/AR.X"


#-----------------------------------------------------------------------------
# 全てのターゲット環境に対して
#-----------------------------------------------------------------------------
for TARGET in ${TARGETS[@]}
do
	echo "generating libstdc++.a for ${TARGET}."
	TARGET_DIR=${TARGET_DIRS[$TARGET]}

	# CPU の種類ごとのディレクトリ
	CPU_DIR=${CPU_DIRS[$TARGET]}

	# ターゲットのソース生成先ディレクトリ名
	LIBSTDCXX_TARGET_SRC_DIR=${LIBSTDCXX_BUILD_DIR}/src/${GCC_ABI_IN_X68K}/${TARGET_DIR}

	# libstdc++ ソースディレクトリ名
	GCC_SRC_LIBSTDCXX_DIR=${GCC_BUILD_DIR}/src/gcc-${GCC_VERSION}/libstdc++-v3

	# libstdc++ ビルドディレクトリ名
	GCC_BUILD_LIBSTDCXX_DIR=${GCC_BUILD_DIR}/build/gcc-${GCC_VERSION}_stage2/${GCC_ABI}${CPU_DIR}/libstdc++-v3

	# ディレクトリ生成
	mkdir -p ${LIBSTDCXX_TARGET_SRC_DIR}
	mkdir -p ${LIBSTDCXX_TARGET_SRC_DIR}/dep


	#-----------------------------------------------------------------------------
	# libstdc++ の asm ファイル作成
	#-----------------------------------------------------------------------------

	# C コンパイルオプション
	CFLAGS="\
		-isystem ${XDEV68K_DIR}/m68k-toolchain/m68k-elf/include\
		-isystem ${XDEV68K_DIR}/m68k-toolchain/m68k-elf/sys-include\
		-DHAVE_CONFIG_H\
		-I${GCC_BUILD_LIBSTDCXX_DIR}\
		-I${GCC_SRC_LIBSTDCXX_DIR}/../libiberty\
		-I${GCC_SRC_LIBSTDCXX_DIR}/../include\
		-I${GCC_BUILD_LIBSTDCXX_DIR}/include/m68k-elf\
		-I${GCC_BUILD_LIBSTDCXX_DIR}/include\
		-I${GCC_SRC_LIBSTDCXX_DIR}/libsupc++\
		-O2\
		-DIN_GLIBCPP_V3\
		-Wno-error\
	"

	# libstdc++.a にアーカイブするオブジェクトファイル名とオブジェクトファイルを生成するコマンドライン（c ソース）
	#	[オブジェクトファイル名]=コンパイル引数
	#	X68K のファイル名規則に違反する場合はここでリネームする。
	declare -A CSRC_ARGS
	CSRC_ARGS=(
#		[cp-demangle]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/libsupc++/cp-demangle.c -DIN_GLIBCPP_V3 -Wno-error"
	)

	# C コンパイル
	for OBJ in ${!CSRC_ARGS[@]}
	do
		CSRC_ARG=${CSRC_ARGS[$OBJ]}
		OBJ_QUOTE=`printf "%q" "${OBJ}"`

		echo "	generating ${OBJ}.s"
		${M68K_TOOLCHAIN}/bin/${GCC_ABI}-gcc ${CFLAGS} -S -o ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}_.s ${CSRC_ARG}
		${GAS2HAS} -i ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}_.s -o ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}.s -cpu ${TARGET} -inline-asm-syntax gas
		rm ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}_.s

		# 依存ファイルを収集
		${M68K_TOOLCHAIN}/bin/${GCC_ABI}-gcc ${CFLAGS} -M ${CSRC_ARG} -MF ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}.d
		DEP_FILES=(`cat ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}.d`)
		for DEP_FILE in ${DEP_FILES[@]}
		do
			if [ -e ${DEP_FILE} ]; then
				cp ${DEP_FILE} ${LIBSTDCXX_TARGET_SRC_DIR}/dep
			fi
		done
		rm ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}.d
	done

	# C++ コンパイルオプション
	CXXFLAGS="\
		-isystem ${M68K_TOOLCHAIN}/${GCC_ABI}/include\
		-isystem ${M68K_TOOLCHAIN}/${GCC_ABI}/sys-include\
		-I${GCC_SRC_LIBSTDCXX_DIR}/../libgcc\
		-I${GCC_BUILD_LIBSTDCXX_DIR}/include/${GCC_ABI}\
		-I${GCC_BUILD_LIBSTDCXX_DIR}/include\
		-I${GCC_SRC_LIBSTDCXX_DIR}/libsupc++\
		-mcpu=$TARGET\
		-std=gnu++17\
		-fno-implicit-templates -Wall -Wextra -Wwrite-strings -Wcast-qual -Wabi=2\
		-fdiagnostics-show-location=once -ffunction-sections -fdata-sections\
		-frandom-seed=complex_io.lo\
		-O2\
		-fno-rtti -fno-exceptions\
		-fcall-used-d2 -fcall-used-a2\
    "

	# libstdc++.a にアーカイブするオブジェクトファイル名とオブジェクトファイルを生成するコマンドライン（c++ ソース）
	#	[オブジェクトファイル名]=コンパイル引数
	#	X68K のファイル名規則に違反する場合はここでリネームする。
	declare -A CXXSRC_ARGS
	CXXSRC_ARGS=(
		[compatibility]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/compatibility.cc -std=gnu++98"
		[compat-debuglist]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/compatibility-debug_list.cc -std=gnu++98"			# *.o ファイル名を短縮した
		[compat-debuglist2]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/compatibility-debug_list-2.cc -std=gnu++98"		# *.o ファイル名を短縮した
		[compat-c++0x]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/compatibility-c++0x.cc -std=gnu++11"					# *.o ファイル名を短縮した
		[compat-atmc++0x]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/compatibility-atomic-c++0x.cc -std=gnu++11"		# *.o ファイル名を短縮した
		[compat-thrc++0x]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/compatibility-thread-c++0x.cc -std=gnu++11"		# *.o ファイル名を短縮した
		[compat-chrono]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/compatibility-chrono.cc -std=gnu++11"				# *.o ファイル名を短縮した
		[compat-condvar]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/compatibility-condvar.cc -std=gnu++11"				# *.o ファイル名を短縮した
		[array_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/array_type_info.cc"
		[atexit_arm]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/atexit_arm.cc"
		[atexit_thread]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/atexit_thread.cc"
		[bad_alloc]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/bad_alloc.cc"
		[bad_array_length]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/bad_array_length.cc"
		[bad_array_new]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/bad_array_new.cc"
		[bad_cast]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/bad_cast.cc"
		[bad_typeid]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/bad_typeid.cc"
		[class_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/class_type_info.cc"
		[del_op]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_op.cc"
		[del_opa]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opa.cc -std=gnu++1z"
		[del_opant]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opant.cc -std=gnu++1z"
		[del_opnt]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opnt.cc"
		[del_ops]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_ops.cc"
		[del_opsa]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opsa.cc -std=gnu++1z"
		[del_opv]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opv.cc"
		[del_opva]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opva.cc -std=gnu++1z"
		[del_opvant]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opvant.cc -std=gnu++1z"
		[del_opvnt]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opvnt.cc"
		[del_opvs]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opvs.cc"
		[del_opvsa]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/del_opvsa.cc -std=gnu++1z"
		[dyncast]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/dyncast.cc"
		[eh_alloc]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_alloc.cc"
		[eh_arm]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_arm.cc"
		[eh_aux_runtime]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_aux_runtime.cc"
		[eh_call]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_call.cc"
		[eh_catch]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_catch.cc"
		[eh_exception]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_exception.cc"
		[eh_globals]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_globals.cc"
		[eh_personality]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_personality.cc"
		[eh_ptr]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_ptr.cc"
		[eh_term_handler]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_term_handler.cc"
		[eh_terminate]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_terminate.cc"
		[eh_throw]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_throw.cc"
		[eh_tm]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_tm.cc"
		[eh_type]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_type.cc"
		[eh_unex_handler]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/eh_unex_handler.cc"
		[enum_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/enum_type_info.cc"
		[function_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/function_type_info.cc"
		[fund_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/fundamental_type_info.cc"			# *.o ファイル名を短縮した
		[guard]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/guard.cc"
		[guard_error]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/guard_error.cc"
		[hash_bytes]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/hash_bytes.cc"
		[nested_exception]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/nested_exception.cc"
		[new_handler]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/new_handler.cc"
		[new_op]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/new_op.cc"
		[new_opa]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/new_opa.cc -std=gnu++1z"
		[new_opant]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/new_opant.cc -std=gnu++1z"
		[new_opnt]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/new_opnt.cc"
		[new_opv]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/new_opv.cc"
		[new_opva]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/new_opva.cc -std=gnu++1z"
		[new_opvant]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/new_opvant.cc -std=gnu++1z"
		[new_opvnt]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/new_opvnt.cc"
		[pbase_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/pbase_type_info.cc"
		[pmem_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/pmem_type_info.cc"
		[pointer_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/pointer_type_info.cc"
		[pure]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/pure.cc"
		[si_class_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/si_class_type_info.cc"
		[tinfo]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/tinfo.cc"
		[tinfo2]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/tinfo2.cc"
		[vec]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/vec.cc"
		[vmi_class_type_info]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/vmi_class_type_info.cc"
		[vterminate]="-c ${GCC_SRC_LIBSTDCXX_DIR}/libsupc++/vterminate.cc"

		[allocator-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/allocator-inst.cc -std=gnu++98"
		[atomicity]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/atomicity.cc -std=gnu++98"
		[basic_file]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/basic_file.cc -std=gnu++98"
		[bitmap_allocator]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/bitmap_allocator.cc -std=gnu++98"
		[c++locale]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/c++locale.cc -std=gnu++98 -fimplicit-templates"
		[codecvt]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/codecvt.cc -std=gnu++98"
		[codecvt_members]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/codecvt_members.cc -std=gnu++98"
		[collate_members]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/collate_members.cc -std=gnu++98"
		[collate_members_cow]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/collate_members_cow.cc -std=gnu++98 -D_GLIBCXX_USE_CXX11_ABI=0 -fimplicit-templates"
		[complex_io]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/complex_io.cc -std=gnu++98"
		[concept-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/concept-inst.cc -std=gnu++98 -D_GLIBCXX_CONCEPT_CHECKS -fimplicit-templates"
		[cow-istream-string]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/cow-istream-string.cc -std=gnu++98"
		[ext-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/ext-inst.cc -std=gnu++98"
		[globals_io]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/globals_io.cc -std=gnu++98"
		[hash_tr1]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/hash_tr1.cc -std=gnu++98"
		[hashtable_tr1]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/hashtable_tr1.cc -std=gnu++98"
		[ios_failure]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/ios_failure.cc -std=gnu++98"
		[ios_init]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/ios_init.cc -std=gnu++98"
		[ios_locale]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/ios_locale.cc -std=gnu++98"
		[istream-string]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/istream-string.cc -std=gnu++98"
		[istream]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/istream.cc -std=gnu++98"
		[list-aux-2]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/list-aux-2.cc -std=gnu++98"
		[list-aux]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/list-aux.cc -std=gnu++98"
		[list]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/list.cc -std=gnu++98"
		[list_associated-2]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/list_associated-2.cc -std=gnu++98"
		[list_associated]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/list_associated.cc -std=gnu++98"
		[locale]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/locale.cc -std=gnu++98"
		[locale_facets]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/locale_facets.cc -std=gnu++98"
		[locale_init]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/locale_init.cc -std=gnu++11 -fchar8_t"
		[localename]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/localename.cc -std=gnu++11 -fchar8_t"
		[math_stubs_float]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/math_stubs_float.cc -std=gnu++98"
		[math_stubs_ldouble]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/math_stubs_long_double.cc -std=gnu++98"			# *.o ファイル名を短縮した
		[messages_members]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/messages_members.cc -std=gnu++98"
		[messages_members_cow]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/messages_members_cow.cc -std=gnu++98 -D_GLIBCXX_USE_CXX11_ABI=0 -fimplicit-templates"
		[misc-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/misc-inst.cc -std=gnu++98"
		[monetary_members]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/monetary_members.cc -std=gnu++98"
		[monetary_members_cow]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/monetary_members_cow.cc -std=gnu++98 -D_GLIBCXX_USE_CXX11_ABI=0 -fimplicit-templates"
		[mt_allocator]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/mt_allocator.cc -std=gnu++98"
		[numeric_members]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/numeric_members.cc -std=gnu++98"
		[numeric_members_cow]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/numeric_members_cow.cc -std=gnu++98 -D_GLIBCXX_USE_CXX11_ABI=0 -fimplicit-templates"
		[parallel_settings]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/parallel_settings.cc -std=gnu++98 -D_GLIBCXX_PARALLEL"
		[pool_allocator]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/pool_allocator.cc -std=gnu++98"
		[stdexcept]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/stdexcept.cc -std=gnu++98"
		[streambuf]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/streambuf.cc -std=gnu++98"
		[strstream]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/strstream.cc -std=gnu++98 -I${GCC_BUILD_DIR}/gcc-${GCC_VERSION}_stage2/${GCC_ABI}/libstdc++-v3/include/backward -Wno-deprecated"
		[time_members]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++98/time_members.cc -std=gnu++98"
		[tree]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/tree.cc -std=gnu++98"
		[valarray]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++98/valarray.cc -std=gnu++98"

		[chrono]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/chrono.cc -std=gnu++11"
		[lt1-codecvt]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/codecvt.cc -std=gnu++11 -fchar8_t"
		[condition_variable]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/condition_variable.cc -std=gnu++11"
		[cow-fstream-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cow-fstream-inst.cc -std=gnu++11"
		[cow-locale_init]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cow-locale_init.cc -std=gnu++11"
		[cow-shim_facets]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cow-shim_facets.cc -std=gnu++11"
		[cow-sstream-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cow-sstream-inst.cc -std=gnu++11"
		[cow-stdexcept]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cow-stdexcept.cc -std=gnu++11"
		[cow-string-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cow-string-inst.cc -std=gnu++11"
		[cow-string-io-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cow-string-io-inst.cc -std=gnu++11"
		[cow-wstring-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cow-wstring-inst.cc -std=gnu++11"
		[cow-wstring-io-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cow-wstring-io-inst.cc -std=gnu++11"
		[ctype]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/ctype.cc -std=gnu++11"
		[ctype_configure_char]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++11/ctype_configure_char.cc -std=gnu++11"
		[ctype_members]="-c ${GCC_BUILD_LIBSTDCXX_DIR}/src/c++11/ctype_members.cc -std=gnu++11"
		[cxx11-hash_tr1]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cxx11-hash_tr1.cc -std=gnu++11"
		[cxx11-ios_failure]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cxx11-ios_failure.cc -std=gnu++11"		# オリジナルの実装では -S で asm を生成したのちパッチを適用している
		[cxx11-locale-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cxx11-locale-inst.cc -std=gnu++11"
		[cxx11-shim_facets]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cxx11-shim_facets.cc -std=gnu++11"
		[cxx11-stdexcept]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cxx11-stdexcept.cc -std=gnu++11"
		[cxx11-wlocale-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/cxx11-wlocale-inst.cc -std=gnu++11"
		[debug]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/debug.cc -std=gnu++11"
		[ext11-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/ext11-inst.cc -std=gnu++11"
		[fstream-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/fstream-inst.cc -std=gnu++11"
		[functexcept]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/functexcept.cc -std=gnu++11"
		[functional]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/functional.cc -std=gnu++11"
		[futex]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/futex.cc -std=gnu++11"
		[future]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/future.cc -std=gnu++11"
		[hash_c++0x]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/hash_c++0x.cc -std=gnu++11"
		[hashtable_c++0x]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/hashtable_c++0x.cc -std=gnu++11"
		[ios-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/ios-inst.cc -std=gnu++11"
		[ios]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/ios.cc -std=gnu++11"
		[iostream-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/iostream-inst.cc -std=gnu++11"
		[istream-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/istream-inst.cc -std=gnu++11"
		[limits]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/limits.cc -std=gnu++11"
		[locale-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/locale-inst.cc -std=gnu++11"
		[mutex]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/mutex.cc -std=gnu++11"
		[ostream-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/ostream-inst.cc -std=gnu++11"
		[placeholders]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/placeholders.cc -std=gnu++11"
		[random]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/random.cc -std=gnu++11"
		[regex]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/regex.cc -std=gnu++11"
		[shared_ptr]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/shared_ptr.cc -std=gnu++11"
		[snprintf_lite]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/snprintf_lite.cc -std=gnu++11"
		[sso_string]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/sso_string.cc -std=gnu++11"
		[sstream-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/sstream-inst.cc -std=gnu++11"
		[streambuf-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/streambuf-inst.cc -std=gnu++11"
		[string-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/string-inst.cc -std=gnu++11"
		[string-io-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/string-io-inst.cc -std=gnu++11"
		[system_error]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/system_error.cc -std=gnu++11"
		[thread]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/thread.cc -std=gnu++11"
		[wlocale-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/wlocale-inst.cc -std=gnu++11"
		[wstring-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/wstring-inst.cc -std=gnu++11"
		[wstring-io-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++11/wstring-io-inst.cc -std=gnu++11"

		[cow-fs_dir]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/cow-fs_dir.cc -std=gnu++17 -fimplicit-templates"
		[cow-fs_ops]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/cow-fs_ops.cc -std=gnu++17 -fimplicit-templates"
		[cow-fs_path]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/cow-fs_path.cc -std=gnu++17 -fimplicit-templates"
		[lt2-cow-string-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/cow-string-inst.cc -std=gnu++17 -fimplicit-templates"
		[fs_dir]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/fs_dir.cc -std=gnu++17 -fimplicit-templates"
		[fs_ops]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/fs_ops.cc -std=gnu++17 -fimplicit-templates"
		[fs_path]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/fs_path.cc -std=gnu++17 -fimplicit-templates"
		[memory_resource]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/memory_resource.cc -std=gnu++17 -fimplicit-templates"
		[lt3-ostream-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/ostream-inst.cc -std=gnu++17 -fimplicit-templates"
		[lt4-string-inst]="-c ${GCC_SRC_LIBSTDCXX_DIR}/src/c++17/string-inst.cc -std=gnu++17 -fimplicit-templates"
	)

	# C++ コンパイル
	for OBJ in ${!CXXSRC_ARGS[@]}
	do
		CXXSRC_ARG=${CXXSRC_ARGS[$OBJ]}
		OBJ_QUOTE=`printf "%q" "${OBJ}"`

		echo "	generating ${OBJ}.s"
		${M68K_TOOLCHAIN}/bin/${GCC_ABI}-g++ ${CXXFLAGS} -S -o ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}_.s ${CXXSRC_ARG}
		${GAS2HAS} -i ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}_.s -o ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}.s -cpu ${TARGET} -inline-asm-syntax gas

		rm ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}_.s

		# 依存ファイルを収集
		${M68K_TOOLCHAIN}/bin/${GCC_ABI}-gcc ${CXXFLAGS} -M ${CXXSRC_ARG} -MF ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}.d
		DEP_FILES=(`cat ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}.d`)
		for DEP_FILE in ${DEP_FILES[@]}
		do
			if [ -e ${DEP_FILE} ]; then
				cp ${DEP_FILE} ${LIBSTDCXX_TARGET_SRC_DIR}/dep
			fi
		done
		rm ${LIBSTDCXX_TARGET_SRC_DIR}/${OBJ}.d
	done


	#-----------------------------------------------------------------------------
	# アセンブルとアーカイブファイルの作成
	#-----------------------------------------------------------------------------

	# ディレクトリ移動
	pushd ${LIBSTDCXX_TARGET_SRC_DIR}

	# *.c 由来ソースファイルのアセンブルとアーカイブ更新
	for OBJ in ${!CSRC_ARGS[@]}
	do
		${AS} -e -u -w0 -m ${TARGET} ${OBJ}.s
		${AR} -u libstdc++.a ${OBJ}.o
	done

	# *.cc 由来ソースファイルのアセンブルとアーカイブ更新
	for OBJ in ${!CXXSRC_ARGS[@]}
	do
		${AS} -e -u -w0 -m ${TARGET} ${OBJ}.s
		${AR} -u libstdc++.a ${OBJ}.o
	done

	# デプロイ
	mkdir -p ${XDEV68K_DIR}/lib/m68k_elf/${TARGET_DIR}/
	mv ./libstdc++.a ${XDEV68K_DIR}/lib/m68k_elf/${TARGET_DIR}/libstdc++.a

	# オブジェクトファイルは除去
	rm *.o

	# 正常終了
	echo "Successfully generated libstdc++.a for ${TARGET}."

	# ディレクトリ復帰
	popd
done


#-----------------------------------------------------------------------------
# ソースコードパッケージの作成
#-----------------------------------------------------------------------------
ROOT_DIR="${PWD}"
cd ${LIBSTDCXX_BUILD_DIR}/src/
tar -zcvf libgcc_src.tar.gz ${GCC_ABI_IN_X68K}/
mkdir -p ${XDEV68K_DIR}/archive/
mv libgcc_src.tar.gz ${XDEV68K_DIR}/archive/libstdc++_src.tar.gz
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


