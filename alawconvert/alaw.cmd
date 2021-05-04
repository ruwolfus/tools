grep -e"dump_mem() <udpsrc[02468]>" %1 > alaw1.txt
grep -v -e"SeqNr:" alaw1.txt > alaw2.txt
rem 2021-04-30T12:39:30,434931 12036 0x000024e8 memdump udpsrc                    gstudpsrc.c:1919 dump_mem() <udpsrc0>  (000000000F1A93E0) 00000000 : 80 88 00 01 00 00 00 a0 66 81 56 23
rem 5.tes : finden und alles davor wegmachen
awk -F':' '{print $5}' alaw2.txt > alaw1.txt
rem RTP-Header wegmachen (ersten 12 bytes) 
sed 's/ 80 .. .. .. .. .. .. .. .. .. .. ../ /' alaw1.txt > alaw.txt
del alaw1.txt
del alaw2.txt
alaw2wav.exe
ren alaw.txt alawrxrtp.txt
ren tests-alaw.wav testrxrtp-alaw.wav

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

pause
