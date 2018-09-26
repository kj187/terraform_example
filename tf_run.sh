#!/usr/bin/env bash

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
color_normal="\033[0m"; color_red="\033[0;31m"; color_green="\033[0;32m";
function echoerr { echo "============================================" 1>&2; echo_red "ERROR: $@" 1>&2;  echo "============================================" 1>&2; }
function error_exit { echoerr "$1"; exit 1; }
function echo_green { echo -e "${color_green}$1${color_normal}"; }
function echo_red { echo -e "${color_red}$1${color_normal}"; }

while getopts 'b:a:s:' OPTION ; do
    case "${OPTION}" in
        b) BASE_PATH="${OPTARG}" ;;
        a) ACCOUNT="${OPTARG}" ;;
        s) STAGE="${OPTARG}" ;;
    esac
done

if [ -z "${BASE_PATH}" ] ; then error_exit "BASE_PATH (-b) not set"; fi
if [ -z "${ACCOUNT}" ] ; then error_exit "ACCOUNT (-a) not set"; fi
if [ -z "${STAGE}" ] ; then error_exit "STAGE (-s) not set"; fi

echo "ACCOUNT: ${ACCOUNT}"
echo "STAGE: ${STAGE}"

BASE_PATH=${BASE_PATH%/}
if [ ! -d "${BASE_PATH}" ] ; then error_exit "Invalid base path (-b): ${BASE_PATH}"; fi
if [ ! -f "${BASE_PATH}/_configure.sh" ] ; then error_exit "Could not find _configure.sh"; fi
source "${BASE_PATH}/_configure.sh"
if [ -z "${KEY}" ] ; then error_exit "KEY was not set in _configure.sh"; fi
echo "KEY: ${KEY}"
cd "${BASE_PATH}" || error_exit "Error switching to base path"

VAR_FILE="-var-file=${SOURCE_DIR}/_settings/${ACCOUNT}_${STAGE}.json"

echo "---> Terraform Initialization"
[ -e .terraform/ ] && rm -rf .terraform/
[ -e terraform.tfstate.backup ] && rm terraform.tfstate.backup
terraform init \
    -input=false \
    -backend-config="key=${KEY}" \
    -force-copy || error_exit "Failed initializing terraform"

terraform apply -auto-approve ${VAR_FILE} || error_exit "Terraform failed"