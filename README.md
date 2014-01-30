gdb
=======

gdb_ebp.exp 		Translates breakpoints into HW breakponts on the fly. 
			Original TinKer wrapper. Used as inspiration.

gdb_tab.exp		Connects to rel GDB, but also opens a TCP server to use
			"on the side"

To make this wrap-tool work it's best, make sure you have the following
tools installed (the script can't tell you and it accepts no flags and will
fall-back to something, not as pleasant):

* rlwrap
* nc
* screen

SCRIPT3 note:
-------------
This project is a script sub-library and is part of a larger project managed
as a Google-repo called "SCRIPT3" (or "s3" for short). S3 can be found
here: https://github.com/mambrus/script3

To download and install any of s3's sub-projects, use the Google's "repo" tool
and the manifest file in the main project above. Much better documentation
there too. 

Note that most of s3's sub-project files won't operate without s3 easily (or
at all).
  
