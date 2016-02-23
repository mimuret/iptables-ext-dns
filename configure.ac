#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.63])
AC_INIT(iptables-ext-dns,1.0.1 , mimuret@gmail.com)
AC_CONFIG_AUX_DIR(config/gnu)
AM_INIT_AUTOMAKE([foreign])
AC_CONFIG_SRCDIR([extensions/libxt_dns.c])
AC_CONFIG_HEADERS([include/autoconfig.h])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.
# FIXME: Replace `main' with a function in `-lresolv':
AC_CHECK_LIB([resolv], [main])

# Checks for header files.
AC_CHECK_HEADERS([netinet/in.h stdlib.h string.h xtables.h])

AC_HEADER_STDBOOL

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CHECK_FUNCS([strcasecmp strdup])

AC_CONFIG_FILES([Makefile extensions/Makefile])

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

LT_INIT
AC_OUTPUT
