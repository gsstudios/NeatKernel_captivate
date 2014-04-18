#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Clear the console before starting
  clear

# Create a variable to store the version
  export version=0.1

# Create bold and normal types of letter
  export t_bold=`tput bold`
  export t_normal=`tput sgr0`
  export red=$(tput setaf 1)             #  red
  export grn=$(tput setaf 2)             #  green
  export blu=$(tput setaf 4)             #  blue
  export cya=$(tput setaf 6)             #  cyan

# Introducing test
  echo
  echo "${red}${t_bold}-----------------------------------"
  echo "${blu} Neatkernel auto-maker menu"
  echo "${red}-----------------------------------"
  echo "${t_normal} Version $version"
  echo
  echo


# question:
  echo "${grn}${t_bold} Which device you would like to build?"

# Answers:
  echo "${t_normal} 1. captivatemtd"
  echo " 2. vibrantmtd"
  echo " 3. galaxysmtd"
  echo " 4. captivatemtd_swapsd"
  echo " 5. vibrantmtd_swapsd"
  echo " 6. galaxysmtd_swapsd"
  echo
  echo " ${red}c. clean script"
  echo " r. Restart"
  echo " x. Exit"
  

# Read the letter the user gives
  echo
read enterLetter

# captivatemtd
  if [ "$enterLetter" == "1" ]
    then
    ./build_kernel.sh captivate

# vibrantmtd
  elif [ "$enterLetter" == "2" ]
    then
    ./build_kernel.sh vibrant

# galaxysmtd
  elif [ "$enterLetter" == "3" ]
    then
    ./build_kernel.sh galaxys

# captivatemtd_swapsd
  elif [ "$enterLetter" == "4" ]
    then
    ./build_kernel.sh captivate_swapsd

# vibrantmtd_swapsd
  elif [ "$enterLetter" == "5" ]
    then
    ./build_kernel.sh vibrant_swapsd

# galaxysmtd_swapsd
  elif [ "$enterLetter" == "6" ]
    then
    ./build_kernel.sh galaxys_swapsd

# clean script
  elif [ "$enterLetter" == "c" ]
    then
    ./clean_kernel.sh

# Restart
  elif [ "$enterLetter" == "r" ]
    then
    ./menu.sh

# Exit
  elif [ "$enterLetter" == "x" ]
    then
exit 0

# Other choice
  else
echo "Invalid option"
    continue
fi


