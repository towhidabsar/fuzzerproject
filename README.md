fuzzerproject
=============

The fuzzer web application testing project.


To run for dvwa type in https://127.0.0.1/dvwa
To run for bodgeit type in https://127.0.0.1/bodgeit

Currently the --customauthen= does not function but it will run the custom authentication with these two inputs.

To run for dvwa input:

fuzz test http://127.0.0.1/dvwa --custom-auth=dvwa --vectors=vectors-small.txt --sensitive=sensitive-data.txt