# Solutions to Linux Class Assignments
#### Solution 1: File System Basics

mkdir ~/linux_course
mkdir ~/linux_course/week1 ~/linux_course/week2
echo "Welcome to Linux!" > ~/linux_course/week1/intro.txt

----------

#### Solution 2: File Permissions

touch ~/linux_course/week1/private_data

chmod 600 ~/linux_course/week1/private_data

ls -l ~/linux_course/week1/private_data

----------

#### Solution 3: Finding Files

touch ~/linux_course/week2/file1.txt ~/linux_course/week2/file2.txt ~/linux_course/week2/file3.txt
find ~/linux_course -name "*.txt"

----------
#### Solution 4: Text Manipulation

echo -e "error: Disk space low\ninfo: System rebooted\nwarning: High memory usage" > ~/linux_course/week2/log.txt

grep "error" ~/linux_course/week2/log.txt > ~/linux_course/week2/error.log
 
----------
#### Solution 5: Process Monitoring

sleep 300 &

ps aux | grep sleep

kill <PID> # Replace <PID> with the process ID of the sleep process

----------

#### Solution 6: Disk Usage

df -h > ~/linux_course/week2/disk_report.txt

du -sh ~/linux_course >> ~/linux_course/week2/disk_report.txt

----------
#### Solution 7: Networking

ip a # Or ifconfig

ping -c 4 google.com > ~/linux_course/week2/ping_output.txt

----------

#### Solution 8: Shell Scripting

echo -e '#!/bin/bash\necho "Hello, Linux!"' > ~/linux_course/hello.sh

chmod +x ~/linux_course/hello.sh

~/linux_course/hello.sh

----------

#### Solution 9: Scheduling Tasks

echo "* * * * * echo $(date) >> ~/linux_course/timestamp.log" | crontab -

Verify using:
cat ~/linux_course/timestamp.log` after a few minutes

----------

#### Solution 10: Archiving and Compression

tar -cvf linux_course.tar ~/linux_course

gzip linux_course.tar

tar -tvf linux_course.tar.gz