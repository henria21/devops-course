# Lesson 1 — Linux & DevOps Introduction
> Source: `2912.01.pptx` (46 slides) — *DevOps Experts Class 1*

---

## DevOps Philosophy

**What is DevOps?**
- DevOps is about culture, enablement, and collaboration
- Shorter feedback loops between developers and their product
- Automate everything — infrastructure, tasks, integrations, deployment
- Monitor what is important, avoid false positives

**Benefits of DevOps:**
- Speed, reliability, faster time to market
- Less manual ops, effective monitoring
- More responsibility, better troubleshooting
- Teams are more productive, more collaboration

---

## Development Methodologies

### Waterfall
- Linear, long time between dev and production
- Many teams involved, not parallel
- Not dynamic and practical to changes
- Each step requires a lot of work and effort

### Agile
- Quick and cyclic behaviour and flow
- Smaller iterations → smaller parts to production
- Faster feedback loops, better ability to measure work
- Small and hybrid teams → less distance between employees

---

## CI/CD Pipeline

### Continuous Integration (CI)
- Practice of routinely integrating code changes into the main branch
- Testing changes as early and often as possible (daily, or multiple times a day)
- Each integration: automated builds, tests, product integrations
- Popular tools: Jenkins, Travis CI, GitHub Actions

### Continuous Delivery
- Teams produce software in short cycles
- Software can be reliably released at any time
- Aims at building, testing, and releasing with greater speed and frequency

### Artifact
- A DevOps engineer delivers an **artifact** — a file deployed to an artifact repository
- Built with a unique version indicating the code version
- Artifact repository stores pre-built, tested, integrated versions of code
- Ensures the same exact object built and tested is shipped to production

### Continuous Deployment
- Every change goes through the pipeline and automatically gets put into production
- Results in many production deployments every day

---

## Linux Fundamentals

### What is Linux?
- Family of free and open-source operating systems built around the Linux kernel
- Distributed as "distros": Ubuntu, Red Hat, CentOS, Fedora, OpenSuse
- Linux kernel first released September 17, 1991, by Linus Torvalds

### Ubuntu OS
- Free and open-source Linux-based OS, popular for user-friendly interface
- Widely used in servers and cloud environments
- Uses `apt` (Advanced Package Tool) for package management
- Backed by Canonical with LTS (Long-Term Support) versions
- Ideal for Docker, Kubernetes, Ansible, AWS, Azure

### Shell & Terminal
- Shell: program that takes commands from the keyboard and gives them to the OS
- Most Linux systems use **bash**
- Terminal emulator: program that opens a window to interact with the shell
- `sudo`: allows users to run programs with root privileges ("Run as administrator" equivalent)

---

## Core Linux Commands

| Command | Description |
|---|---|
| `pwd` | Print working directory — shows absolute path |
| `ls` | List files; `ls -a` shows hidden files |
| `cd` | Change directory |
| `mkdir` | Create a directory |
| `rmdir` | Delete an empty directory |
| `rm` | Delete files or directories containing files |
| `touch` | Create a file (e.g., `touch users.txt`) |
| `cp` | Copy files — `cp source destination` |
| `mv` | Move (or rename) files |
| `echo` | Write text to a file — `echo hello >> new.txt` |
| `cat` | Display contents of a file |
| `tar` | Work with tarballs/archives |
| `zip` / `unzip` | Compress/extract zip archives |

---

## File Permissions — `chmod`

Linux file permissions define access for:
- **User** (owner), **Group**, **Others**

### Octal notation
Each digit is a combination of: `4` = read, `2` = write, `1` = execute, `0` = no permission

```
chmod 754 myfile
```
- `7` = 4+2+1 → user: read, write, execute
- `5` = 4+0+1 → group: read, execute
- `4` = 4+0+0 → others: read only

---

## Package Manager — `apt`

```bash
sudo apt-get update              # Update package database
sudo apt-get install <package>   # Install a package
sudo apt-get remove <package>    # Remove a package
```

---

## Text Editors

| Editor | Notes |
|---|---|
| **vi** | Original editor (1976); command mode + insert mode |
| **vim** | "vi improved" — syntax highlighting, multi-level undo, split screen |
| **nano** | Most user-friendly; Ctrl+X to save/exit, Ctrl+W to search |

### vi / vim key commands
- `i` — enter insert mode
- `Esc` — return to command mode
- `:wq` — save and exit
- Install vim: `sudo apt-get install vim`

---

## System Utilities

| Utility | Description |
|---|---|
| `top` | Real-time process monitor (CPU/memory) |
| `htop` | Interactive version of top |
| `df` | Disk space usage |
| `du` | Directory/file disk usage |
| `ps` | List active processes |
| `kill [PID]` | Terminate a process |
| `uptime` | System uptime and load average |

---

## Linux Processes

- **Foreground** vs **Background** processes: append `&` to run in background (e.g., `sleep 100 &`)
- `fg` — bring background process to foreground
- `ps` — list current processes
- `kill [PID]` — terminate process by PID
- `nice` / `renice` — adjust process priority

---

## System Signals

| Signal | Number | Meaning |
|---|---|---|
| SIGINT | 2 | Interrupt (Ctrl+C) |
| SIGTERM | 15 | Politely ask process to terminate |
| SIGKILL | 9 | Forcefully terminate |
| SIGSTOP | 19 | Pause process |
| SIGCONT | 18 | Continue stopped process |

---

## Key Takeaways

1. DevOps = culture + automation + shorter feedback loops
2. CI/CD pipeline: code → build → test → artifact → deploy → monitor
3. Linux is the foundation of most DevOps infrastructure
4. Master the core commands: `ls`, `cd`, `mkdir`, `chmod`, `apt`, `ps`, `kill`
5. Waterfall → Agile → DevOps = evolution toward faster, more reliable delivery

---

## Assignment

**10 exercises covering Linux fundamentals:**

| # | Topic | Task |
|---|---|---|
| 1 | **File System Basics** | Create `~/linux_course/` with `week1/` and `week2/` subdirectories; write a file |
| 2 | **File Permissions** | Create a private file; set permissions to `600` (owner read/write only) |
| 3 | **Finding Files** | Create multiple `.txt` files; use `find` to locate all of them |
| 4 | **Text Manipulation** | Write log lines with `echo`; filter with `grep` into a separate file |
| 5 | **Process Monitoring** | Run `sleep 300 &`; find it with `ps aux`; terminate it with `kill` |
| 6 | **Disk Usage** | Write `df -h` and `du -sh` output to a report file |
| 7 | **Networking** | Check IP with `ip a`; ping Google and save output |
| 8 | **Shell Scripting** | Write a bash script; make it executable; run it |
| 9 | **Scheduling Tasks** | Create a cron job that logs a timestamp every minute |
| 10 | **Archiving** | Create a tar archive and compress it with gzip |

---

## Student Answers

```bash
# Solution 1: File System Basics
mkdir ~/linux_course
mkdir ~/linux_course/week1 ~/linux_course/week2
echo "Welcome to Linux!" > ~/linux_course/week1/intro.txt

# Solution 2: File Permissions
touch ~/linux_course/week1/private_data
chmod 600 ~/linux_course/week1/private_data
ls -l ~/linux_course/week1/private_data

# Solution 3: Finding Files
touch ~/linux_course/week2/file1.txt ~/linux_course/week2/file2.txt ~/linux_course/week2/file3.txt
find ~/linux_course -name "*.txt"

# Solution 4: Text Manipulation
echo -e "error: Disk space low\ninfo: System rebooted\nwarning: High memory usage" > ~/linux_course/week2/log.txt
grep "error" ~/linux_course/week2/log.txt > ~/linux_course/week2/error.log

# Solution 5: Process Monitoring
sleep 300 &
ps aux | grep sleep
kill <PID>

# Solution 6: Disk Usage
df -h > ~/linux_course/week2/disk_report.txt
du -sh ~/linux_course >> ~/linux_course/week2/disk_report.txt

# Solution 7: Networking
ip a
ping -c 4 google.com > ~/linux_course/week2/ping_output.txt

# Solution 8: Shell Scripting
echo -e '#!/bin/bash\necho "Hello, Linux!"' > ~/linux_course/hello.sh
chmod +x ~/linux_course/hello.sh
~/linux_course/hello.sh

# Solution 9: Scheduling Tasks
echo "* * * * * echo $(date) >> ~/linux_course/timestamp.log" | crontab -

# Solution 10: Archiving and Compression
tar -cvf linux_course.tar ~/linux_course
gzip linux_course.tar
tar -tvf linux_course.tar.gz
```
