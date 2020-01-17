#!/usr/bin/python3

import os

from entrypoint_helpers import env, gen_cfg, gen_container_id, str2bool, start_app


RUN_USER = env['run_user']
RUN_GROUP = env['run_group']
CROWD_INSTALL_DIR = env['crowd_install_dir']
CROWD_HOME = env['crowd_home']

gen_cfg('server.xml.j2', f'{CROWD_INSTALL_DIR}/apache-tomcat/conf/server.xml')
gen_cfg('crowd-init.properties.j2', f'{CROWD_INSTALL_DIR}/crowd-webapp/WEB-INF/classes/crowd-init.properties')

start_app(f'{CROWD_INSTALL_DIR}/start-crowd.sh -fg', CROWD_HOME, name='Crowd')
