#!/bin/env bash

# Change the paths for the environment variables appropriate for your environment.

# The LD_LIBRARY_PATH environment variable to specify directory paths that the linker should search for libraries specified
# Exam: /oracle/app/oracle/product/19.1.0.1/dbhome_1/lib/
export LD_LIBRARY_PATH=<ld_library_path>

#The ORACLE_HOME environment variable to point to the directory where the Oracle database client software is installed.
# Exam: /oracle/app/oracle/product/19.1.0.1/dbhome_1
export ORACLE_HOME=<oracle_home>

# The PYTHONPATH is an environment variable which you can set to add additional directories where python will look for modules and packages
# Exam: /usr/bin/python3.6
export PYTHONPATH=<python_path>

export PATH=PATH:/usr/bin/python3.6

export TNS_ADMIN=$ORACLE_HOME/network/admin

# The ORACLE_SID identifies the name of a specific database instance and tells the Operating System which Oracle Instance to apply your commands. 
# Exam: vdb102128111
export ORACLE_SID=<oracle_sid>


#point to the Python install path like '/usr/bin/python' below.
/usr/bin/python3.6 "/root/sumo_oracle_metrics.py" -u "sumo_user" -p "<sumo_user-password>" -s "<sid>"
