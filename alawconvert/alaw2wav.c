#include <stdio.h>

typedef enum { TRUE = 1, FALSE = 0 } bool;

int main(void)
{
    FILE *infilep=0;
    FILE *outfilep=0;
    FILE *wavstubfilep=0;
    const char* infile = "alaw.txt";
    const char* outfile = "tests-alaw.wav";
    const char* wavstubfile = "tests-alaw-roh.wav";
    unsigned char inb;
    bool bstart=FALSE;
    unsigned char outbyte = 0;

    infilep = fopen(infile,"r");
    wavstubfilep = fopen(wavstubfile,"r");
    outfilep = fopen(outfile,"w");
    if(!infilep || !outfilep || !wavstubfilep)
    {
        if(infilep) fclose(infilep);
        if(outfilep) fclose(outfilep);
        if(wavstubfilep) fclose(wavstubfilep);
    }
    //read the header from a file
    while(fscanf(wavstubfilep,"%c",&inb) != EOF)
    {
        fprintf(outfilep,"%c",inb);
    };
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
    if(wavstubfilep) fclose(wavstubfilep);
}
