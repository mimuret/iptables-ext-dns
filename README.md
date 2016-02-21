# iptables-ext-dns
Administration tool for IPv4/IPv6 TCP/UDP packet filtering.

##build & install
####`CentOS 6`
```bash
sudo yum install gcc make automake libtool \
iptables-devel kernel-headers

git -b kernel2.6 clone https://github.com/mimuret/iptables-ext-dns.git
cd iptables-ext-dns

./autogen.sh
./configure --libdir=/lib64
make
sudo make install
```

####`CentOS 7`
```bash
sudo yum install gcc make automake libtool \
iptables-devel kernel-headers

git -b kernel3 clone https://github.com/mimuret/iptables-ext-dns.git
cd iptables-ext-dns

./autogen.sh
./configure --libdir=/lib64
make
sudo make install
```


## Usage
```option
dns match options:
[!] --qr match when response
[!] --opcode match
      (Flags QUERY,IQUERY,STATUS,NOTIFY,UPDATE)
[!] --aa match when Authoritative Answer
[!] --tc match when Truncated Response
[!] --rd match when Recursion Desired
[!] --ra match when Recursion Available
[!] --ad match when Authentic Data
[!] --cd match when checking Disabled
[!] --qname
[!] --qtype
    (Flags ex. A,AAAA,MX,NS,TXT,SOA... )
        see. http://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml
[!] --reverse-match --rmatch reverse matching flag
```

## Example
### Ex. accept example.jp request.`
`qname` option default match mode is exact match.

This sample matches 'example.jp', but not matches 'hogehoge.example.jp'.

```bash
iptables -A INPUT  -m dns --qname example.jp -j ACCEPT
ip6tables -A INPUT  -m dns --qname example.jp -j ACCEPT
```

### Ex. drop ${random}.example.jp. request.`
`rmatch` option changes match mode to reverse match.

This sample matches 'example.jp' and 'hogehoge.example.jp,'.

```bash
iptables -A INPUT  -m dns --rmatch --qname example.jp -j DROP
ip6tables -A INPUT  -m dns --rmatch --qname example.jp -j DROP
```

### Ex. drop ${random}.example.jp. request qname len > 64 .`
`maxlen` option provide qname length filtering.

This sample not matches 'example.jp.' and 'hogehoge.example.jp.'.

but 'OJcoaTh297tDwtkNCAV2vtLwh3P0S6Ldce6Oas0Sug6YJGCniluVLoEPBBIOTEr.example.com.' is matched
```bash
iptables -A INPUT  -m dns --rmatch --qname example.jp ! --maxsize 64 -j DROP
ip6tables -A INPUT  -m dns --rmatch --qname example.jp ! --maxsize 64 -j DROP
```

### Ex. drop QType ANY`
'qtype' option provide QType filter.

This sample is drop query when type is ANY.
```bash
iptables -A INPUT -m dns --qtype ANY --maxsize 64 -j DROP
ip6tables -A INPUT -m dns --qtype ANY --maxsize 64 -j DROP
```
