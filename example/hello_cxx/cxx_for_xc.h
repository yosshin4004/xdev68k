#ifndef	CXX_FOR_XC_H
#define	CXX_FOR_XC_H

#ifdef __cplusplus
extern "C" {
#endif

void execute_static_ctors();

void __cxa_atexit(void (*p)());

#ifdef __cplusplus
}
#endif

#endif
