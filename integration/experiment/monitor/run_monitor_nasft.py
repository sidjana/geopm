#!/usr/bin/env python3
#
#  Copyright (c) 2015 - 2022, Intel Corporation
#  SPDX-License-Identifier: BSD-3-Clause
#

'''
Run nasft with the monitor agent.
'''

import argparse

from experiment.monitor import monitor
from experiment import machine
from apps.nasft import nasft


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    monitor.setup_run_args(parser)
    args, extra_args = parser.parse_known_args()
    mach = machine.init_output_dir(args.output_dir)
    app_conf = nasft.NasftAppConf(mach)
    monitor.launch(app_conf=app_conf, args=args,
                   experiment_cli_args=extra_args)
