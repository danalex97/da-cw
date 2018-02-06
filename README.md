# da-cw
Alexandru Dan(ad5915) and Maurizio zen(mz4715)

### Running locally

To run the system locally use:
```
make MAIN=<system>.local_start local
```

E.g.
```
make MAIN=System1.local_start local
```

The number of messages, timeouts, link reliability and number of peers can be set as follows:
```
make MAIN=<system>.local_start \
  MAX_MESSAGES=<max-messages> \
  TIMEOUT=<timeout-in-milliseconds> \
  LINK_REL=<link-reliability-percent> local
```

E.g.
```
make MAIN=System4.local_start MAX_MESSAGES=10000000 TIMEOUT=3000 LINK_REL=50 local
```

### Running on Docker

To run the system on docker use:
```
make MAIN=<system>.network_start up
```

E.g.
```
make MAIN=System1.network_start up
```

The number of messages, timeouts, link reliability and number of peers can be set as follows:
```
make MAIN=<system>.network_start \
  MAX_MESSAGES=<max-messages> \
  TIMEOUT=<timeout-in-milliseconds> \
  LINK_REL=<link-reliability-percent> up
```

E.g.
```
make MAIN=System4.network_start MAX_MESSAGES=10000000 TIMEOUT=3000 LINK_REL=50 up
```

### Clean

To clean:
```
make clean
```

To clean the used containers replace `up` with `down` for Docker.
