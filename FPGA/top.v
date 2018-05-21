`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:06:33 04/14/2017 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(
  input clk,
  input clr,
  input start,
  input day,
  input Wait,
  input display_d,   //切换数码管显示里程
  input display_w,   //切换数码管显示等待时间
  output reg[3:0]an,
  output reg[6:0]seg7,  
  output reg over_3_day , //白天里程超过3公里时一个led灯亮
  output reg over_10_day,
  output reg over_10_night,
  output reg dp
    );
	reg clk_1hz; 
	reg [15:0]distance; //里程
	reg [15:0]fee;     //费用
	reg [15:0]wait_time;
	reg [3:0]fee_z;    //费用的小数部分
   reg [31:0]count1;
   reg [31:0]count2;
   reg [3:0]Num;   
   reg clk_1khz;   //用于动态扫描数码管
   reg [1:0]cnt;
	reg[3:0] m_one,m_ten,m_hun,m_tho; //车费的个位、十位、百位、千位
	reg[15:0]comb1;
	reg[3:0]comb1_a,comb1_b,comb1_c,comb1_d;
	reg[3:0] d_one,d_ten,d_hun,d_tho;  //等待时间的个位、十位、百位、千位
	reg[15:0] comb2;
	reg[3:0]comb2_a,comb2_b,comb2_c,comb2_d;
   parameter S_price1=14,S_price2=17;

	
	//分频为1HZ
always@(posedge clk )
  begin
	if(count1=='d25000000) 
	  begin
	   clk_1hz=~clk_1hz;
	   count1<=0;
		end
	else count1<=count1+1;	
	end

	//里程部分
always@(posedge clk_1hz or posedge clr)
  begin
   if(clr)
	 distance<=0;
	else if(!start)
	 distance<=0;
	else if(!Wait)
	   begin
		 if(distance[3:0]=='d9&&distance[7:4]=='d9&&distance[11:8]=='d9)
		  begin
		   distance[3:0]<=0;
			distance[7:4]<=0;
			distance[11:8]<=0;
			distance[15:12]<=distance[15:12]+1;
			end
		else if(distance[3:0]=='d9&&distance[7:4]=='d9)
        begin
         distance[3:0]<=0;
         distance[7:4]<=0;
         distance[11:8]<=distance[11:8]+1;
         end
		else if(distance[3:0]=='d9)
        begin
         distance[3:0]<=0;
         distance[7:4]<=distance[7:4]+1;
         end
		else distance[3:0]<=distance[3:0]+1;	
	end
  	 end
	 
//	计算等待时间
  always@(posedge clk_1hz or posedge clr)
    begin
	  if(clr)
	    wait_time<=0;
	  else if(!start)
       wait_time<=0;
     else if(Wait)
       wait_time<=wait_time+1;	
   end		 
	
//计算费用部分	
	always@(posedge clk or posedge clr)
  begin
   if  (clr)
	  fee<=0;
	else if(!start) fee<=0;
	else  
	 begin
	  if(day)
	   begin
		 if((distance[3:0]+10*distance[7:4]+100*distance[11:8]+1000*distance[15:12])<=3)
		  begin
		  fee<=S_price1+wait_time[15:1];
		  over_3_day<=0;
		  over_10_day<=0;
		  over_10_night<=0;
		  end
		 else if((distance[3:0]+10*distance[7:4]+100*distance[11:8]+1000*distance[15:12])<=10) 
        begin
		  fee<=S_price1+3*((distance[3:0]+10*distance[7:4]+100*distance[11:8]+1000*distance[15:12])-3)+wait_time[15:1];
		  over_3_day<=1;
		  over_10_day<=0;
		  over_10_night<=0;
		  end
       else if((distance[3:0]+10*distance[7:4]+100*distance[11:8]+1000*distance[15:12])>10)
        begin
		  fee<=S_price1+4*((distance[3:0]+10*distance[7:4]+100*distance[11:8]+1000*distance[15:12])-10)+21+wait_time[15:1];		  over_10_day<=1;
		  over_3_day<=0;
		  over_10_night<=0;
		  end
       end
     if(!day)
      begin
       if((distance[3:0]+10*distance[7:4]+100*distance[11:8]+1000*distance[15:12])<=10)
        begin
		  fee<=S_price2+4*(distance[3:0]+10*distance[7:4]+100*distance[11:8]+1000*distance[15:12])+wait_time[15:1];
		  over_3_day<=0;
		  over_10_day<=0;
		  over_10_night<=0;
		  end
		else if((distance[3:0]+10*distance[7:4]+100*distance[11:8]+1000*distance[15:12])>10)
		  begin
        fee<=S_price2+5*((distance[3:0]+10*distance[7:4]+100*distance[11:8]+1000*distance[15:12])-10)+40+wait_time[15:1];
		  over_10_night<=1;
		  over_3_day<=0;
		  over_10_day<=0;
		  end
       end
      end
     end
 
 //处理费用的小数部分
  always@(posedge clk)
   begin
	 if(wait_time[0]==1)
	   fee_z<=4'b0101;
	 else fee_z<=4'b0000;	
   end
 
 
 //将费用转换为BCD码
always@(posedge clk)
   begin 
	if(comb1<fee)
     begin
	 if (comb1_a=='d9&&comb1_b=='d9&&comb1_c=='d9)
		begin
	      comb1_a<='b0000;
	      comb1_b<='b0000;
          comb1_c<='b0000;
          comb1_d<=comb1_d+1;
          comb1<=comb1+1;
        end 
     else if(comb1_a=='d9&&comb1_b=='d9)
        begin
          comb1_a<='b0000;
          comb1_b<='b0000;
          comb1_c<=comb1_c+1;
          comb1<=comb1+1;
        end 
     else if(comb1_a=='d9) 
        begin
	      comb1_a<='b0000;
	      comb1_b<=comb1_b+1;
	      comb1<=comb1+1;
	    end 
	 else
	  begin
		comb1_a<=comb1_a+1;
		comb1<=comb1+1;
      end
	 end	
	else if (comb1==fee)
		begin
	      m_one<=comb1_a;
	      m_ten<=comb1_b;
	      m_hun<=comb1_c;
	      m_tho<=comb1_d;
	    end
	else if (comb1>fee)
	    begin
			comb1_a<='b0000;
			comb1_b<='b0000;
            comb1_c<='b0000;
            comb1_d<='b0000;
            comb1<='d0;
        end
 end
 
 //将等待时间转换为BCD码
  always@(posedge clk)
   begin
	if(comb2<wait_time)
     begin
	  if (comb2_a=='d9&&comb2_b=='d9&&comb2_c=='d9)
		begin
	      comb2_a<='b0000;
	      comb2_b<='b0000;
          comb2_c<='b0000;
          comb2_d<=comb2_d+1;
          comb2<=comb2+1;
        end 
     else if(comb2_a=='d9&&comb2_b=='d9)
        begin
          comb2_a<='b0000;
          comb2_b<='b0000;
          comb2_c<=comb2_c+1;
          comb2<=comb2+1;
        end 
     else if(comb2_a=='d9) 
        begin
	      comb2_a<='b0000;
	      comb2_b<=comb2_b+1;
	      comb2<=comb2+1;
	    end 
	 else
	  begin
		comb2_a<=comb2_a+1;
		comb2<=comb2+1;
      end
	 end	
	else if (comb2==wait_time)
		begin
	      d_one<=comb2_a;
	      d_ten<=comb2_b;
	      d_hun<=comb2_c;
	      d_tho<=comb2_d;
	    end
	else if (comb2>wait_time)
	    begin
			comb2_a<='b0000;
			comb2_b<='b0000;
            comb2_c<='b0000;
            comb2_d<='b0000;
            comb2<='d0;
        end
 end
	
 
	//分频为1KHZ用于扫描数码管
 always@(posedge clk)
    begin
		if(count2=='d25000)
			begin clk_1khz<=~clk_1khz;count2<='d0;end
		else
		 begin count2<=count2+1;end 
      end
 
always@(posedge clk_1khz)
   begin 
	 cnt=cnt+1;
	 end

always@(cnt)
 begin
  if(display_d==1&&display_w==0)
   begin
	case(cnt)
	 'b00:begin Num<=distance[3:0];dp<=1;an<='b1110;end
	 'b01:begin Num<=distance[7:4];dp<=1;an<='b1101;end
	 'b10:begin Num<=distance[11:8];dp<=1;an<='b1011;end
	 'b11:begin Num<=distance[15:12];dp<=1;an<='b0111;end
	 default:begin Num<=4'bx;dp<=1;an<=4'bx;end
    endcase
  end
 else if(display_d==0&&display_w==1)
   begin 
	case(cnt)
	 'b00:begin Num<=d_one;dp<=1;an<='b1110;end
	 'b01:begin Num<=d_ten;dp<=1;an<='b1101;end
	 'b10:begin Num<=d_hun;dp<=1;an<='b1011;end
	 'b11:begin Num<=d_tho;dp<=1;an<='b0111;end
	 default:begin Num<=4'bx;dp<=1;an<=4'bx;end
  endcase
  end
  
 else 
    begin
    case(cnt)
      'b00:begin Num<=fee_z;dp<=1;an<='b1110;end
	   'b01:begin Num<=m_one;dp<=0;an<='b1101;end
	   'b10:begin Num<=m_ten;dp<=1;an<='b1011;end
	   'b11:begin Num<=m_hun;dp<=1;an<='b0111;end
	 default:begin Num<=4'bx;dp<=1;an<=4'bx;end	 
    endcase
	 end
  end
  

always@(Num)
 begin
 case(Num)
 0:seg7=7'b0000001;
 1:seg7=7'b1001111;
 2:seg7=7'b0010010;
 3:seg7=7'b0000110;
 4:seg7=7'b1001100;
 5:seg7=7'b0100100;
 6:seg7=7'b0100000;
 7:seg7=7'b0001111;
 8:seg7=7'b0000000;
 9:seg7=7'b0000100;
 default:seg7=7'b1111111;
 endcase
 end

endmodule

