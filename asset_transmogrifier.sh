#!/bin/bash

#NOTES: chmod this script with chmod 755 to run as regular local user

#This line allows for passing in a source file as an argument to the script (i.e: ./script.sh source_file.txt)
input_file="$1"

#This creates the folder structure used to mount the SMB Share and copy the assets over to the local machines
SOURCE_FILES_ROOT_DIR="${HOME}/operations/source" 
DESTINATION_FILES_ROOT_DIR="${HOME}/operations/copied_files"

#This creates the fileshare mount point and place to copy files over to on the local machine.
 echo "Creating initial folders..."
 mkdir -p "${SOURCE_FILES_ROOT_DIR}"
 mkdir -p "${DESTINATION_FILES_ROOT_DIR}"
 echo "Folders Created! Destination files will be copied to ${DESTINATION_FILES_ROOT_DIR}"

#This loop checks if a line is empty or not then processes the original data so it can be used to pull the assets
while read -r line; 
  do 
    if [ -z "$line" ]; then
      continue;
    fi
    line=${line/\\\\///}
    line=${line//\\//}
    line=${line%%\"*\"}
    SERVER_NAME=$(echo "$line" | cut -d / -f 4);
    SHARE_NAME=$(echo "$line" | cut -d / -f 5);
    ASSET_LOC=$(echo "$line" | cut -d / -f 6-);
    SMB_MOUNT_PATH="//$(sisaacs)@${SERVER_NAME}/${SHARE_NAME}";

     if df -h | grep -q "${SMB_MOUNT_PATH}"; then
       echo "${SHARE_NAME} is already mounted. Copying files..."
     else
       echo "Mounting it"
       mount_smbfs "${SMB_MOUNT_PATH}" "${SOURCE_FILES_ROOT_DIR}"
      fi

   cp -a ${SOURCE_FILES_ROOT_DIR}/${ASSET_LOC} ${DESTINATION_FILES_ROOT_DIR}

  done < $input_file

# cleanup
 hdiutil unmount ${SOURCE_FILES_ROOT_DIR}

exit 0