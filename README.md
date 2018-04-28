gdb
=======

## Tools

| Name          | Meaning                                                    |
| ------------- | ---------------------------------------------------------- |
| `connect.sh`  | Connects to a ongoing `TCP-TAP`                            |
|               |                                                            |
| `isym.sh`     | ??? Obsolete?                                              |
|               |                                                            |
| `tap.sh`      | The main wrapper around `TCP-TAP`. You want to look inside this script |
|               |                                                            |
| `term.sh`     | Similar to `connect.sh` but opens a X-terminal for each session |
|               |                                                            |

## Historic tools

| Name          | Meaning                                                    |
| ------------- | ---------------------------------------------------------- |
| gdb_ebp.exp   | Translates breakpoints into HW breakponts on the fly.      |
|               | Original Tinker debugger-wrapper using Expect. Used as     |
|               | inspiration. May still come into good use for remote       |
|               | terminals as                                               |
|               | [`TCP-TAP`](https://github.com/mambrus/tcp_tap) does not   |
|               | really handle terminals.                                   |
|               |                                                            |
|gdb_tab.exp    |  Connects to rel GDB, but also opens a TCP server to use   |
|               |  "on the side"                                             |

To make this wrap-tool work it's best, make sure you have the following
tools installed (the script can't tell you and it accepts no flags and will
fall-back to something, not as pleasant):

* rlwrap
* netcat (nc) - Make sure it's  original BSD version
* screen
* (Expect)

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

