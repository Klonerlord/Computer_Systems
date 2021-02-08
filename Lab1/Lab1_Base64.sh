#!/bin/bash

cat $1 |
awk \
'function encode64()
{
  while( "od -v -t x1 $1" | getline ) # reading lines of a file, that was already translated to hex, once per cycle
  {
    for(c=9; c<=length($0); c++)
    {
      hindex=index("0123456789abcdef",substr($0,c,1)); # geting the index of hex symbol for bit shifting
      if(hindex--)
      {
        for(b=1; b<=4; b++ ) # 4 iterations because we use hex system for shifting and one symbol at a time
        {
          result=result*2+int(hindex/8); # result decimal value of encoded sector
          hindex=(hindex*2)%16; # part that we get from hex and use for counting what exact bit was shifted to left. 0 if less than 8 and 1 if bigger
          if(++symbol_counter==6) # bit counter
          {
            printf substr(base64,result+1,1);
            if(++symbol_counter>75) # to make output more readable, output 75 symbols per line
            {
              printf("\n");
              symbol_counter=0;
            }
            symbol_counter=0;
            result=0;
          }
        }
      }
    }
  }
  if(symbol_counter)
  {
    while(symbol_counter++<6)
    {
      result=result*2;
    }
    printf "%c",substr(base64,result+1,1);
  }
  print "==";
}

BEGIN {
  base64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  encode64();
}'