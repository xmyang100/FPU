# include <stdio.h>
#include <stdbool.h>

int main()
{
    unsigned int data_i = 0x00005555;
    unsigned short data_o;

    unsigned short first_one_index;
    unsigned short sign;
    unsigned short expcache;
    unsigned int rmcache;
    bool ifoverflow;
    bool ifzero;
    bool ifround;

    /*----------------------step1:pre_operation------------------------*/
    sign = data_i >> 31;
    if((data_i >= 65536) && (data_i <= 131071))
    {
        first_one_index = 16; 
        rmcache = (data_i & 0x0003ffc0) >> 6;
        ifround = (data_i & 0x00000020) && (data_i & 0x00000040 || data_i & 0x0000001f);
        ifoverflow = 0;
        ifzero = 0;
    }
    else if((data_i >= 32768) && (data_i <=65535))
    {
        first_one_index = 15;  
        rmcache = (data_i & 0x0001ffe0) >> 5;
        ifround = (data_i & 0x00000010) && (data_i & 0x00000020 || data_i & 0x0000000f);
        ifoverflow = 0;
        ifzero = 0;
    }
    else if((data_i >= 16384) && (data_i <= 32767))
    {
        first_one_index = 14; 
        rmcache = (data_i & 0x0000fff0) >> 4;
        ifround = (data_i & 0x00000008) && (data_i & 0x00000010 || data_i & 0x00000007);
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 8192)  && (data_i <= 16383))
    {
        first_one_index = 13; 
        rmcache = (data_i & 0x00007ff8) >> 3;
        ifround = (data_i & 0x00000004) && (data_i & 0x00000008 || data_i & 0x00000003);
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 4096)  && (data_i <= 8191))
    {
        first_one_index = 12;  
        rmcache = (data_i & 0x00003ffc) >> 2;
        ifround = (data_i & 0x00000002) && (data_i & 0x00000004 || data_i & 0x00000001);
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 2048)  && (data_i <= 4095))
    {
        first_one_index = 11;  
        rmcache = (data_i & 0x00001ffe) >> 1;
        ifround = (data_i & 0x00000001) && data_i & 0x00000002;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 1024)  && (data_i <= 2047))
    {
        first_one_index = 10;  
        rmcache = (data_i & 0x00000fff);
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 512)    &&  (data_i <= 1023))
    {
        first_one_index = 9; 
        rmcache = (data_i & 0x000007ff) << 1;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 256)    &&  (data_i <= 511))
    {
        first_one_index = 8; 
        rmcache = (data_i & 0x000003ff) << 2;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 128)    &&  (data_i <= 255))
    {
        first_one_index = 7;
        rmcache = (data_i & 0x000001ff) << 3;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 64)     &&  (data_i <= 127))
    {
        first_one_index = 6;  
        rmcache = (data_i & 0x000000ff) << 4;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 32)     &&  (data_i <= 63))
    {
        first_one_index = 5;  
        rmcache = (data_i & 0x0000007f) << 5;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 16)     &&  (data_i <= 31))
    {
        first_one_index = 4; 
        rmcache = (data_i & 0x0000003f) << 6;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 8)     &&  (data_i <= 15))
    {
        first_one_index = 3;  
        rmcache = (data_i & 0x0000001f) << 7;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 4)     &&  (data_i <= 7))
    {
        first_one_index = 2;   
        rmcache = (data_i & 0x0000000f) << 8;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if((data_i >= 2)     &&  (data_i <= 3))
    {
        first_one_index = 1;  
        rmcache = (data_i & 0x00000007) << 9;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if(data_i == 1)
    {
        first_one_index = 0;   
        rmcache = (data_i & 0x00000003) << 10;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 0;
    }
    else if(data_i == 0)
    {
        first_one_index = 0;   
        rmcache = (data_i & 0x00000001) << 11;
        ifround = 0;
        ifzero = 1;
        ifoverflow = 0;
    }
    else 
    {
        first_one_index = first_one_index; 
        rmcache = rmcache;
        ifround = 0;
        ifzero = 0;
        ifoverflow = 1;
    }
    


    /*--------------------------step2:round to nearest even-------------------------*/
    if(!(ifoverflow | ifzero))
        expcache = first_one_index + 15;
    
    if(ifround)
        rmcache = rmcache + 1;


    /*--------------------------step3:overflow and carry-----------------------*/
    if(rmcache & 0x00000800)
    {
        rmcache = rmcache >> 1;
        expcache = expcache + 1;
    }


    /*--------------------------step4:result-----------------------------*/
    data_o = sign << 15;
    if(ifoverflow && !ifzero)
        data_o = 0xffff;
    else if(!ifoverflow && ifzero)
        data_o = 0x0000;
    else
    {
        if(expcache < 31)
            data_o = (sign << 15) | ((expcache & 0x1f) << 10) | (rmcache & 0x3ff);
        else
            data_o = 0xffff;
    }

    return 0;
}