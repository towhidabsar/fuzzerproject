fuzzerproject
=============

The fuzzer web application testing project.


To run for dvwa type in http://127.0.0.1/dvwa
To run for bodgeit type in http://127.0.0.1/bodgeit

Typical command:

fuzz test http://127.0.0.1/dvwa --custom-auth=dvwa --vectors=vectors-small.txt --sensitive=sensitive-data.txt --slow=1000

The log of all the detailed vulnerabilities are found in output.txt.
The report outlining basic metrics of the problems found in the web application is report.txt.