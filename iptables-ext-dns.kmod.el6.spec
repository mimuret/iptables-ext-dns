%define _unpackaged_files_terminate_build 0
%define _mod_dir kernel/net/netfilter
%define kmod_name iptables-ext-dns

#el6
%{!?kversion: %define kversion 2.6.32-573.el6.%{_target_cpu}}

Summary: Administration tool for IPv4/IPv6 TCP/UDP packet filtering.
Name: iptables-ext-dns
Version: 1.2.0
Release: 0%{?dist}
License: GPLv3
Group: System Environment/Base
Source: https://github.com/mimuret/iptables-ext-dns/iptables-ext-dns-%{version}.zip
URL: https://github.com/mimuret/iptables-ext-dns
Requires: iptables iptables-ipv6 nc
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX
BuildRequires: gcc make automake libtool kabi-whitelists iptables-devel kernel-headers kernel-devel

#el6
Source10: kmodtool-%{kmod_name}-el6.sh

%{expand:%(sh %{SOURCE10} rpmtemplate %{kmod_name} %{kversion} "")}

%description
Administration tool for IPv4/IPv6 TCP/UDP packet filtering.

%prep
%{__rm} -rf ${RPM_BUILD_ROOT}

%setup
autoreconf --install --force --verbose
%{configure} --libdir=/%{_lib}
echo "override %{kmod_name} * weak-updates/%{kmod_name}" > kmod-%{kmod_name}.conf

%build
%{__make}

%install
install -m755 -d ${RPM_BUILD_ROOT}/lib/modules/%{kversion}/extra/%{kmod_name}/
install modules/xt_dns.ko ${RPM_BUILD_ROOT}/lib/modules/%{kversion}/extra/%{kmod_name}/

install -m755 -d ${RPM_BUILD_ROOT}%{_sysconfdir}/depmod.d/
install kmod-%{kmod_name}.conf ${RPM_BUILD_ROOT}%{_sysconfdir}/depmod.d/

install -m755 -d ${RPM_BUILD_ROOT}%{_defaultdocdir}/kmod-%{kmod_name}-%{version}/

install -m755 -d ${RPM_BUILD_ROOT}%{_datadir}/%{name}-%{version}/test
install -m755 -d ${RPM_BUILD_ROOT}%{_datadir}/%{name}-%{version}/test/common
install -m755 -d ${RPM_BUILD_ROOT}%{_datadir}/%{name}-%{version}/test/ipv4
install -m755 -d ${RPM_BUILD_ROOT}%{_datadir}/%{name}-%{version}/test/ipv6
install -m755 -d ${RPM_BUILD_ROOT}%{_datadir}/%{name}-%{version}/test/util
install -m755 test/common/*.sh ${RPM_BUILD_ROOT}%{_datadir}/%{name}-%{version}/test/common
install -m755 test/ipv4/*.sh ${RPM_BUILD_ROOT}%{_datadir}/%{name}-%{version}/test/ipv4
install -m755 test/ipv6/*.sh ${RPM_BUILD_ROOT}%{_datadir}/%{name}-%{version}/test/ipv6
install -m755 test/util/*.sh ${RPM_BUILD_ROOT}%{_datadir}/%{name}-%{version}/test/util

export INSTALL_MOD_PATH=${RPM_BUILD_ROOT}
export INSTALL_MOD_DIR=extra/%{kmod_name}
#export INSTALL_MOD_DIR=%{_mod_dir}

%{__make} DESTDIR=${RPM_BUILD_ROOT} install

%clean
%{__rm} -rf ${RPM_BUILD_ROOT}

%post

%postun

%files
%defattr(-,root,root)

%doc LICENSE
%doc README.md

/etc/depmod.d/kmod-iptables-ext-dns.conf
/%{_lib}/xtables/libxt_dns.*

%{_datadir}

%changelog
* Fri Feb 26 2016 t0r0t0r0
- 1st
