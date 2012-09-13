#!/bin/bash

script_dir=$(dirname $0)

if [ -z "$JENKINS_HOME" ] || [ -z "$JOB_NAME" ]; then
    echo "Jenkins Environment variables not found" >&2
    exit 1
fi

LOG_LOCATION=${JENKINS_HOME}/jobs/${JOB_NAME}/builds

ORG=heat-api
SITE=${ORG}.github.com
LOG_DIR=test_logs

clone_site() {
    if [ ! -d $SITE ]; then
        git clone git@github.com:${ORG}/${SITE}.git
    fi

    pushd $SITE
    git config user.name "heat-gerrit"
    git config user.email "scd@broked.org"

    git pull --rebase
    [ -d $LOG_DIR ] || mkdir -p $LOG_DIR
    popd
}

update_logs() {
    pushd $SITE
    [ -d $LOG_DIR ] || mkdir -p $LOG_DIR
    rsync -r ${LOG_LOCATION}/ ${LOG_DIR}/${JOB_NAME}
    git add $LOG_DIR
    git commit -m "Sync ${BUILD_TAG} build logs"
    git push
    popd
}


cd $script_dir
clone_site
update_logs
