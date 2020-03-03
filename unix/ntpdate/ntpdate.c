/*
 * This code will query a ntp server for the local time and display
 * it.  it is intended to show how to use a NTP server as a time
 * source for a simple network connected device.
 * This is the C version.  The orignal was in Perl
 *
 * For better clock management see the offical NTP info at:
 * http://www.eecis.udel.edu/~ntp/
 *
 * written by Tim Hogard (thogard@abnormal.com)
 * Thu Sep 26 13:35:41 EAST 2002
 * Converted to C Fri Feb 21 21:42:49 EAST 2003
 * this code is in the public domain.
 * it can be found here http://www.abnormal.com/~thogard/ntp/
 *
 */
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <time.h>
#include <string.h>

void ntpdate();

typedef struct
{
    uint8_t li_vn_mode;      // Eight bits. li, vn, and mode.
                             // li.   Two bits.   Leap indicator.
                             // vn.   Three bits. Version number of the protocol.
                             // mode. Three bits. Client will pick mode 3 for client.

    uint8_t stratum;         // Eight bits. Stratum level of the local clock.
    uint8_t poll;            // Eight bits. Maximum interval between successive messages.
    uint8_t precision;       // Eight bits. Precision of the local clock.

    uint32_t rootDelay;      // 32 bits. Total round trip delay time.
    uint32_t rootDispersion; // 32 bits. Max error aloud from primary clock source.
    uint32_t refId;          // 32 bits. Reference clock identifier.

    uint32_t refTm_s;        // 32 bits. Reference time-stamp seconds.
    uint32_t refTm_f;        // 32 bits. Reference time-stamp fraction of a second.

    uint32_t origTm_s;       // 32 bits. Originate time-stamp seconds.
    uint32_t origTm_f;       // 32 bits. Originate time-stamp fraction of a second.

    uint32_t rxTm_s;         // 32 bits. Received time-stamp seconds.
    uint32_t rxTm_f;         // 32 bits. Received time-stamp fraction of a second.

    uint32_t txTm_s;         // 32 bits and the most important field the client cares about. Transmit time-stamp seconds.
    uint32_t txTm_f;         // 32 bits. Transmit time-stamp fraction of a second.

} ntp_packet;              // Total: 384 bits or 48 bytes.

int main() {
    ntpdate();
    return 0;
}

void ntpdate() {
char    *host_name="ptbtime2.ptb.de";
//char    *host_name="de.pool.ntp.org";
//char    *hostip="188.68.53.92";

int portno=123;     //NTP is port 123
int maxlen=1024;        //check our buffers
int i;          // misc var i
unsigned char msg[48]={010,0,0,0,0,0,0,0,0};    // the packet we send
unsigned long  buf[maxlen]; // the buffer we get back
struct protoent *proto;     //
struct sockaddr_in server_addr;
int s;  // socket
time_t tmit;   // the time -- This is a time_t sort of
struct sockaddr saddr;
socklen_t saddr_l;
struct hostent *server;      // Server data structure.
struct timeval newtime;
int serverzone;

//argv[1] ); host_name

proto=getprotobyname("udp");
s=socket(PF_INET, SOCK_DGRAM, proto->p_proto);
if(!s) perror("socket");
//if(s) printf("socket=%d\n",s);

//#convert hostname to ipaddress
server = gethostbyname( host_name );
if ( server == NULL )
{
	printf("ERROR, no such host");
	return;
}
memset( &server_addr, 0, sizeof( server_addr ));
server_addr.sin_family=AF_INET;
//server_addr.sin_addr.s_addr = inet_addr(hostip);
bcopy( ( char* )server->h_addr, ( char* ) &server_addr.sin_addr.s_addr, server->h_length );
server_addr.sin_port=htons(portno);
printf("host_name:%s\n",host_name);
printf("ipaddr:0x%x\n",server_addr.sin_addr);

/*
 * build a message.  Our message is all zeros except for a one in the
 * protocol version field
 * msg[] in binary is 00 001 000 00000000 
 * it should be a total of 48 bytes long
*/

// send the data
//printf("sending data..\n");
i=sendto(s,msg,sizeof(msg),0,(struct sockaddr *)&server_addr,sizeof(server_addr));
if (!i) perror("Result sendto:");
//printf("receiving data..\n");

// get the data back
saddr_l = sizeof (saddr);
i=recvfrom(s,buf,48,0,&saddr,&saddr_l);
if (!i) perror("Result recvfrom:");
//printf("recvfrom: %d\n",i);

//We get 12 long words back in Network order
/*
for(i=0;i<12;i++)
    printf("%d\t%-8x\n",i,ntohl(buf[i]));
*/

/*
 * The high word of transmit time is the 10th word we get back
 * tmit is the time in seconds not accounting for network delays which
 * should be way less than a second if this is a local NTP server
 */

tmit=ntohl((time_t)buf[10]);    //# get transmit time
//printf("tmit=%d\n",tmit);

/*
 * Convert time to unix standard time NTP is number of seconds since 0000
 * UT on 1 January 1900 unix time is seconds since 0000 UT on 1 January
 * 1970 There has been a trend to add a 2 leap seconds every 3 years.
 * Leap seconds are only an issue the last second of the month in June and
 * December if you don't try to set the clock then it can be ignored but
 * this is importaint to people who coordinate times with GPS clock sources.
 */

tmit-= 2208988800U; 
//printf("tmit=%d\n",tmit);
/* use unix library function to show me the local time (it takes care
 * of timezone issues for both north and south of the equator and places
 * that do Summer time/ Daylight savings time.
 */


//#compare to system time
i=time(0);
printf("\nNetTime: %sSysTime: %s",ctime(&tmit),ctime((time_t*)&(i)));
printf("%d-%d=%d\n",i,tmit,i-tmit);
//printf("System time is %d seconds off\n",i-tmit);

newtime.tv_sec = mktime(localtime(&tmit));
newtime.tv_usec = 0;
//Zeitzone korrigieren -> wenn 2 dann eine Stunde weniger
serverzone=-7200;
//if(-(double)(serverzone/3600.0) == 2) newtime.tv_sec -= 3600; //Sommerzeit	
//if(-(double)(serverzone/3600.0) == 1) newtime.tv_sec -= 3600; //Normalzeit ???

settimeofday(&newtime, NULL);

//printf("Server time is %sTimezone is UTC%+02.1f\n", asctime(localtime(&tmit)),-(double)(serverzone/3600.0));
}
