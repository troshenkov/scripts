#!/bin/bash

# ===================================================================
# Script to Force DNS Cluster Synchronization on WHM/cPanel Servers
# ===================================================================
#
# This script triggers a forced synchronization of the DNS cluster 
# in a WHM/cPanel environment. The script uses the built-in WHM/cPanel
# command `/scripts/dnscluster syncall` to initiate synchronization
# across all servers in the DNS cluster.
#
# Usage:
# - Simply run this script as root or a user with sufficient privileges
#   on a WHM/cPanel server.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

/scripts/dnscluster syncall

exit 0
