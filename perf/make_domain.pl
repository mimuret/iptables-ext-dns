#!/usr/bin/perl

use String::Random;

for(my $i=0;$i<10000;$i++) {
        $domain = String::Random->new->randregex('[A-Za-z0-9]{63}\.[A-Za-z0-9]{63}\.[A-Za-z0-9]{63}\.[A-Za-z0-9]{48}\.example\.com\.');
        print("$domain A\n");
}
