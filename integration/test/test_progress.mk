#  Copyright (c) 2015 - 2024, Intel Corporation
#  SPDX-License-Identifier: BSD-3-Clause
#

EXTRA_DIST += integration/test/test_progress.py

if ENABLE_OPENMP
if ENABLE_MPI
check_PROGRAMS += integration/test/test_progress
integration_test_test_progress_SOURCES = integration/test/test_progress.cpp
integration_test_test_progress_SOURCES += $(model_source_files)
integration_test_test_progress_LDADD = libgeopm.la $(MATH_LIB) $(MPI_CLIBS)
integration_test_test_progress_LDFLAGS = $(AM_LDFLAGS) $(MPI_CLDFLAGS) $(MATH_CLDFLAGS)
integration_test_test_progress_CXXFLAGS = $(AM_CXXFLAGS) $(MPI_CFLAGS) -D_GNU_SOURCE -std=c++11 $(MATH_CFLAGS)
endif
else
EXTRA_DIST += integration/test/test_progress.cpp
endif
