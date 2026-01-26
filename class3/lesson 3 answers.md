# Solutions to Git Class Assignments
## Assignment
 1. GitHub repository URL
[https://github.com/henria21/gitclass/](https://github.com/henria21/gitclass/)
 2. Image of git Log
![log image](https://github.com/henria21/devops-course/blob/main/class3/Images/1%20log.png)
 3. Python file attached
[https://github.com/henria21/devops-course/blob/main/class3/app.py](https://github.com/henria21/devops-course/blob/main/class3/app.py)

## Bonus Git Assignment – Hands-On Advanced Practice**

#### Inspecting History (Hands-On)

**git log --oneline**  
```
baaffea (HEAD -> main, origin/main, origin/HEAD) merged main and feature/add-time message conflict  
0c9a1a3 (origin/feature/add-time, feature/add-time) change greeting 2  
1e42802 change greeting 1  
a74e62b add time to message  
48481db add first version of app.py  
792d8d4 Merge branch 'branch2'  
1c0dcbc (branch2) diffrent change to dockerfile  
87c8488 (origin/branch1, branch1) changing docker file  
4995b04 adding docker file
```
![log image](https://github.com/henria21/devops-course/blob/main/class3/Images/2%20log.png)

 2. added file history graph
 ```
 *   commit baaffea14cd8d8d5bb9c8e66a649f360691f4327
|\  Merge: 1e42802 0c9a1a3
| | Author: henria21 <33258485+henria21@users.noreply.github.com>
| | Date:   Thu Jan 15 14:23:10 2026 +0200
| | 
| |     merged main and feature/add-time message conflict
| | 
| * commit 0c9a1a3d8cb33530055bea322e8e604e467be4d5
| | Author: henria21 <33258485+henria21@users.noreply.github.com>
| | Date:   Thu Jan 15 14:14:21 2026 +0200
| | 
| |     change greeting 2
| | 
* | commit 1e42802c5aa5a394cb009e5e3b03575eb467c7ad
|/  Author: henria21 <33258485+henria21@users.noreply.github.com>
|   Date:   Thu Jan 15 14:13:03 2026 +0200
|   
|       change greeting 1
| 
* commit a74e62bd61d7875be736d4523b1ce83b51bfcf66
| Author: henria21 <33258485+henria21@users.noreply.github.com>
| Date:   Thu Jan 15 14:00:57 2026 +0200
| 
|     add time to message
| 
* commit 48481dbfdd8dc2a07ba900a0c2670c37b5f8d009
| Author: henria21 <33258485+henria21@users.noreply.github.com>
| Date:   Thu Jan 15 13:57:20 2026 +0200
| 
|     add first version of app.py
|   
*   commit 792d8d4106b87e04ac22b70410d0614cf9c2cf73
|\  Merge: 87c8488 1c0dcbc
| | Author: henria21 <33258485+henria21@users.noreply.github.com>
| | Date:   Thu Jan 15 13:54:36 2026 +0200
| | 
| |     Merge branch 'branch2'
| | 
| * commit 1c0dcbc9b606bd6d12755971fdeccdc46e97a459
| | Author: henria21 <33258485+henria21@users.noreply.github.com>
| | Date:   Mon Jan 12 20:53:28 2026 +0200
| | 
| |     different change to dockerfile
| | 
* | commit 87c84883b92bf24b10cf3117be4a7dab96a5f8d1
|/  Author: henria21 <33258485+henria21@users.noreply.github.com>
|   Date:   Mon Jan 12 20:02:42 2026 +0200
|   
|       changing docker file
| 
* commit 4995b040d71b8365a2d763e5d0ed617f3c2e76c5
  Author: henria21 <33258485+henria21@users.noreply.github.com>
  Date:   Mon Jan 12 19:54:09 2026 +0200
  
      adding docker file
 ```
 4. added to file git commit show
 ```
 commit 4995b040d71b8365a2d763e5d0ed617f3c2e76c5
Author: henria21 <33258485+henria21@users.noreply.github.com>
Date:   Mon Jan 12 19:54:09 2026 +0200

    adding docker file

diff --git a/Dockerfile b/Dockerfile
new file mode 100644
index 0000000..3e9afe6
--- /dev/null
+++ b/Dockerfile
@@ -0,0 +1,6 @@
+FROM python:3-slim
+WORKDIR /usr/src
+COPY app.py /usr/src
+#Port documantion
+EXPOSE 8080
+CMD ["python","/usr/src/app.py"]
 ```
### 2. Diff Practice (Hands-On)

git diff

git add app.py

git diff --staged

git restore app.py

git restore --staged app.py

### 3. Undoing Commits (Hands-On)

3.1. after **git restore --staged app.py** - before discard the change

**git diff**  
 ```
diff --git a/app.py b/app.py  
index d9133e8..54490fc 100644  
--- a/app.py  
+++ b/app.py  
@@ -2,7 +2,7 @@ import datetime  
  
def greet(name):  
  
- return f"Good by and fare well, Have a great day, {name}, time is {datetime.datetime.now()}!"  
+ return f"Good by and fare well, Have a BLESSED day, {name}, time is {datetime.datetime.now()}!"  
  
  
if __name__ == "__main__":
 ```
**discard**:

**git restore app.py**

after discard:

git diff is empty:

C:\Users\henri\OneDrive\Documents\GitHub\gitclass>**git diff**  
  
C:\Users\henri\OneDrive\Documents\GitHub\gitclass>

**undoing a commit**

**git diff**  
 ```
diff --git a/app.py b/app.py  
index d9133e8..c518514 100644  
--- a/app.py  
+++ b/app.py  
@@ -2,7 +2,7 @@ import datetime  
  
def greet(name):  
  
- return f"Good by and fare well, Have a great day, {name}, time is {datetime.datetime.now()}!"  
+ return f"Good day, {name}, time is {datetime.datetime.now()}!"  
  
  
if __name__ == "__main__":  
  ``` 
**git add app.py**  
  
**git diff**  
  
**git commit app.py -m "fix timestamp"**  
 ```
[main 100a448] fix timestamp  
1 file changed, 1 insertion(+), 1 deletion(-)
 ```
**revert**:

git revert 8acbba6  
 ```
hint: Waiting for your editor to close the file... unix2dos: converting file C:/Users/henri/OneDrive/Documents/GitHub/gitclass/.git/COMMIT_EDITMSG to DOS format...  
dos2unix: converting file C:/Users/henri/OneDrive/Documents/GitHub/gitclass/.git/COMMIT_EDITMSG to Unix format...  
[main 4dbbf25] Revert "fix the message 2"  
1 file changed, 1 insertion(+), 1 deletion(-)  
 ```  
**git log --oneline**  
 ```
4dbbf25 (HEAD -> main) Revert "fix the message 2"  
8acbba6 fix the message 2  
baaffea (origin/main, origin/HEAD) merged main and feature/add-time message conflict  
0c9a1a3 (origin/feature/add-time, feature/add-time) change greeting 2  
1e42802 change greeting 1  
a74e62b add time to message  
48481db add first version of app.py  
792d8d4 Merge branch 'branch2'  
1c0dcbc (branch2) different change to dockerfile  
87c8488 (origin/branch1, branch1) changing docker file  
4995b04 adding docker file
 ```
### 4. Stashing Work (Hands-On):

**git stash**  
 ```
Saved working directory and index state WIP on main: 4dbbf25 Revert "fix the message 2"  
 ```  
**git stash list**  
```
stash@{0}: WIP on main: 4dbbf25 Revert "fix the message 2"  
```
**git stash pop**  
 ```
On branch main  
Your branch is ahead of 'origin/main' by 2 commits.  
(use "git push" to publish your local commits)  
  
Changes not staged for commit:  
(use "git add <file>..." to update what will be committed)  
(use "git restore <file>..." to discard changes in working directory)  
modified: app.py  
  
no changes added to commit (use "git add" and/or "git commit -a")  
Dropped refs/stash@{0} (5e89fb2a81d0b64682fa7f599291c06511450806)
 ```
### 5. Branch Cleanup (Hands-On):

**git branch -d temp/cleanup**  
 ```
Deleted branch temp/cleanup (was b8313dc).
 ```
**Required Commands**

git branch temp/cleanup

git checkout temp/cleanup

git commit -am "Temporary change"

git checkout main

git merge temp/cleanup

git branch -d temp/cleanup

### 6. Remote Sync (Hands-On)

after fetch diff was:
 ```
diff --git a/app.py b/app.py  
index acb63e2..d9133e8 100644  
--- a/app.py  
+++ b/app.py  
@@ -2,7 +2,7 @@ import datetime  
  
def greet(name):  
  
- return f"Good by , {name}, time is {datetime.datetime.now()}!"  
+ return f"Good by and fare well, Have a great day, {name}, time is {datetime.datetime.now()}!"  
  
  
if __name__ == "__main__":
 ```
after: **git pull --rebase**

the changes i made in local kept but all the changes that were in remote main were synced to my local branch and then local changes were added on top

### 7. Rebase Practice (Advanced – Hands-On)

**Required Commands**

git checkout -b feature/rebase-practice

git rebase main

git rebase –continue
![rebase image](https://github.com/henria21/devops-course/blob/main/class3/Images/3%20rebase.png)

<![endif]-->

### 8, Tagging a Release (Hands-On)

**Required Commands**

git tag v1.0.0

git push origin v1.0.0

git show v1.0.0
![tags image](https://github.com/henria21/devops-course/blob/main/class3/Images/4%20tags.png)

<![endif]-->

### 9. .gitignore Practice (Hands-On)

**Before**:

git status
```
On branch main

Your branch is up to date with 'origin/main'.

Untracked files:

(use "git add <file>..." to include in what will be committed)

.env

nothing added to commit but untracked files present (use "git add" to track)
```
**After:**

echo .env >> .gitignore

git status
```
On branch main

Your branch is up to date with 'origin/main'.

Untracked files:

(use "git add <file>..." to include in what will be committed)

.gitignore

nothing added to commit but untracked files present (use "git add" to track)

To fix fit ignore tracking i use:

git add .gitignore

git commit -m "Add .gitignore"

and then status shows

On branch main

Your branch is ahead of 'origin/main' by 1 commit.

(use "git push" to publish your local commits)

nothing to commit, working tree clean
```
### 10. HEAD & Detached HEAD (Hands-On)

**Required Commands**

git checkout <commit-hash>

git status

git checkout main

![checkout image](https://github.com/henria21/devops-course/blob/main/class3/Images/5%20checkout.png)
<![endif]-->

### 11. Real-World Recovery Scenarios (Hands-On)

**Commit to main by Mistake**

git branch feature/mistake

git reset --hard HEAD~1

**Broken Merge**

git merge feature/add-time

git merge –abort

![log image](https://github.com/henria21/devops-course/blob/main/class3/Images/6%20log.png)