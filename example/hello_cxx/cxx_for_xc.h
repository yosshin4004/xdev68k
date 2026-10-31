#ifndef	CXX_FOR_XC_H
#define	CXX_FOR_XC_H

#ifdef __cplusplus
extern "C" {
#endif

void execute_static_ctors();

int __cxa_atexit(void (*func)(void *), void *object, void *dso);

#ifdef __cplusplus
}
#endif

#endif
