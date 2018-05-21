%option noyywrap
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%}

symbol [-+*/=~!%^&<>/t( ]
b_number [0-1]+
h_number [0-9a-fA-F]+
o_number [0-7]+
%%

"#" {  char c;                                       //将单行注释中的大写字母转化为小写
       int flag=0;
       putchar('#');
       do{
          c=input();
          if(c>='A'&&c<='Z') {putchar(tolower(c));}
          else if(c=='\n') {putchar(c);flag=1;}      //遇到换行符，说明单行注释结束，退出循环
          else putchar(c);}
       while(!flag);
    }


"\"\"\"" {  char c;				    //将多行注释中的大写字母转化为小写
	int flag=0;
	for(int i=1;i<=3;i++) putchar('\"');
	do{
	   c=input();
	   if(c>='A'&&c<='Z') {putchar(tolower(c));}
	   else if(c=='\"')
	     {putchar(c);c=input();
	      if(c=='\"')
	        {putchar(c);c=input();
	          if(c=='\"')
		    {putchar(c);flag=1;}      //再次遇到三引号，多行注释结束，退出循环
	          else putchar(c);}
	      else putchar(c);}
	   else putchar(c);
	 } while(!flag);
     }



"'''" {  char c;                                      //将多行注释中的大写字母转化为小写
	int flag=0;
	for(int i=1;i<=3;i++) putchar('\'');
	do{
	   c=input();
	   if(c>='A'&&c<='Z') {putchar(tolower(c));}
	   else if(c=='\'')
	     {putchar(c);c=input();
	      if(c=='\'')
	        {putchar(c);c=input();
	          if(c=='\'')
		    {putchar(c);flag=1;}
	          else putchar(c);}
	      else putchar(c);}
	   else putchar(c);
	 } while(!flag);
     }



{symbol}"0b"{b_number}|{symbol}"0B"{b_number} {         
	int n=yyleng,a=0,j=0,num=0;                         //将代码中的二进制数转化为十进制
	int c[100];
	putchar(yytext[0]);
	for(int i=3;i<n;i++)
	  {num=num*2+(yytext[i]-'0');}      //将二进制字符串转化为十进制整数
	
	for(j=0;num>0;j++)                  //将该整数转化为字符串并输出
	  { c[j]=num%10; 
	    num=num/10;}
        for(int i=j-1;i>=0;i--)             
	  putchar(c[i]+'0');
	}



{symbol}"0x"{h_number}|{symbol}"0X"{h_number} {              //将代码中的十六进制数转化为十进制
	int n=yyleng,a=0,j=0,temp=0,num=0;
	int c[100];
	putchar(yytext[0]);
	for(int i=3;i<n;i++)
	  {if(yytext[i]>='0'&&yytext[i]<='9') temp=yytext[i]-'0';
	   else if(yytext[i]>='a'&&yytext[i]<='z') temp=10+(yytext[i]-'a');
	   else temp=10+(yytext[i]-'A');
           num=num*16+temp;
             }
   	for(j=0;num>0;j++)
	  { c[j]=num%10;
	    num=num/10;}
        for(int i=j-1;i>=0;i--)
	    putchar(c[i]+'0');  
	}


{symbol}"0o"{o_number}|{symbol}"0O"{o_number} {                //将代码中的八进制数转化为十进制
	int n=yyleng,a=0,j=0,num=0;
	int c[100];
	putchar(yytext[0]);
	for(int i=3;i<n;i++)
	  {num=num*8+(yytext[i]-'0');}
   	for(j=0;num>0;j++)
	  { c[j]=num%10;
	    num=num/10;}
        for(int i=j-1;i>=0;i--)
	    putchar(c[i]+'0');  
	
	}
{symbol}"0"{o_number} {
	int n=yyleng,a=0,j=0,num=0;
	int c[100];
	putchar(yytext[0]);
	for(int i=2;i<n;i++)
	  {num=num*8+(yytext[i]-'0');}
   	for(j=0;num>0;j++)
	  { c[j]=num%10;
	    num=num/10;}
        for(int i=j-1;i>=0;i--)
	    putchar(c[i]+'0');  
	
	}

"'"  {char c,temp;                                  // 将字符串中的字符按默认方式输出
       int flag=0;
       putchar('\'');
       do{
          c=input();
          if(c=='\''&&temp!='\\') {putchar(c);flag=1;}  // 遇到'且前一个字符不是转义字符，结束
          else putchar(c);
	  temp=c;}
       while(!flag);
    }

"\""  {char c,temp;                                  // 将字符串中的字符按默认方式输出
       int flag=0;
       putchar('\"');
       do{
          c=input();
          if(c=='\"'&&temp!='\\') {putchar(c);flag=1;}  // 遇到"且前一个字符不是转义字符，结束
          else putchar(c);
	  temp=c;}
       while(!flag);
    }

%%

void main(void)
{
    yylex();
}
