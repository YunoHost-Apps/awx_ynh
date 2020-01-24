#! /bin/sh
#
#     This file is part of the Squashtest platform.
#     Copyright (C) Henix, henix.fr
#
#     See the NOTICE file distributed with this work for additional
#     information regarding copyright ownership.
#
#     This is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     this software is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public License
#     along with this software.  If not, see <http://www.gnu.org/licenses/>.
#


#That script will :
#- check that the java environnement exists,
#- the version is adequate,
#- will run the application


# Default variables
JAR_NAME="squash-tm.war"  # Java main library
HTTP_PORT=8080                             # Port for HTTP connector (default 8080; disable with -1)
# Directory variables
TMP_DIR=/opt/squash-tm/tmp                             # Tmp and work directory
BUNDLES_DIR=/opt/squash-tm/bundles                     # Bundles directory
CONF_DIR=/opt/squash-tm/conf                           # Configurations directory
LOG_DIR=/opt/squash-tm/logs                            # Log directory
TOMCAT_HOME=/opt/squash-tm/tomcat-home                  # Tomcat home directory
PLUGINS_DIR=/opt/squash-tm/plugins                     # Plugins directory
# DataBase parameters
DB_TYPE=mysql                                 # DAtabase type, one of h2, mysql, postgresql
DB_URL=jdbc:mysql://localhost:3306/yunobase           # DataBase URL
DB_USERNAME=yunouser                             # DataBase username
DB_PASSWORD=yunopass                             # DataBase password
## Do not configure a third digit here
REQUIRED_VERSION=1.8
# Extra Java args
JAVA_ARGS="-Xms128m -Xmx1024m -server"


# Tests if java exists
echo -n "$0 : checking java environment... ";

java_exists=`java -version 2>&1`;

if [ $? -eq 127 ]
then
    echo;
    echo "$0 : Error : java not found. Please ensure that \$JAVA_HOME points to the correct directory.";
    echo "If \$JAVA_HOME is correctly set, try exporting that variable and run that script again. Eg : ";
    echo "\$ export \$JAVA_HOME";
    echo "\$ ./$0";
    exit -1;
fi

echo "done";

# Create logs and tmp directories if necessary
if [ ! -e "$LOG_DIR" ]; then
    mkdir $LOG_DIR
fi

if [ ! -e "$TMP_DIR" ]; then
    mkdir $TMP_DIR
fi

# Tests if the version is high enough
echo -n "checking version... ";

NUMERIC_REQUIRED_VERSION=`echo $REQUIRED_VERSION |sed 's/\./0/g'`;
java_version=`echo $java_exists | grep version |cut -d " " -f 3  |sed 's/\"//g' | cut -d "." -f 1,2 | sed 's/\./0/g'`;

if [ $java_version -lt $NUMERIC_REQUIRED_VERSION ]
then
    echo;
    echo "$0 : Error : your JRE does not meet the requirements. Please install a new JRE, required version ${REQUIRED_VERSION}.";
    exit -2;
fi

echo  "done";


# Let's go !
echo "$0 : starting Squash TM... ";

export _JAVA_OPTIONS="-Dspring.datasource.url=${DB_URL} -Dspring.datasource.username=${DB_USERNAME} -Dspring.datasource.password=${DB_PASSWORD} -Duser.language=en"
DAEMON_ARGS="${JAVA_ARGS} -Djava.io.tmpdir=${TMP_DIR} -Dlogging.dir=${LOG_DIR} -jar ${BUNDLES_DIR}/${JAR_NAME} --spring.profiles.active=${DB_TYPE} --spring.config.additional-location=${CONF_DIR}/ --spring.config.name=application,squash.tm.cfg --logging.config=${CONF_DIR}/log4j2.xml --squash.path.bundles-path=${BUNDLES_DIR} --squash.path.plugins-path=${PLUGINS_DIR} --server.port=${HTTP_PORT} --server.tomcat.basedir=${TOMCAT_HOME} "

exec java ${DAEMON_ARGS}

