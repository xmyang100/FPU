#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "flt16.h"
#include "top_ctrl.h"

#if (BF16_MODE == (ON))
    #define EXP_WITCH (8)
    #define SIG_WITCH (7)
#else
    #define EXP_WITCH (5)
    #define SIG_WITCH (10)
#endif

#define FP32_BIAS (127)
#define FP16_BIAS (15)
#define BIAS_32TO16 (FP32_BIAS - FP16_BIAS)

#define FP32_BIT_SIGN (31)
#define FP32_BIT_EXP  (23)
#define FP16_BIT_SIGN (15)
#define FP16_BIT_EXP  (10)

#define FP16_CONCAT(s, e, f) \
    (((s & 0x1) << FP16_BIT_SIGN) | ((e & 0x1f) << FP16_BIT_EXP) | (f & 0x3ff))

#define FP16_NAN     (0xffff)
#define FP16_ZERO(s) FP16_CONCAT(s, 0, 0)
#define FP16_INF(s)  FP16_CONCAT(s, 0x1f, 0)

FLT16 FLT64ToFLT16 (FLT64 input)
{
    FLT16 y;

    // INT32 bin32;
    // memcpy(&bin32, &input, sizeof(bin32));
    // y.sign = (INT32)((bin32 & 0x80000000) >> (FP32_BIT_SIGN));
    // y.exp  = (INT32)((bin32 & 0x7F800000) >> (FP32_BIT_EXP));
    // y.sig = (INT32)((bin32 & 0x007FFFFF) >> (FP32_BIT_EXP - FP16_BIT_EXP)); // use upper 10 bits.
    // // y.sig = (INT32)(bin32 & 0x007FFFFF);

    // if (y.exp == 0x00 && y.sig == 0x0000)
    // {
    //     y.exp = 0;
    //     y.sig = 0; 
    // }
    // else if (y.exp == 0xff)
    // {
    //     if (y.sig == 0x0000)
    //     {
    //         y.exp = 0x1f;
    //         y.sig = 0; 
    //     }
    //     else
    //     {
    //         y.sign = 1;
    //         y.exp = 0x1f;
    //         y.sig = 0x3ff; 
    //     }
    // }

    // if (y.exp < BIAS_32TO16)
    // {
    //     y.exp = 0x00; // lower limit
    // } 
    // else if ((y.exp - 0x1f) > BIAS_32TO16)
    // {
    //     y.exp = 0x1f; // upper limit
    // }
    // else
    // {
    //     y.exp -= BIAS_32TO16;
    // }
        
    INT32 i = 0;

    if (fabs(input) <= 1e-10)
    {
        y.sign = 0;
        y.sig = 0;
        y.exp = 0;
    }
    else
    {
        if (input < 0)
        {
            y.sign = 1;
            input *= -1;
        }
        else
        {
            y.sign = 0;
        }

        y.exp = pow(2, (EXP_WITCH - 1)) - 1;
        while (input < 1)
        {
            input *= 2;
            y.exp -= 1;
        }
        while (input > 2)
        {
            input /= 2;
            y.exp += 1;
        }
        input -= 1;
        y.sig = 0;
        for (i = 0; i < SIG_WITCH; i++)
        {
            input *= 2;
            if (input >= 1)
            {
                input -= 1;
                y.sig += pow(2, (SIG_WITCH - 1 - i));
            }
        }
    }
    
    if ((y.exp == 0) && (y.sig == 0)) y.flt64 = 0;
    else if (y.exp >= (pow(2, (EXP_WITCH - 1)) - 1)) y.flt64 = pow(-1.0, y.sign) * pow(2, y.exp - (pow(2, (EXP_WITCH - 1)) - 1)) * (y.sig / pow(2, SIG_WITCH) + 1);
    else y.flt64 = pow(-1.0, y.sign) / pow(2, (pow(2, (EXP_WITCH - 1)) - 1) - y.exp) * (y.sig / pow(2, SIG_WITCH) + 1);

    return y;
}

FLT16 MyPluFLT16 (FLT16 a, FLT16 b)
{
    FLT16 c;
    INT32 sig = 0;
    INT32 exp = 0;
    INT32 l;

    if ((a.exp == 0) && (a.sig == 0))
    {
        c = b;
    }
    else if ((b.exp == 0) && (b.sig == 0))
    {
        c = a;
    }
    else
    {
        if (a.sign == b.sign)
        {
            c.sign = a.sign;
            a.sig += pow(2, SIG_WITCH);
            b.sig += pow(2, SIG_WITCH);
            if (a.exp > b.exp)
            {
                l = a.exp - b.exp;
                b.exp = a.exp;
                b.sig /= pow(2, l);
            }
            else if (a.exp < b.exp)
            {
                l = b.exp - a.exp;
                a.exp = b.exp;
                a.sig /= pow(2, l);
            }

            sig = a.sig + b.sig;
            exp = b.exp;
            while (sig >= pow(2, (SIG_WITCH + 1)))
            {
                sig /= 2;
                exp += 1;
            }

            c.sig = sig - pow(2, SIG_WITCH);
            c.exp = exp;
        }
        else   
        {
            if (a.exp == b.exp)
            {
                if (a.sig == b.sig)
                {
                    c.sign = 0;
                    c.sig = 0;
                    c.exp = 0;
                }
                else
                {
                    if (a.sig > b.sig)
                    {
                        c.sign = a.sign;
                        sig = a.sig - b.sig;
                        exp = b.exp;
                    }
                    else
                    {
                        c.sign = b.sign;
                        sig = b.sig - a.sig;
                        exp = a.exp;
                    }
                    while (sig < pow(2, SIG_WITCH))
                    {
                        sig *= 2;
                        exp -= 1;
                    }
                    c.sig = sig - pow(2, SIG_WITCH);
                    c.exp = exp;
                } 
            }
            else
            {
                a.sig += pow(2, SIG_WITCH);
                b.sig += pow(2, SIG_WITCH);
                if (a.exp > b.exp)
                {
                    c.sign = a.sign;
                    l = a.exp - b.exp;
                    b.exp = a.exp;
                    b.sig /= pow(2, l);
                    sig = a.sig - b.sig;
                    exp = b.exp;
                }
                else
                {
                    c.sign = b.sign;
                    l = b.exp - a.exp;
                    a.exp = b.exp;
                    a.sig /= pow(2, l);
                    sig = b.sig - a.sig;
                    exp = a.exp;
                }
                while (sig < pow(2, SIG_WITCH))
                {
                    sig *= 2;
                    exp -= 1;
                }
                c.sig = sig - pow(2, SIG_WITCH);
                c.exp = exp;
            }
            
        }
    }

    if ((c.exp == 0) && (c.sig == 0)) c.flt64 = 0;
    else if (c.exp >= (pow(2, (EXP_WITCH - 1)) - 1)) c.flt64 = pow(-1.0, c.sign) * pow(2, c.exp - (pow(2, (EXP_WITCH - 1)) - 1)) * (c.sig / pow(2, SIG_WITCH) + 1);
    else c.flt64 = pow(-1.0, c.sign) / pow(2, (pow(2, (EXP_WITCH - 1)) - 1) - c.exp) * (c.sig / pow(2, SIG_WITCH) + 1);

    return c;
}

FLT16 MyMulFLT16 (FLT16 a, FLT16 b)
{
    INT32 i;
    FLT16 c;
    FLT64 sig;

    if ((a.exp == 0) && (a.sig == 0))
    {
        c = a;
    }
    else if ((b.exp == 0) && (b.sig == 0))
    {
        c = b;
    }
    else
    {
        c.sign = (a.sign + b.sign) % 2;

        c.exp = a.exp + b.exp - (pow(2, (EXP_WITCH - 1)) - 1);
        sig = ((a.sig + pow(2, SIG_WITCH)) / (1.0 * pow(2, SIG_WITCH))) * ((b.sig + pow(2, SIG_WITCH)) / (1.0 * pow(2, SIG_WITCH)));

        while (sig >= 2)
        {
            sig /= 2;
            c.exp += 1;
        }
        sig -= 1;

        c.sig = 0;
        for (i = 0; i < SIG_WITCH; i++)
        {
            sig *= 2;
            if (sig >= 1)
            {
                sig -= 1;
                c.sig += pow(2, ((SIG_WITCH - 1) - i));
            }
        }
    }
    
    if ((c.exp == 0) && (c.sig == 0)) c.flt64 = 0;
    else if (c.exp >= (pow(2, (EXP_WITCH - 1)) - 1)) c.flt64 = pow(-1.0, c.sign) * pow(2, c.exp - (pow(2, (EXP_WITCH - 1)) - 1)) * (c.sig / pow(2, SIG_WITCH) + 1);
    else c.flt64 = pow(-1.0, c.sign) / pow(2, (pow(2, (EXP_WITCH - 1)) - 1) - c.exp) * (c.sig / pow(2, SIG_WITCH) + 1);
    
    return c;
}

FLT16 MySubFLT16 (FLT16 a, FLT16 b)
{
    FLT16 c;

    if ((b.exp != 0) || (b.sig != 0))
    {
        b.sign = 1 - b.sign;
    }

    c = MyPluFLT16(a, b);

    if ((c.exp == 0) && (c.sig == 0)) c.flt64 = 0;
    else if (c.exp >= (pow(2, (EXP_WITCH - 1)) - 1)) c.flt64 = pow(-1.0, c.sign) * pow(2, c.exp - (pow(2, (EXP_WITCH - 1)) - 1)) * (c.sig / pow(2, SIG_WITCH) + 1);
    else c.flt64 = pow(-1.0, c.sign) / pow(2, (pow(2, (EXP_WITCH - 1)) - 1) - c.exp) * (c.sig / pow(2, SIG_WITCH) + 1);

    return c;
}

FLT16 MyDivFLT16 (FLT16 a, FLT16 b)
{
    FLT16 c;
    INT32 i;
    FLT64 sig;

    if ((b.exp == 0) && (b.sig == 0))
    {
        printf("div failed! a = %lf, b = %lf\n", a.flt64, b.flt64);
        c = b;
    }
    else if ((a.exp == 0) && (a.sig == 0))
    {
        c = a;
    }
    else
    {
        c.sign = (a.sign + b.sign) % 2;

        c.exp = a.exp - b.exp + (pow(2, (EXP_WITCH - 1)) - 1);
        sig = ((a.sig + pow(2, SIG_WITCH)) / (1.0 * pow(2, SIG_WITCH))) / ((b.sig + pow(2, SIG_WITCH)) / (1.0 * pow(2, SIG_WITCH)));

        while (sig < 1)
        {
            sig *= 2;
            c.exp -= 1;
        }
        sig -= 1;

        c.sig = 0;
        for (i = 0; i < SIG_WITCH; i++)
        {
            sig *= 2;
            if (sig >= 1)
            {
                sig -= 1;
                c.sig += pow(2, ((SIG_WITCH - 1) - i));
            }
        }
    }

    if ((c.exp == 0) && (c.sig == 0)) c.flt64 = 0;
    else if (c.exp >= (pow(2, (EXP_WITCH - 1)) - 1)) c.flt64 = pow(-1.0, c.sign) * pow(2, c.exp - (pow(2, (EXP_WITCH - 1)) - 1)) * (c.sig / pow(2, SIG_WITCH) + 1);
    else c.flt64 = pow(-1.0, c.sign) / pow(2, (pow(2, (EXP_WITCH - 1)) - 1) - c.exp) * (c.sig / pow(2, SIG_WITCH) + 1);
    
    return c;
}