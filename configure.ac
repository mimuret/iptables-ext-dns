#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.63])
m4_define([VERSION_MAJOR],[1])
m4_define([VERSION_MINOR],[2])
m4_define([VERSION_MICRO],[0])
AC_INIT(iptables-ext-dns,m4_defn([VERSION_MAJOR]).m4_defn([VERSION_MINOR]).m4_defn([VERSION_MICRO]), mimuret@gmail.com, iptables-ext-dns)
AC_SUBST(VERSION_INFO, [VERSION_MAJOR:VERSION_MINOR:VERSION_MICRO])

AC_CONFIG_AUX_DIR(misc)
AM_INIT_AUTOMAKE([foreign])
AC_CONFIG_SRCDIR([extensions/libxt_dns.c])
AC_CONFIG_HEADERS([include/autoconfig.h])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.
# FIXME: Replace `main' with a function in `-lresolv':
AC_CHECK_LIB([resolv], [main])

# Checks for header files.
AC_CHECK_HEADERS([netinet/in.h stdlib.h string.h],[],[AC_MSG_ERROR([need header])])
AC_CHECK_HEADERS([xtables.h],[],[AC_MSG_ERROR([need xtables.h in iptables-devel])])

AC_HEADER_STDBOOL

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CHECK_FUNCS([strcasecmp strdup])

AC_CONFIG_FILES([Makefile extensions/Makefile test/Makefile])

AC_ARG_ENABLE(debug, [ --enable-debug trun on debugging [default no]],,enable_debug=no)
AC_MSG_CHECKING(whether to enable debuging)
if test x$enable_debug = xyes; then
   AC_MSG_RESULT(yes)
   AC_DEFINE(DEBUG,[],[for debugging])
   CXXFLAGS="$CXXFLAGS -g -O0 -Wall"
   CFLAGS="$CFLAGS -g -O0 -Wall"
else
   AC_MSG_RESULT(no)
fi
AC_CHECK_FILE([/etc/redhat-release],[AC_SUBST(libdir,[/lib64])],[])
AC_CHECK_FILE([/etc/debian_version],[AC_SUBST(libdir,[/lib])],[])
LT_INIT
AC_OUTPUT
