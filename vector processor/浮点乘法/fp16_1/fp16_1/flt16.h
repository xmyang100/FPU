#ifndef _FP16_H_
#define _FP16_H_

#include "data_type_redef.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct FLT16{
    INT8 sign;
    INT32 exp;
    INT32 sig;
    FLT64 flt64;
} FLT16;

FLT16 FLT64ToFLT16 (FLT64 input);

FLT16 MyPluFLT16 (FLT16 a, FLT16 b);

FLT16 MyMulFLT16 (FLT16 a, FLT16 b);

FLT16 MySubFLT16 (FLT16 a, FLT16 b);

FLT16 MyDivFLT16 (FLT16 a, FLT16 b);


#ifdef __cplusplus
}
#endif

#endif  /* end of _QUANTIZATIOIN_H_ */