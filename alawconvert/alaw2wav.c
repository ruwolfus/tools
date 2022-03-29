#include <stdio.h>
#include "alaw2wav.h"

//#define HEADERFROMFILE
//#define WRITEHEADER

typedef enum { TRUE = 1, FALSE = 0 } bool;

int main(void)
{
    FILE *infilep=0;
    FILE *outfilep=0;
#ifdef HEADERFROMFILE    
    FILE *wavstubfilep=0;
#endif    
    const char* infile = "alaw.txt";
#ifdef WRITEHEADER
    const char* outfile = "tests-alaw.wav";
#else
    const char* outfile = "alaw.bin";
#endif
#ifdef HEADERFROMFILE    
    const char* wavstubfile = "tests-alaw-roh.wav";
#endif    
    unsigned char inb;
    bool bstart=FALSE;
    unsigned char outbyte = 0;
    unsigned char header[1000];
    int headerlen = 0;

    infilep = fopen(infile,"r");
#ifdef HEADERFROMFILE    
    wavstubfilep = fopen(wavstubfile,"r");
#endif    
    outfilep = fopen(outfile,"w");
    if(!infilep || !outfilep
#ifdef HEADERFROMFILE    
    || !wavstubfilep
#endif    
    )
    {
        if(infilep) fclose(infilep);
        if(outfilep) fclose(outfilep);
#ifdef HEADERFROMFILE        
        if(wavstubfilep) fclose(wavstubfilep);
#endif        
    }
    //read the header from a file
#ifdef HEADERFROMFILE
    while(fscanf(wavstubfilep,"%c",&inb) != EOF && (headerlen < sizeof(header)))
    {
      header[headerlen++] = inb;
    };
#else    
    while((headerlen < sizeof(header)) && (headerlen < sizeof(headerraw)))
    {
      header[headerlen] = headerraw[headerlen];
      headerlen++;
    };
#endif    

#ifdef WRITEHEADER
    int i = 0;
    while(i < headerlen)
    {
        fprintf(outfilep,"%c",header[i++]);
    };
#endif    

    //read samples from tracefile
    while(fscanf(infilep,"%c",&inb) != EOF)
    {
      if(inb==' ' || !(((inb>='0')&&(inb<='9'))||((inb>='a')&&(inb<='f'))))
      {
          bstart=FALSE;
          continue;
      }
/*
      if(inb=='b')
      {
        printf("test\n");
      }
*/
      if((inb>='0')&&(inb<='9')) inb-='0';
      else inb-='a'-10;

      if(bstart==FALSE)
      {
        outbyte=inb;
        outbyte=outbyte<<4;
        bstart=TRUE;
        continue;
      }
      else
      {
        outbyte+=inb;
        bstart=FALSE;
      }
      fprintf(outfilep,"%c",outbyte);
      outbyte=0;
    };

    if(infilep) fclose(infilep);
    if(outfilep) fclose(outfilep);
#ifdef HEADERFROMFILE    
    if(wavstubfilep) fclose(wavstubfilep);
#endif
}
