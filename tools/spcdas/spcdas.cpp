#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
typedef unsigned char  byte;
typedef unsigned short word;
typedef unsigned long  ulong;

FILE *fp, *wr;
struct {
  word pc, stop, load;
  bool rel, addr, hex;
  byte mem[65536];
}spc = { 0x0000, 0x0000, 0x0000, true, true, true };

//print one opcode using formatting passed by disas_op
void disas(byte o, char *s, byte a = 0, byte b = 0, byte c = 0, byte d = 0) {
char ws[4096], t[16];
int i, x, pos = 0, z;
ulong v;
  if(spc.addr == true) {
    sprintf(ws, "%0.4x: ", spc.pc);
  } else {
    sprintf(ws, "");
  }
  if(spc.hex == true) {
    for(i=0;i<o;i++) {
      sprintf(t, "%0.2x ", spc.mem[spc.pc+i]);
      strcat(ws, t);
    }
    for(;i<3;i++) {
      strcat(ws, "   ");
    }
    strcat(ws, " ");
  }
  z=strlen(ws);
  for(i=0;i<strlen(s);i++) {
    if(s[i]=='*') {
      x=s[++i];
      if(x=='b') {
        if     (pos == 0)v=spc.mem[spc.pc+a];
        else if(pos == 1)v=spc.mem[spc.pc+b];
        else if(pos == 2)v=spc.mem[spc.pc+c];
        else if(pos == 3)v=spc.mem[spc.pc+d];
        pos++;
        sprintf(t, "%0.2x", v&0xff);
      } else if(x=='w') {
        if     (pos == 0)v=spc.mem[spc.pc+a]|(spc.mem[spc.pc+a+1]<<8);
        else if(pos == 1)v=spc.mem[spc.pc+b]|(spc.mem[spc.pc+b+1]<<8);
        else if(pos == 2)v=spc.mem[spc.pc+c]|(spc.mem[spc.pc+c+1]<<8);
        else if(pos == 3)v=spc.mem[spc.pc+d]|(spc.mem[spc.pc+d+1]<<8);
        pos++;
        sprintf(t, "%0.4x", v&0xffff);
      } else if(x=='m') {
        if     (pos == 0)v=spc.mem[spc.pc+a]|(spc.mem[spc.pc+a+1]<<8);
        else if(pos == 1)v=spc.mem[spc.pc+b]|(spc.mem[spc.pc+b+1]<<8);
        else if(pos == 2)v=spc.mem[spc.pc+c]|(spc.mem[spc.pc+c+1]<<8);
        else if(pos == 3)v=spc.mem[spc.pc+d]|(spc.mem[spc.pc+d+1]<<8);
        pos++;
        sprintf(t, "%0.4x,%d", (v>>3)&0x1fff, v&7);
      } else if(x=='r') {
        if     (pos == 0)v=spc.mem[spc.pc+a];
        else if(pos == 1)v=spc.mem[spc.pc+b];
        else if(pos == 2)v=spc.mem[spc.pc+c];
        else if(pos == 3)v=spc.mem[spc.pc+d];
        pos++;
        if(spc.rel == true) {
          v=(spc.pc+2)+(signed char)v;
          sprintf(t, "%0.4x", v&0xffff);
        } else {
          sprintf(t, "%0.2x", v&0xff);
        }
      }
      ws[z]=0;
      strcat(ws, t);
      z+=strlen(t);
    } else {
      ws[z++]=s[i];
    }
  }
  ws[z]=0;
  fprintf(wr, "%s\r\n", ws);

  spc.pc+=o;
}

//*b=byte, *w=word, *m=word,bit, *r=relative
void disas_op(void) {
byte op = spc.mem[spc.pc];
  switch(op) {
  case 0x00: disas(1, "nop");                     break;
  case 0x01: disas(1, "tcall 0");                 break;
  case 0x02: disas(2, "set0  $*b", 1);            break;
  case 0x03: disas(3, "bbs0  $*b,$*r", 1, 2);     break;
  case 0x04: disas(2, "or    a,$*b", 1);          break;
  case 0x05: disas(3, "or    a,$*w", 1);          break;
  case 0x06: disas(1, "or    a,(x)");             break;
  case 0x07: disas(2, "or    a,($*b+x)", 1);      break;
  case 0x08: disas(2, "or    a,#$*b", 1);         break;
  case 0x09: disas(3, "or    ($*b),($*b)", 2, 1); break;
  case 0x0a: disas(3, "or1   c,$*m", 1);          break;
  case 0x0b: disas(2, "asl   $*b", 1);            break;
  case 0x0c: disas(3, "asl   $*w", 1);            break;
  case 0x0d: disas(1, "push  psw");               break;
  case 0x0e: disas(3, "tset1 $*w", 1);            break;
  case 0x0f: disas(1, "brk");                     break;
  case 0x10: disas(2, "bpl   $*r", 1);            break;
  case 0x11: disas(1, "tcall 1");                 break;
  case 0x12: disas(2, "clr0  $*b", 1);            break;
  case 0x13: disas(3, "bbc0  $*b,$*r", 1, 2);     break;
  case 0x14: disas(2, "or    a,$*b+x", 1);        break;
  case 0x15: disas(3, "or    a,$*w+x", 1);        break;
  case 0x16: disas(3, "or    a,$*w+y", 1);        break;
  case 0x17: disas(2, "or    a,($*b)+y", 1);      break;
  case 0x18: disas(3, "or    $*b,#$*b", 2, 1);    break;
  case 0x19: disas(1, "or    (x),(y)");           break;
  case 0x1a: disas(2, "decw  $*b", 1);            break;
  case 0x1b: disas(2, "asl   $*b+x", 1);          break;
  case 0x1c: disas(1, "asl   a");                 break;
  case 0x1d: disas(1, "dec   x");                 break;
  case 0x1e: disas(3, "cmp   x,$*w", 1);          break;
  case 0x1f: disas(3, "jmp   ($*w+x)", 1);        break;
  case 0x20: disas(1, "clrp");                    break;
  case 0x21: disas(1, "tcall 2");                 break;
  case 0x22: disas(2, "set1  $*b", 1);            break;
  case 0x23: disas(3, "bbs1  $*b,$*r", 1, 2);     break;
  case 0x24: disas(2, "and   a,$*b", 1);          break;
  case 0x25: disas(3, "and   a,$*w", 1);          break;
  case 0x26: disas(1, "and   a,(x)");             break;
  case 0x27: disas(2, "and   a,($*b+x)", 1);      break;
  case 0x28: disas(2, "and   a,#$*b", 1);         break;
  case 0x29: disas(3, "and   ($*b),($*b)", 2, 1); break;
  case 0x2a: disas(3, "or1   c,!($*m)", 1);       break;
  case 0x2b: disas(2, "rol   $*b", 1);            break;
  case 0x2c: disas(3, "rol   $*w", 1);            break;
  case 0x2d: disas(1, "push  a");                 break;
  case 0x2e: disas(3, "cbne  $*b,$*r", 1, 2);     break;
  case 0x2f: disas(2, "bra   $*r", 1);            break;
  case 0x30: disas(2, "bmi   $*r", 1);            break;
  case 0x31: disas(1, "tcall 3");                 break;
  case 0x32: disas(2, "clr1  $*b", 1);            break;
  case 0x33: disas(3, "bbc1  $*b,$*r", 1, 2);     break;
  case 0x34: disas(2, "and   a,$*b+x", 1);        break;
  case 0x35: disas(3, "and   a,$*w+x", 1);        break;
  case 0x36: disas(3, "and   a,$*w+y", 1);        break;
  case 0x37: disas(2, "and   a,($*b)+y", 1);      break;
  case 0x38: disas(3, "and   $*b,#$*b", 2, 1);    break;
  case 0x39: disas(1, "and   (x),(y)");           break;
  case 0x3a: disas(2, "incw  $*b", 1);            break;
  case 0x3b: disas(2, "rol   $*b+x", 1);          break;
  case 0x3c: disas(1, "rol   a");                 break;
  case 0x3d: disas(1, "inc   x");                 break;
  case 0x3e: disas(2, "cmp   x,$*b", 1);          break;
  case 0x3f: disas(3, "call  $*w", 1);            break;
  case 0x40: disas(1, "setp");                    break;
  case 0x41: disas(1, "tcall 4");                 break;
  case 0x42: disas(2, "set2  $*b", 1);            break;
  case 0x43: disas(3, "bbs2  $*b,$*r", 1, 2);     break;
  case 0x44: disas(2, "eor   a,$*b", 1);          break;
  case 0x45: disas(3, "eor   a,$*w", 1);          break;
  case 0x46: disas(1, "eor   a,(x)");             break;
  case 0x47: disas(2, "eor   a,($*b+x)", 1);      break;
  case 0x48: disas(2, "eor   a,#$*b", 1);         break;
  case 0x49: disas(3, "eor   ($*b),($*b)", 2, 1); break;
  case 0x4a: disas(3, "and1  c,$*m", 1);          break;
  case 0x4b: disas(2, "lsr   $*b", 1);            break;
  case 0x4c: disas(3, "lsr   $*w", 1);            break;
  case 0x4d: disas(1, "push  x");                 break;
  case 0x4e: disas(3, "tclr1 $*w", 1);            break;
  case 0x4f: disas(2, "pcall $*b", 1);            break;
  case 0x50: disas(2, "bvc   $*r", 1);            break;
  case 0x51: disas(1, "tcall 5");                 break;
  case 0x52: disas(2, "clr2  $*b", 1);            break;
  case 0x53: disas(3, "bbc2  $*b,$*r", 1, 2);     break;
  case 0x54: disas(2, "eor   a,$*b+x", 1);        break;
  case 0x55: disas(3, "eor   a,$*w+x", 1);        break;
  case 0x56: disas(3, "eor   a,$*w+y", 1);        break;
  case 0x57: disas(2, "eor   a,($*b)+y", 1);      break;
  case 0x58: disas(3, "eor   $*b,#$*b", 2, 1);    break;
  case 0x59: disas(1, "eor   (x),(y)");           break;
  case 0x5a: disas(2, "cmpw  ya,$*b", 1);         break;
  case 0x5b: disas(2, "lsr   $*b+x", 1);          break;
  case 0x5c: disas(1, "lsr   a");                 break;
  case 0x5d: disas(1, "mov   x,a");               break;
  case 0x5e: disas(3, "cmp   y,$*w", 1);          break;
  case 0x5f: disas(3, "jmp   $*w", 1);            break;
  case 0x60: disas(1, "clrc");                    break;
  case 0x61: disas(1, "tcall 6");                 break;
  case 0x62: disas(2, "set3  $*b", 1);            break;
  case 0x63: disas(3, "bbs3  $*b,$*r", 1, 2);     break;
  case 0x64: disas(2, "cmp   a,$*b", 1);          break;
  case 0x65: disas(3, "cmp   a,$*w", 1);          break;
  case 0x66: disas(1, "cmp   a,(x)");             break;
  case 0x67: disas(2, "cmp   a,($*b+x)", 1);      break;
  case 0x68: disas(2, "cmp   a,#$*b", 1);         break;
  case 0x69: disas(3, "cmp   ($*b),($*b)", 2, 1); break;
  case 0x6a: disas(3, "and1  c,!($*m)", 1);       break;
  case 0x6b: disas(2, "ror   $*b", 1);            break;
  case 0x6c: disas(3, "ror   $*w", 1);            break;
  case 0x6d: disas(1, "push  y");                 break;
  case 0x6e: disas(3, "dbnz  $*b,$*r", 1, 2);     break;
  case 0x6f: disas(1, "ret");                     break;
  case 0x70: disas(2, "bvs   $*r", 1);            break;
  case 0x71: disas(1, "tcall 7");                 break;
  case 0x72: disas(2, "clr3  $*b", 1);            break;
  case 0x73: disas(3, "bbc3  $*b,$*r", 1, 2);     break;
  case 0x74: disas(2, "cmp   a,$*b+x", 1);        break;
  case 0x75: disas(3, "cmp   a,$*w+x", 1);        break;
  case 0x76: disas(3, "cmp   a,$*w+y", 1);        break;
  case 0x77: disas(2, "cmp   a,($*b)+y", 1);      break;
  case 0x78: disas(3, "cmp   $*b,#$*b", 2, 1);    break;
  case 0x79: disas(1, "cmp   (x),(y)");           break;
  case 0x7a: disas(2, "addw  ya,$*b", 1);         break;
  case 0x7b: disas(2, "ror   $*b+x", 1);          break;
  case 0x7c: disas(1, "ror   a");                 break;
  case 0x7d: disas(1, "mov   a,x");               break;
  case 0x7e: disas(2, "cmp   y,$*b", 1);          break;
  case 0x7f: disas(1, "reti");                    break;
  case 0x80: disas(1, "setc");                    break;
  case 0x81: disas(1, "tcall 8");                 break;
  case 0x82: disas(2, "set4  $*b", 1);            break;
  case 0x83: disas(3, "bbs4  $*b,$*r", 1, 2);     break;
  case 0x84: disas(2, "adc   a,$*b", 1);          break;
  case 0x85: disas(3, "adc   a,$*w", 1);          break;
  case 0x86: disas(1, "adc   a,(x)");             break;
  case 0x87: disas(2, "adc   a,($*b+x)", 1);      break;
  case 0x88: disas(2, "adc   a,#$*b", 1);         break;
  case 0x89: disas(3, "adc   ($*b),($*b)", 2, 1); break;
  case 0x8a: disas(3, "eor1  c,$*m", 1);          break;
  case 0x8b: disas(2, "dec   $*b", 1);            break;
  case 0x8c: disas(3, "dec   $*w", 1);            break;
  case 0x8d: disas(2, "mov   y,#$*b", 1);         break;
  case 0x8e: disas(1, "pop   psw");               break;
  case 0x8f: disas(3, "mov   $*b,#$*b", 2, 1);    break;
  case 0x90: disas(2, "bcc   $*r", 1);            break;
  case 0x91: disas(1, "tcall 9");                 break;
  case 0x92: disas(2, "clr4  $*b", 1);            break;
  case 0x93: disas(3, "bbc4  $*b,$*r", 1, 2);     break;
  case 0x94: disas(2, "adc   a,$*b+x", 1);        break;
  case 0x95: disas(3, "adc   a,$*w+x", 1);        break;
  case 0x96: disas(3, "adc   a,$*w+y", 1);        break;
  case 0x97: disas(2, "adc   a,($*b)+y", 1);      break;
  case 0x98: disas(3, "adc   $*b,#$*b", 2, 1);    break;
  case 0x99: disas(1, "adc   (x),(y)");           break;
  case 0x9a: disas(2, "subw  ya,$*b", 1);         break;
  case 0x9b: disas(2, "dec   $*b+x", 1);          break;
  case 0x9c: disas(1, "dec   a");                 break;
  case 0x9d: disas(1, "mov   x,sp");              break;
  case 0x9e: disas(1, "div   ya,x");              break;
  case 0x9f: disas(1, "xcn   a");                 break;
  case 0xa0: disas(1, "ei");                      break;
  case 0xa1: disas(1, "tcall 10");                break;
  case 0xa2: disas(2, "set5  $*b", 1);            break;
  case 0xa3: disas(3, "bbs5  $*b,$*r", 1, 2);     break;
  case 0xa4: disas(2, "sbc   a,$*b", 1);          break;
  case 0xa5: disas(3, "sbc   a,$*w", 1);          break;
  case 0xa6: disas(1, "sbc   a,(x)");             break;
  case 0xa7: disas(2, "sbc   a,($*b+x)", 1);      break;
  case 0xa8: disas(2, "sbc   a,#$*b", 1);         break;
  case 0xa9: disas(3, "sbc   ($*b),($*b)", 2, 1); break;
  case 0xaa: disas(3, "mov1  c,$*m", 1);          break;
  case 0xab: disas(2, "inc   $*b", 1);            break;
  case 0xac: disas(3, "inc   $*w", 1);            break;
  case 0xad: disas(2, "cmp   y,#$*b", 1);         break;
  case 0xae: disas(1, "pop   a");                 break;
  case 0xaf: disas(1, "mov   (x)+,a");            break;
  case 0xb0: disas(2, "bcs   $*r", 1);            break;
  case 0xb1: disas(1, "tcall 11");                break;
  case 0xb2: disas(2, "clr5  $*b", 1);            break;
  case 0xb3: disas(3, "bbc5  $*b,$*r", 1, 2);     break;
  case 0xb4: disas(2, "sbc   a,$*b+x", 1);        break;
  case 0xb5: disas(3, "sbc   a,$*w+x", 1);        break;
  case 0xb6: disas(3, "sbc   a,$*w+y", 1);        break;
  case 0xb7: disas(2, "sbc   a,($*b)+y", 1);      break;
  case 0xb8: disas(3, "sbc   $*b,#$*b", 2, 1);    break;
  case 0xb9: disas(1, "sbc   (x),(y)");           break;
  case 0xba: disas(2, "movw  ya,$*b", 1);         break;
  case 0xbb: disas(2, "inc   $*b+x", 1);          break;
  case 0xbc: disas(1, "inc   a");                 break;
  case 0xbd: disas(1, "mov   sp,x");              break;
  case 0xbe: disas(1, "das   a");                 break;
  case 0xbf: disas(1, "mov   a,(x)+");            break;
  case 0xc0: disas(1, "di");                      break;
  case 0xc1: disas(1, "tcall 12");                break;
  case 0xc2: disas(2, "set6  $*b", 1);            break;
  case 0xc3: disas(3, "bbs6  $*b,$*r", 1, 2);     break;
  case 0xc4: disas(2, "mov   $*b,a", 1);          break;
  case 0xc5: disas(3, "mov   $*w,a", 1);          break;
  case 0xc6: disas(1, "mov   (x),a");             break;
  case 0xc7: disas(2, "mov   ($*b+x),a", 1);      break;
  case 0xc8: disas(2, "cmp   x,#$*b", 1);         break;
  case 0xc9: disas(3, "mov   $*w,x", 1);          break;
  case 0xca: disas(3, "mov1  $*m,c", 1);          break;
  case 0xcb: disas(2, "mov   $*b,y", 1);          break;
  case 0xcc: disas(3, "mov   $*w,y", 1);          break;
  case 0xcd: disas(2, "mov   x,#$*b", 1);         break;
  case 0xce: disas(1, "pop   x");                 break;
  case 0xcf: disas(1, "mul   ya");                break;
  case 0xd0: disas(2, "bne   $*r", 1);            break;
  case 0xd1: disas(1, "tcall 13");                break;
  case 0xd2: disas(2, "clr6  $*b", 1);            break;
  case 0xd3: disas(3, "bbc6  $*b,$*r", 1, 2);     break;
  case 0xd4: disas(2, "mov   $*b+x,a", 1);        break;
  case 0xd5: disas(3, "mov   $*w+x,a", 1);        break;
  case 0xd6: disas(3, "mov   $*w+y,a", 1);        break;
  case 0xd7: disas(2, "mov   ($*b)+y,a", 1);      break;
  case 0xd8: disas(2, "mov   $*b,x", 1);          break;
  case 0xd9: disas(2, "mov   $*b+y,x", 1);        break;
  case 0xda: disas(2, "movw  $*b,ya", 1);         break;
  case 0xdb: disas(2, "mov   $*b+x,y", 1);        break;
  case 0xdc: disas(1, "dec   y");                 break;
  case 0xdd: disas(1, "mov   a,y");               break;
  case 0xde: disas(3, "cbne  $*b+x,$*r", 1, 2);   break;
  case 0xdf: disas(1, "daa   a");                 break;
  case 0xe0: disas(1, "clrv");                    break;
  case 0xe1: disas(1, "tcall 14");                break;
  case 0xe2: disas(2, "set7  $*b", 1);            break;
  case 0xe3: disas(3, "bbs7  $*b,$*r", 1, 2);     break;
  case 0xe4: disas(2, "mov   a,$*b", 1);          break;
  case 0xe5: disas(3, "mov   a,$*w", 1);          break;
  case 0xe6: disas(1, "mov   a,(x)");             break;
  case 0xe7: disas(2, "mov   a,($*b+x)", 1);      break;
  case 0xe8: disas(2, "mov   a,#$*b", 1);         break;
  case 0xe9: disas(3, "mov   x,$*w", 1);          break;
  case 0xea: disas(3, "not1  $*m", 1);            break;
  case 0xeb: disas(2, "mov   y,$*b", 1);          break;
  case 0xec: disas(3, "mov   y,$*w", 1);          break;
  case 0xed: disas(1, "notc");                    break;
  case 0xee: disas(1, "pop   y");                 break;
  case 0xef: disas(1, "sleep");                   break;
  case 0xf0: disas(2, "beq   $*r", 1);            break;
  case 0xf1: disas(1, "tcall 15");                break;
  case 0xf2: disas(2, "clr7  $*b", 1);            break;
  case 0xf3: disas(3, "bbc7  $*b,$*r", 1, 2);     break;
  case 0xf4: disas(2, "mov   a,$*b+x", 1);        break;
  case 0xf5: disas(3, "mov   a,$*w+x", 1);        break;
  case 0xf6: disas(3, "mov   a,$*w+y", 1);        break;
  case 0xf7: disas(2, "mov   a,($*b)+y", 1);      break;
  case 0xf8: disas(2, "mov   x,$*b", 1);          break;
  case 0xf9: disas(2, "mov   x,$*b+y", 1);        break;
  case 0xfa: disas(3, "mov   ($*b),($*b)", 2, 1); break;
  case 0xfb: disas(2, "mov   y,$*b+x", 1);        break;
  case 0xfc: disas(1, "inc   y");                 break;
  case 0xfd: disas(1, "mov   y,a");               break;
  case 0xfe: disas(2, "dbnz  y,$*r", 1);          break;
  case 0xff: disas(1, "stop");                    break;
  }
}

//quick str to hex function
word atoh(char *s) {
int i, sl=strlen(s);
byte x;
word r = 0;
  for(i=0;i<sl;i++) {
    x=s[(sl-1)-i];
    if(x>='0'&&x<='9')x-='0';
    else if(x>='A'&&x<='F')x-='A'-0x0a;
    else if(x>='a'&&x<='f')x-='a'-0x0a;
    else {
      printf("error: invalid hex code [%s] - defaulting to 0000\n", s);
      return 0;
    }
    r|=x<<(i<<2);
  }
  return r;
}

int main(int argc,char *argv[]) {
int i, fsize, eof = 1;
//not enough arguments? print help message
  if(argc < 3) {
    printf(
      "spcdas v0.01 ~byuu\n"
      "usage: spcdas input.bin [-options] output.s\n"
      "\n"
      "options: [x is a word in hex - ex: c2ff]\n"
      "  -load x          : load file into spc ram position x         [default: 0000]\n"
      "  -pc   x          : set starting offset for disassembly to x  [default: 0000]\n"
      "  -stop [x  | eof] : stop disassembly at x or end of file      [default:  eof]\n"
      "  -rel  [on | off] : enable / disable relative branch resolves [default:   on]\n"
      "  -addr [on | off] : enable / disable addresses                [default:   on]\n"
      "  -hex  [on | off] : enable / disable opcode hex display       [default:   on]\n"
      "\n"
      "press any key...\n"
    );
    getch();
    return 0;
  }

//parse arguments
  if(argc != 3) {
    for(i=2;i<argc;i+=2) {
           if(!strcmp(argv[i], "-load")) { spc.load = atoh(argv[i+1]); }
      else if(!strcmp(argv[i], "-pc"  )) { spc.pc   = atoh(argv[i+1]); }
      else if(!strcmp(argv[i], "-stop")) {
        if(!strcmp(argv[i+1], "eof")) {
          eof = 1;
        } else {
          eof = 0;
          spc.stop = atoh(argv[i+1]);
        }
      }
      else if(!strcmp(argv[i], "-rel" )) {
             if(!strcmp(argv[i+1], "on" ))spc.rel = true;
        else if(!strcmp(argv[i+1], "off"))spc.rel = false;
      }
      else if(!strcmp(argv[i], "-addr")) {
             if(!strcmp(argv[i+1], "on" ))spc.addr = true;
        else if(!strcmp(argv[i+1], "off"))spc.addr = false;
      }
      else if(!strcmp(argv[i], "-hex")) {
             if(!strcmp(argv[i+1], "on" ))spc.hex = true;
        else if(!strcmp(argv[i+1], "off"))spc.hex = false;
      }
    }
  }

  fp=fopen(argv[1], "rb");
  if(!fp) {
    printf("error opening: [%s]\n", argv[1]);
    return 0;
  }

//get file size
  fseek(fp, 0, SEEK_END);
  fsize = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  if(eof)spc.stop = spc.load + fsize;

//default state of spc memory is 0xff
  memset(spc.mem, 0xff, 65536);

//block a potential buffer overflow if fsize > spc.mem[]
  if(fsize + spc.load > 65536) { //fill all available memory, truncate file
    fread(spc.mem+spc.load, 1, 65536-spc.load, fp);
    if(eof)spc.stop = 0x0000;
  } else {                       //read entire file, stop if fsize > spc.mem[]
    fread(spc.mem+spc.load, 1, (fsize > 65536) ? 65536 : fsize, fp);
  }

  fclose(fp);

//perform disassembly
  wr=fopen(argv[argc-1], "wb");
//if spc.stop = 0, treat as a special value - it will disassemble until spc.pc
//wraps around the 0xffff limit and reaches back to 0
  do {
    disas_op();
  } while( (spc.stop == 0) ? spc.pc != 0 : spc.pc < spc.stop);
  fclose(wr);

  return 0;
}
