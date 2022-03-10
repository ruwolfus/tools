rem outgoing call: rtpsession0 -> webrtc rtpsession1 -> rtp

rem grep -e"dump_mem() <udpsrc[02468]>" %1 > alaw1.txt
rem grep -v -e"SeqNr:" alaw1.txt > alaw2.txt
rem 2021-04-30T12:39:30,434931 12036 0x000024e8 memdump udpsrc gstudpsrc.c:1919 dump_mem() <udpsrc0>  (000000000F1A93E0) 00000000 : 80 88 00 01 00 00 00 a0 66 81 56 23
rem 5.tes : finden und alles davor wegmachen
rem awk -F':' '{print $5}' alaw2.txt > alaw1.txt

grep -e"dump_mem() <rtpsession1.recv_rtp_sink>" %1 > alaw1.txt
rem 2022-02-23T10:55:57,683740 19572 0x00000e88 memdump rtpsession gstrtpsession.c:2842 dump_mem() <rtpsession9:recv_rtp_sink>  (000000000A37F5D0) Pt:8 SeqNr:47167 time:10840462 0:00:00.010840462 ssrc:1766850906 tdiff:160
grep -v -e"SeqNr:" alaw1.txt > alaw2.txt
rem 6.tes : finden und alles davor wegmachen
awk -F':' '{print $6}' alaw2.txt > alaw1.txt

rem RTP-Header wegmachen (ersten 12 bytes) 
sed 's/ 80 .. .. .. .. .. .. .. .. .. .. ../ /' alaw1.txt > alaw.txt
del alaw1.txt
del alaw2.txt
alaw2wav.exe
ren alaw.txt alawrxrtp.txt
ren tests-alaw.wav testrxrtp-alaw.wav

rem goto ende

grep -e"dump_mem() <rtpsession0:send_rtp_src>" %1 > alaw1.txt
grep -v -e"SeqNr:" alaw1.txt > alaw2.txt
awk -F':' '{print $6}' alaw2.txt > alaw1.txt
rem RTP-Header wegmachen (ersten 12 bytes) 
sed 's/ 80 .. .. .. .. .. .. .. .. .. .. ../ /' alaw1.txt > alaw.txt
del alaw1.txt
del alaw2.txt
alaw2wav.exe
ren alaw.txt alawrxwebrtc.txt
ren tests-alaw.wav testrxwebrtc-alaw.wav

:ende

pause
