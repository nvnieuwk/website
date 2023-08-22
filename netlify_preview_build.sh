#!/bin/bash
#####################################################################
# NEXTFLOW WEBSITE
#####################################################################

# DESCRIPTION
#       for build JBake project on Netlify
#
# USAGE
#       Assume the root directory of your git repository is the root
#       directory of your JBake project.
#       On Netlify, set `Build Cmd` to `sh build.sh [JBake_version]`,
#       then Netlify will build your JBake project with the JBake version
#       you specified.
#
#       For example, if you want to build the project with JBake v2.4.0,
#       just set `sh build.sh 2.4.0` in `Build Cmd`.
#
#       If you don't specify the version number, i.e. `sh build.sh`,
#       then the latest JBake version is used.
#
# CREDIT
#       https://github.com/Mushiyo/netilfy-jbake-example-project-groovy
#
if [ $# -eq 0 ]
then # if no argument passed in, set jBake to latest version
    jbake_version=2.3.1
else
    jbake_version=$1
fi
echo "downloading JBake v$jbake_version"
wget --quiet https://github.com/jbake-org/jbake/releases/download/v$jbake_version/jbake-$jbake_version-bin.zip
echo "unzipping JBake v$jbake_version"
unzip -o -q jbake-$jbake_version-bin.zip
jbake-$jbake_version/bin/jbake -b


#####################################################################
# NEXTFLOW DOCUMENTATION
#####################################################################

# Make the empty target directories
mkdir -p output/docs/latest
mkdir -p output/docs/edge

# Fetch the Nextflow repo
cd ../
git clone https://github.com/nextflow-io/nextflow.git
cd nextflow/docs/

# Find the latest stable and edge releases
STABLE_TAG=$(curl -s https://api.github.com/repos/nextflow-io/nextflow/releases | jq -r ". [].tag_name" | grep -v edge | head -n 1)
EDGE_TAG=$(curl -s https://api.github.com/repos/nextflow-io/nextflow/releases | jq -r ". [].tag_name" | grep edge | head -n 1)
echo "Latest stable release: $STABLE_TAG"
echo "Latest edge release: $EDGE_TAG"

# Sanity check: Assert string lengths
if [ ${#STABLE_TAG} -le 4 ]; then echo "Version string too short" ; exit 1; fi
if [ ${#EDGE_TAG} -le 4 ]; then echo "Version string too short" ; exit 1; fi

# Build edge docs
git checkout $EDGE_TAG
pip install -r requirements.txt
make clean html
mv _build/html/* ../../website/output/docs/edge/

# Build stable docs
git checkout $STABLE_TAG
pip install -r requirements.txt
make clean html
mv _build/html/* ../../website/output/docs/latest/
