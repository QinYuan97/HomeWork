.model small
.stack  
   DB 200H dup(0)
.data
a  DW 4291H,5996H,6993H,5356H,9992H,9093H,9994H,9395H,0098H,0A545H
      DW 0421H,0B832H,0001H,0002H,0003H,3486H,3449H,0F834H,4942H,0004H
      DW 0F835H,8354H,8355H,8352H,0004H,8000H,4356H,3255H,0010H,7FFFH
      DW 0E245H,5494H,3863H,3863H,3863H,5386H,0011H,0003H,6732H,7FFEH
      DW 5368H, 5555H,5555H,2859H,0C842H,0C842H,5212H,0F031H,8432H,1234H
       ;16位有符号数   
count equ $-a
.code
.startup
mov ax,count
sub ax,2
xor dx,dx
mov bx,offset a
call qsort
mov ah,4ch
int 21h

qsort proc near
cmp dx,ax
jge exit
call partion
push ax
push cx
sub cx,2
mov ax,cx
call qsort
pop cx
pop ax 
add cx,2
mov dx,cx 
call qsort 
exit:
ret
qsort endp

partion proc near
push ax
push dx
mov si,dx 
mov di,ax
mov dx,word ptr[bx][si]
mov cx,word ptr[bx][di]
call swap 
sub ax,si   
mov ES:[00000H],ax                 
mov di,si                 
mov ax,cx             
next:
mov dx,word ptr[bx][si]       
cmp dx,ax
jge sign
mov cx,word ptr[bx][di]
call swap 
add di,2                       
sign:
add si,2                     
sub ES:[00000H],2
cmp ES:[00000H],0
ja next      
mov cx,word ptr[bx][di]
mov dx,ax
call swap 
mov cx,di 
pop dx
pop ax 
ret 
partion endp

swap proc near
xchg dx,cx
mov word ptr[bx][si],dx 
mov word ptr[bx][di],cx 
ret
swap endp

END
