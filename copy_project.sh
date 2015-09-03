#!/usr/bin/env bash

## Copy this skeleton project to X location and rename the vagrant guest virtual machine

usage() {
  cat << EOF
  Usage: $0 <options>

  OPTIONS:
    -n : node/hostname; REQUIRED
    -p : project name; Defaults to -n value
    -l : location to 'clone' the project,
         Defaults to the parent directory of
         of the vagrant_skeleton project
    -h : print usage
EOF
}

options=':p:l:hn:'
while getopts $options option; do
  case "${option}" in
    n) node_name=${OPTARG} ;;
    p) project_name=${OPTARG} ;;
    l) location=${OPTARG} ;;
    h) usage; exit 1 ;;
    /?) echo "Unknown option: -$OPTARG" >&2; 
      usage;
      exit 1 ;;
    :)
      echo "Missing option argument for -$OPTARG" >&2;
      usage;
      exit 1 ;;
    *)
      echo "Unimplemented option: -$OPTARG" >&2; 
      usage;
      exit 1 ;;
  esac
done


if [[ -z "${node_name}" ]]; then
  echo -e "Missing option argument for -n\n"
  usage
  exit 1
fi

if [[ -z ${project_name} ]]; then
  project_name=${node_name}
fi

# Get the full script path and parent directory
script=$(realpath "$0")
scriptpath=$(dirname "$script")

if [[ -z ${location} ]]; then
  location=$(dirname "$scriptpath")
fi

# Copy the Vagrant Skeleton project to $location path excluding .git directory

rsync -avq --rsync-path="mkdir -p ${location}/${project_name}" --exclude '.git' --exclude 'copy_project.sh' --exclude '.vagrant' "${scriptpath}/" "${location}/${project_name}"

# Replace the references to the default skeleton node name 'nodename1' in ALL file recursively
find "${location}/${project_name}" -type d \( -path ./.git \) -prune -o -type f -exec sed -i -e "s/nodename1/${node_name}/g" {} \;

# Rename files that contain the default skeleton node name 'nodename1'
find "${location}/${project_name}" -depth -type f -name "nodename1*" | while read FNAME; do mv "$FNAME" "${FNAME//nodename1/${node_name}}"; done

cat << EOF
  To deploy the Vagrant environment, change 
  to the directory of your new project. Execute Lirarian-Puppet
  to fetch required modules and issue the vagrant up command 

  $ cd ${location}/${project_name}/puppet/environments/dev
  $ librarian-puppet install && vagrant up
EOF


