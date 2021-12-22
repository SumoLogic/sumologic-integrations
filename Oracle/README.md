# Oracle RDBMS
### Step 1. Install the Telegraf Agent
If you don’t have the Telegraf agent installed, use the [following steps](https://help.sumologic.com/03Send-Data/Collect-from-Other-Data-Sources/Collect_Metrics_Using_Telegraf/03_Install_Telegraf) to install Telegraf. Otherwise, continue to step 2.
### Step 2. Create Sumo User in Oracle
```sh
CREATE USER sumo_user IDENTIFIED BY "<yourpassword>";
GRANT select_catalog_role TO sumo_user;
GRANT CREATE SESSION TO sumo_user;
```
If you get error ```ORA-65096: invalid common user or role name``` when creating ```sumo_user```

You set the undocumented (hidden) parameter ```"_oracle_script"=true```  you can create the fred user without a C## in from of the user ID.  However, this user will not used useful in a pluggable/container database:
```sh
ALTER session SET "_ORACLE_SCRIPT"=true;
CREATE USER sumo_user IDENTIFIED BY "<yourpassword>";
GRANT select_catalog_role TO sumo_user;
GRANT CREATE SESSION TO sumo_user;
```
### Step 3. Install Python
 1. Make sure python 3.6 or higher is installed on the Telegraf agent server.
 2. Install python package cx_Oracle. Use the following snippet.
    ```sh
    python3 -m pip install cx_Oracle --upgrade
    ```
### Step 4. Create a Script to Gather Oracle RDBMS Metrics
 1. Download [sumo_oracle_metrics.py](https://raw.githubusercontent.com/SumoLogic/sumologic-integrations/main/Oracle/sumo_oracle_metrics.py) onto your Telegraf agent server.
 2. Test the script execution using this command:
    ```sh
    python3 sumo_oracle_metrics.py
    ```
    You should get a response similar to this:
    ```sh
    usage: sumo_oracle_metrics.py [-h] -u USER -p PASSWD -s SID
    sumo_oracle_metrics.py: error: the following arguments are required: -u/--user, -p/--passwd, -s/--sid
    ```
    If the script is not executing, adjust the file permission and the Python path.
 3. Download [exec_oracle_metrics.sh](https://raw.githubusercontent.com/SumoLogic/sumologic-integrations/main/Oracle/exec_oracle_metrics.sh) onto your Telegraf agent server.
 4. Edit the script to change the environment variables, and python execution path for your Telegraf agent server.
 5. Change the ```<sumo_user-password>``` & ```<sid>``` parameters in ```exec_oracle_metrics.sh``` file
    ```sh
    # Example.
    /usr/bin/python3.6 "/home/oracle/sumo_oracle_metrics.py" -u "sumo_user" -p "sumopassword123" -s "orcl"
    ```
 6. Note down the full paths for files downloaded and saved from steps 1 & 3 above
### Step 5. Configure Telegraf Exec Input Plugin
**For Linux Telegraf agent server**

Create a file called ```oracle.conf``` in ```/etc/telegraf/telegraf.d``` and enter the following snippet:
```sh
[[inputs.exec]]
   commands = ["/<path_TO_BE_CHANGEME>/exec_oracle_metrics.sh"]
   timeout = "5s"
   data_format = "influx"
  [inputs.exec.tags]
    environment="<DEV_TO_BE_CHANGEME>"
    component="database"
    db_system="oracle"
    db_cluster="<PROD_TO_BE_CHANGEME>"

[[outputs.sumologic]]
  url = "<URL_from_HTTP_Logs_and_Metrics_Source>"
  data_format = "prometheus"
```
Enter values for fields annotated with ```<VALUE_TO_BE_CHANGED>``` to the appropriate values. Do not include the brackets (```<>```) in your final configuration
* Input plugins section, which is ```[[inputs.exec]]```:
    * **commands** - The exec plugin executes all the ```commands``` in parallel on every interval and parses metrics from their output in any one of the accepted Input Data Formats.
* In the tags section, which is ```[inputs.exec.tags]```:
    * **environment** - This is the deployment environment where the Oracle cluster identified by the value of **servers** resides. For example: **dev**, **prod**, or **QA**. While this value is optional we highly recommend setting it. 
    * **db_cluster** - Enter a name to identify this Oracle cluster. This cluster name will be shown in our dashboards. 
* In the output plugins section, which is ```[[outputs.sumologic]]```: 
    * **URL** - This is the HTTP source URL created previously. See this doc for more information on additional parameters for configuring the Sumo Logic Telegraf output plugin.

**For Windows Telegraf agent server.**

Edit the ```telegraf.conf``` file located at ```Program Files\Telegraf``` and enter the following snippet:
```sh
[[inputs.exec]]
   commands = [
         'python "<path_TO_BE_CHANGEME>\sumo_oracle_metrics.py" -u "sumo_user" -p "<password_TO_BE_CHANGEME>" -s "<sid_TO_BE_CHANGEME>"'
			]
   timeout = "5s"
   data_format = "influx"
  [inputs.exec.tags]
    environment="<DEV_TO_BE_CHANGEME>"
    component="database"
    db_system="oracle"
    db_cluster="<PROD_TO_BE_CHANGEME>"

[[outputs.sumologic]]
  url = "<URL_from_HTTP_Logs_and_Metrics_Source>"
  data_format = "prometheus"
```
Enter values for fields annotated with ```<VALUE_TO_BE_CHANGED>``` to the appropriate values. Do not include the brackets (```<>```) in your final configuration
* Input plugins section, which is ```[[inputs.exec]]```:
    * **commands** - The exec plugin executes all the ```commands``` in parallel on every interval and parses metrics from their output in any one of the accepted Input Data Formats.
* In the tags section, which is ```[inputs.exec.tags]```:
    * **environment** - This is the deployment environment where the Oracle cluster identified by the value of **servers** resides. For example: **dev**, **prod**, or **QA**. While this value is optional we highly recommend setting it. 
    * **db_cluster** - Enter a name to identify this Oracle cluster. This cluster name will be shown in our dashboards. 
* In the output plugins section, which is ```[[outputs.sumologic]]```: 
    * **URL** - This is the HTTP source URL created previously. See this doc for more information on additional parameters for configuring the Sumo Logic Telegraf output plugin.
### Step 6. Restart Telegraf
**For Linux**

Run ```sudo service telegraf restart``` to restart your Telegraf agent.

**For Windows**

Restart the Telegraf service using the Windows Services Management Console or from the command prompt:
```sh
net stop telegraf
net start telegraf
```