rem outgoing call: rtpsession0 -> webrtc rtpsession1 -> rtp
rem incoming call: rtpsession1 -> webrtc rtpsession0 -> rtp (session0rx.bin==session1tx.bin session1rx.bin==session0tx.bin)

grep -e"dump_mem() <rtpsession1.recv_rtp_sink>" %1 > session1rx1.txt
rem 2022-02-23T10:55:57,683740 19572 0x00000e88 memdump rtpsession gstrtpsession.c:2842 dump_mem() <rtpsession9:recv_rtp_sink>  (000000000A37F5D0) Pt:8 SeqNr:47167 time:10840462 0:00:00.010840462 ssrc:1766850906 tdiff:160
grep -v -e"SeqNr:" session1rx1.txt > session1rx2.txt
rem 6.tes : finden und alles davor wegmachen
awk -F':' '{print $6}' session1rx2.txt > session1rx.txt

rem RTP-Header wegmachen (ersten 12 bytes) 
rem sed 's/ 80 .. .. .. .. .. .. .. .. .. .. ../ /' alaw1.txt > alaw.txt
del session1rx1.txt
del session1rx2.txt
rem alaw2wav.exe
rem mv alaw.txt alawrxrtp.txt
rem mv tests-alaw.wav testrxrtp-alaw.wav
cp session1rx.txt alaw.txt
alaw2bin.exe
mv alaw.bin session1rxrtp.bin
sed 's/ 80 .. .. .. .. .. .. .. .. .. .. ../ /' session1rx.txt > alaw1.txt
sed 's/ 90 .. .. .. .. .. .. .. .. .. .. ../ /' alaw1.txt > alaw.txt
alaw2bin.exe
mv alaw.bin session1rx.bin
del alaw.txt
del alaw1.txt

rem goto ende

grep -e"dump_mem() <rtpsession1.send_rtp_src>" %1 > session1tx1.txt
grep -v -e"SeqNr:" session1tx1.txt > session1tx2.txt
awk -F':' '{print $6}' session1tx2.txt > session1tx.txt
del session1tx1.txt
del session1tx2.txt
cp session1tx.txt alaw.txt
alaw2bin.exe
mv alaw.bin session1txrtp.bin
sed 's/ 80 .. .. .. .. .. .. .. .. .. .. ../ /' session1tx.txt > alaw1.txt
sed 's/ 90 .. .. .. .. .. .. .. .. .. .. ../ /' alaw1.txt > alaw.txt
alaw2bin.exe
mv alaw.bin session1tx.bin
del alaw.txt
del alaw1.txt

grep -e"dump_mem() <rtpsession0.send_rtp_src>" %1 > session0tx1.txt
grep -v -e"SeqNr:" session0tx1.txt > session0tx2.txt
awk -F':' '{print $6}' session0tx2.txt > session0tx.txt
del session0tx1.txt
del session0tx2.txt
cp session0tx.txt alaw.txt
alaw2bin.exe
mv alaw.bin session0txrtp.bin
sed 's/ 80 .. .. .. .. .. .. .. .. .. .. ../ /' session0tx.txt > alaw1.txt
sed 's/ 90 .. .. .. .. .. .. .. .. .. .. ../ /' alaw1.txt > alaw.txt
alaw2bin.exe
mv alaw.bin session0tx.bin
del alaw.txt
del alaw1.txt

grep -e"dump_mem() <rtpsession0.recv_rtp_sink>" %1 > session0rx1.txt
grep -v -e"SeqNr:" session0rx1.txt > session0rx2.txt
awk -F':' '{print $6}' session0rx2.txt > session0rx.txt
del session0rx1.txt
del session0rx2.txt
cp session0rx.txt alaw.txt
alaw2bin.exe
mv alaw.bin session0rxrtp.bin
sed 's/ 80 .. .. .. .. .. .. .. .. .. .. ../ /' session0rx.txt > alaw1.txt
sed 's/ 90 .. .. .. .. .. .. .. .. .. .. ../ /' alaw1.txt > alaw.txt
alaw2bin.exe
mv alaw.bin session0rx.bin
del alaw.txt
del alaw1.txt

:ende

pause
