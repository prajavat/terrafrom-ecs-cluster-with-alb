#!/bin/bash
#
# exec 2>>/var/log/ecs/ecs-agent-install.log
# set -x
# until curl -s http://localhost:51678/v1/metadata
# do
# 	sleep 1
# done
#install the Docker volume plugin
docker plugin install rexray/ebs REXRAY_PREEMPT=true EBS_REGION=us-east-1 --grant-all-permissions
#restart the ECS agent
stop ecs 
start ecs