*-----------------------------------------------------------------------------
* このファイルは、Project C Library の LIBC 1.1.32A ぱっち DON 版 (libcd4.tgz)
* に含まれていた fefunc.h を複製し、拡張子を inc にリネームしたものです。
*
* SHARP の XC コンパイラにも同名のファイルがありますが、中身が異なっています。
* xdev68k では Project C Library 版の fefunc.h を利用しています。
* また、ファイル名の混同を避けるため、拡張子を inc にリネームしています。
*
*
* オリジナルファイルは以下の URL から入手可能です。
* http://retropc.net/x68000/software/develop/lib/libcdon/
* このファイルのライセンスはオリジナルと同様 public domain とします。
* 以下、オリジナルファイルをそのまま収録いたします。
*-----------------------------------------------------------------------------

* -*-Fundamental-*-
*
* PROJECT C Library, X68000 PROGRAMMING INTERFACE DEFINITION
* --------------------------------------------------------------------
* This file is written by the Project C Library Group,  and completely
* in public domain. You can freely use, copy, modify, and redistribute
* the whole contents, without this notice.
* --------------------------------------------------------------------
* $Id: fefunc.h,v 1.1 1993/04/19 22:11:45 mura Exp $
*
		.nlist

__LMUL:		.equ		$fe00
__LDIV:		.equ		$fe01
__LMOD:		.equ		$fe02
__UMUL:		.equ		$fe04
__UDIV:		.equ		$fe05
__UMOD:		.equ		$fe06
__IMUL:		.equ		$fe08
__IDIV:		.equ		$fe09
__RANDOMIZE:	.equ		$fe0c
__SRAND:	.equ		$fe0d
__RAND:		.equ		$fe0e
__STOL:		.equ		$fe10
__LTOS:		.equ		$fe11
__STOH:		.equ		$fe12
__HTOS:		.equ		$fe13
__STOO:		.equ		$fe14
__OTOS:		.equ		$fe15
__STOB:		.equ		$fe16
__BTOS:		.equ		$fe17
__IUSING:	.equ		$fe18
__LTOD:		.equ		$fe1a
__DTOL:		.equ		$fe1b
__LTOF:		.equ		$fe1c
__FTOL:		.equ		$fe1d
__FTOD:		.equ		$fe1e
__DTOF:		.equ		$fe1f
__VAL:		.equ		$fe20
__USING:	.equ		$fe21
__STOD:		.equ		$fe22
__DTOS:		.equ		$fe23
__ECVT:		.equ		$fe24
__FCVT:		.equ		$fe25
__GCVT:		.equ		$fe26
__DTST:		.equ		$fe28
__DCMP:		.equ		$fe29
__DNEG:		.equ		$fe2a
__DADD:		.equ		$fe2b
__DSUB:		.equ		$fe2c
__DMUL:		.equ		$fe2d
__DDIV:		.equ		$fe2e
__DMOD:		.equ		$fe2f
__DABS:		.equ		$fe30
__DCEIL:	.equ		$fe31
__DFIX:		.equ		$fe32
__DFLOOR:	.equ		$fe33
__DFRAC:	.equ		$fe34
__DSGN:		.equ		$fe35
__SIN:		.equ		$fe36
__COS:		.equ		$fe37
__TAN:		.equ		$fe38
__ATAN:		.equ		$fe39
__LOG:		.equ		$fe3a
__EXP:		.equ		$fe3b
__SQR:		.equ		$fe3c
__PI:		.equ		$fe3d
__NPI:		.equ		$fe3e
__POWER:	.equ		$fe3f
__RND:		.equ		$fe40
__DFREXP:	.equ		$fe49
__DLDEXP:	.equ		$fe4a
__DADDONE:	.equ		$fe4b
__DSUBONE:	.equ		$fe4c
__DDIVTWO:	.equ		$fe4d
__DIEECNV:	.equ		$fe4e
__IEEDCNV:	.equ		$fe4f
__FVAL:		.equ		$fe50
__FUSING:	.equ		$fe51
__STOF:		.equ		$fe52
__FTOS:		.equ		$fe53
__FECVT:	.equ		$fe54
__FFCVT:	.equ		$fe55
__FGCVT:	.equ		$fe56
__FTST:		.equ		$fe58
__FCMP:		.equ		$fe59
__FNEG:		.equ		$fe5a
__FADD:		.equ		$fe5b
__FSUB:		.equ		$fe5c
__FMUL:		.equ		$fe5d
__FDIV:		.equ		$fe5e
__FMOD:		.equ		$fe5f
__FABS:		.equ		$fe60
__FCEIL:	.equ		$fe61
__FFIX:		.equ		$fe62
__FFLOOR:	.equ		$fe63
__FFRAC:	.equ		$fe64
__FSGN:		.equ		$fe65
__FSIN:		.equ		$fe66
__FCOS:		.equ		$fe67
__FTAN:		.equ		$fe68
__FATAN:	.equ		$fe69
__FLOG:		.equ		$fe6a
__FEXP:		.equ		$fe6b
__FSQR:		.equ		$fe6c
__FPI:		.equ		$fe6d
__FNPI:		.equ		$fe6e
__FPOWER:	.equ		$fe6f
__FRND:		.equ		$fe70
__FFREXP:	.equ		$fe79
__FLDEXP:	.equ		$fe7a
__FADDONE:	.equ		$fe7b
__FSUBONE:	.equ		$fe7c
__FDIVTWO:	.equ		$fe7d
__FIEECNV:	.equ		$fe7e
__IEEFCNV:	.equ		$fe7f
__CLMUL:	.equ		$fee0
__CLDIV:	.equ		$fee1
__CLMOD:	.equ		$fee2
__CUMUL:	.equ		$fee3
__CUDIV:	.equ		$fee4
__CUMOD:	.equ		$fee5
__CLTOD:	.equ		$fee6
__CDTOL:	.equ		$fee7
__CLTOF:	.equ		$fee8
__CFTOL:	.equ		$fee9
__CFTOD:	.equ		$feea
__CDTOF:	.equ		$feeb
__CDCMP:	.equ		$feec
__CDADD:	.equ		$feed
__CDSUB:	.equ		$feee
__CDMUL:	.equ		$feef
__CDDIV:	.equ		$fef0
__CDMOD:	.equ		$fef1
__CFCMP:	.equ		$fef2
__CFADD:	.equ		$fef3
__CFSUB:	.equ		$fef4
__CFMUL:	.equ		$fef5
__CFDIV:	.equ		$fef6
__CFMOD:	.equ		$fef7
__CDTST:	.equ		$fef8
__CFTST:	.equ		$fef9
__CDINC:	.equ		$fefa
__CFINC:	.equ		$fefb
__CDDEC:	.equ		$fefc
__CFDEC:	.equ		$fefd
__FEVARG:	.equ		$fefe
__FEVECS:	.equ		$feff

FPACK:		.macro		callname
		.dc		callname
		.endm

		.list
