CC=gcc
all: checkdll.exe xampp_start.exe xampp_stop.exe xamppcli.exe

clean:
	rm -f checkdll.exe xampp_start.exe xampp_stop.exe xamppcli.exe
	rm -f *.o
	rm -f *.res

checkdll.exe: checkdll.c
	$(CC) -o checkdll.exe checkdll.c

xampp_util.o: xampp_util.c
	$(CC) -c -o xampp_util.o xampp_util.c

xampp.res: xampp.rc
	windres -o xampp.res -O coff xampp.rc

xampp_start.exe: xampp_start.c xampp_util.o xampp_util.h xampp.res
	$(CC) -o xampp_start.exe xampp_start.c xampp_util.o xampp.res

xampp_stop.exe: xampp_stop.c xampp_util.o xampp_util.h xampp.res
	$(CC) -o xampp_stop.exe xampp_stop.c xampp_util.o xampp.res

xamppcli.exe: xamppcli.c xampp_util.o xampp_util.h xampp.res
	$(CC) -o xamppcli.exe xamppcli.c xampp_util.o xampp.res

