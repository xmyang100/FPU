#include <stdio.h>
#include <stdbool.h>

//Chinese encode with UTF-8;中文编码UTF-8

int main()
{
    unsigned short data1 = 0x4440;
    unsigned short data2 = 0x4660;
    unsigned short datanew;

    unsigned int rmcache;           //尾数计算
    short expcache;                 //阶数计算
    bool sign;                      //符号计算
    unsigned short lastbit;         //计算过程中保留最后一位

    /*-------------------------step1:calculate------------------------------*/
    rmcache = (data1 & 0x03ff | 0x0400) * (data2 & 0x03ff | 0x0400);            //尾数相乘
    expcache = ((data1 >> 10) & 0x001f) + ((data2 >> 10) & 0x001f) - 15;        //阶数相加减15
    sign = (data1 >> 15) & (data2 >> 15);                                       //符号相与

    /*-------------------------step2:overflow and carry------------------------------*/
    if((rmcache & 0x00200000) == 0x00200000 )           //如果第22位是1，即溢出
    {
        lastbit = rmcache & 0x00000001;                 //最后一位记录下来
        rmcache = rmcache >> 1;                         //尾数右移一位
        expcache = expcache + 1;                        //阶数加一
    }
    else
        lastbit = 0;
        
    /*-----------------------step3:round to nearest even------------------------*/
    if( ((rmcache & 0x00000200) == 0x00000200) && (((rmcache & 0x00000400) == 0x00000400) || ((rmcache & 0x0000001ff) != 0x00000000) || lastbit) )  
    {
        rmcache = rmcache + 0x00000400;                 //判断入条件:(第九位 && (第十位 || 低八位有没有1))，入则第十位加一
    }

    /*-----------------------step4:overflow and carry again-------------------------------*/
    if(rmcache & 0x00200000 == 0x00200000)              //如果入了又溢出，即第22位是1
    {
        rmcache = rmcache >> 1;                         //尾数右移一位
        expcache = expcache + 1;                        //阶数加一
    }

    /*-----------------------step5:result----------------------------*/
    if(expcache > 31)                                   //阶数大于31，上溢出
        datanew =  (sign << 15) | 0x7fff    ;
    else if(expcache >= 0)                              //阶数正常，拼接符号位+阶数+尾数
        datanew = (sign << 15) | ((expcache & 0x001f) << 10) | ((rmcache & 0x000ffc00) >> 10);
    else                                                //阶数小于0，下溢出
        datanew = (sign << 15) | 0x0000;

    return 0;


}