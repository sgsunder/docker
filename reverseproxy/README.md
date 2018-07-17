# Reverse Proxy
Simple, automated reverse proxying service that integrates with the rest of
your Docker applications

Pass proxy commands as environment variables in the following format
```
proxy_somename=<origin prefix>|<destination hostname>:<destination port>|<destination prefix>
```
