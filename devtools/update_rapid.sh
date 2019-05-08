#!/bin/bash

# This script updates rapid's nimble package to the latest version.
# Made for use on my local machine, this script may not work on other machines.

nimble -y uninstall rapid
cd ../rapid
nimble -y install
cd ../planet_overgamma
