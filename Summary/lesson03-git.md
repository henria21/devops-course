# Lesson 3 — Git & Version Control
> Source: `Git.pptx` (59 slides) — *DevOps Experts Class 6 (Git)*

---

## What is Version Control?

Version control records changes to files over time so you can recall specific versions later.

| Type | Description |
|---|---|
| **Centralized** | Single server holds all versions (e.g., SVN) |
| **Distributed** | Every developer has a full copy (e.g., Git) |

### Git History
- Created in 2005 by Linus Torvalds for the Linux kernel
- Goals: speed, simple design, strong support for non-linear development, fully distributed
- Git is a tree structure — each commit = a new node in the tree

---

## Git Terminology

| Term | Meaning |
|---|---|
| **SHA** | Unique identifier for every commit/node in the Git tree |
| **HEAD** | Reference to the node the working space currently points to |
| **branch** | A label on a given node (not a physical copy of files) |
| **main** | The repository's main branch |
| **clone** | Copy an existing remote repository to local |
| **commit** | Submit (save) files to the local repository |
| **fetch** | Download latest changes from remote without merging |
| **pull** | fetch + merge combined |
| **push** | Submit code to a remote repository |
| **remote** | Remote location of your repository (usually on a server) |
| **merge** | Join two or more development histories together |
| **checkout** | Switch branches or restore working tree files |
| **revert** | Undo an existing commit (creates a new commit) |

---

## Initial Setup & Basic Workflow

```bash
git init
git config --global user.name "username"
git config --global user.email "your@email.com"

git status
git add .             # or: git add *
git commit -m "init commit"
git log
```

---

## Remote Repositories & GitHub

```bash
git remote add origin <git-url>   # Link to remote
git push origin main              # Push to remote
git clone <git-url>               # Clone a remote repo
```

**GitHub** is a web-based hosting service for Git repositories. It adds:
- Pull requests and code review
- Issue tracking
- Team collaboration features

---

## Branching

Branches allow isolated development of features without affecting main.

```bash
git branch <branch_name>          # Create branch
git checkout <branch_name>        # Switch to branch
git checkout -b <branch_name>     # Create and switch
git merge <branch_name>           # Merge branch into current
git log --graph --oneline --all   # Visual branch history
```

### Git Flow Pattern
```
main ← hotfix branches (fix and merge back)
  ↑
develop ← feature branches merge here
  ↑
feature branches (created per feature)
```

---

## Merge vs Rebase vs Fetch vs Pull

| Command | Behaviour |
|---|---|
| `git fetch` | Download changes from remote **without** merging — inspect first |
| `git pull` | Fetch + merge — gets latest and integrates into local branch |
| `git merge` | Joins branches, creates a merge commit (preserves history) |
| `git rebase` | Reapplies your commits on top of updated branch — **linear history** |

> `git pull` = merge approach; `git rebase` = linear history approach

---

## Conflict Resolution

Conflicts arise when two branches change the same lines in a file.

```
<<<<<<< HEAD
we are going to conflict
=======
world
>>>>>>> new-branch
```

**Resolution steps:**
1. Git marks the conflicted file
2. Developer manually edits the file to the desired content
3. `git add .` then `git commit` to complete the merge

### Example causing a conflict
```bash
git init
echo "hello" > a.txt && git add . && git commit -am "init"
git branch new-branch && git checkout new-branch
echo "world" > a.txt && git commit -am "branch change"
git checkout master
echo "newer change" > a.txt && git commit -am "master change"
git merge new-branch   # → CONFLICT
```

---

## Reset vs Revert

| Command | What it does |
|---|---|
| `git reset --hard <sha>` | "Go back" to a specific commit — rewrites history |
| `git revert <sha>` | Undo a specific commit by creating a **new** commit |

- **Reset** changes historical commits
- **Revert** creates a new commit with the undone changes (safer for shared branches)

```bash
git log --graph --pretty=oneline --abbrev-commit
git reset 39391c0 --hard      # hard reset to that commit
git revert 200ab45 --no-edit  # revert (new commit undoing that one)
```

---

## Detached HEAD

Occurs when you checkout a specific commit (not a branch):

```bash
git checkout <commit-sha>   # → HEAD is now detached
git status                  # shows "HEAD detached at ..."
git checkout master         # return to branch
```

---

## Cherry-Pick

Apply a specific commit from one branch onto another **without merging the full branch**.

```bash
git cherry-pick <commit-hash>       # Apply specific commit
git cherry-pick --continue          # After resolving conflicts
git cherry-pick --abort             # Abort if needed
```

**Use cases:**
- Backport a bug fix from main to a release branch
- Apply a tested experimental feature without full merge
- Isolate and reuse specific changes

---

## Code Review & Pull Requests

- When a developer finishes work, another developer reviews the code
- Review checks: logic errors, requirements coverage, style guidelines
- A pull request can only be merged after reviewer approval

---

## Monorepo vs Multi-repo

| Aspect | Monorepo | Multi-repo |
|---|---|---|
| Main benefit | Atomic changes across projects | Team autonomy & independent releases |
| Main drawback | Requires advanced tooling to scale | Hard cross-repo coordination |
| CI/CD | Unified, consistent pipelines | Isolated, simpler per repo |
| Dependencies | Single version, no drift | Version drift risk |

---

## IDE Integration (PyCharm / GitHub Desktop)

**PyCharm Git integration:**
1. File → Settings → Version Control → Git → set executable path
2. Clone: File → New → Project from Version Control → Git
3. Commit, push, pull, branch switching all available visually

**GitHub Desktop:**
- GUI client for cloning, branching, committing, pushing

---

## Key Takeaways

1. Git is a distributed VCS — every developer has the full history
2. Branches are cheap — create them freely for features and fixes
3. **Merge** preserves history; **Rebase** creates a clean linear history
4. **Reset** rewrites history; **Revert** is safe for shared branches
5. Cherry-pick lets you grab individual commits across branches
6. Always use pull requests and code review before merging to main

---

## Assignment

**Goal:** Practice branching, merging, and conflict resolution with a Python app.

**Parts:**
1. Create a GitHub repository `git-python-practice`
2. Clone it locally; add `app.py` with a `greet()` function; commit and push
3. Create branch `feature/add-time`; modify `greet()` to include timestamp; push branch
4. Merge `feature/add-time` → `main` (no conflict)
5. Create a real merge conflict: change `greet()` differently on `main` and on the feature branch; trigger and resolve manually
6. **Bonus advanced tasks:** inspect history, diff practice, undoing commits, stashing, branch cleanup, remote sync, rebase, tagging, `.gitignore`, detached HEAD, recovery scenarios

**Submission:** GitHub repo URL + `git log --oneline --graph` output + proof of conflict creation and resolution.

---

## Student Answers

**Repo:** [https://github.com/henria21/gitclass/](https://github.com/henria21/gitclass/)

**Key command outputs:**

```bash
# git log --oneline (after merging and reverting)
4dbbf25 (HEAD -> main) Revert "fix the message 2"
8acbba6 fix the message 2
baaffea merged main and feature/add-time message conflict
0c9a1a3 change greeting 2
1e42802 change greeting 1
a74e62b add time to message
48481db add first version of app.py
792d8d4 Merge branch 'branch2'
1c0dcbc different change to dockerfile
87c8488 changing docker file
4995b04 adding docker file
```

**Bonus highlights:**

```bash
# Diff before staging
git diff

# Stage and check staged diff
git add app.py
git diff --staged

# Revert a specific commit
git revert 8acbba6

# Stash and restore
git stash
git stash list
git stash pop

# Pull with rebase
git pull --rebase
# Result: local changes kept but remote changes applied first; local commits replayed on top

# Create and push tag
git tag v1.0.0
git push origin v1.0.0

# .gitignore — hide .env
echo .env >> .gitignore
git add .gitignore && git commit -m "Add .gitignore"

# Detached HEAD
git checkout <commit-hash>   # HEAD detached
git checkout main            # Return to branch

# Rebase feature branch onto main
git checkout -b feature/rebase-practice
git rebase main

# Recovery: commit to main by mistake
git branch feature/mistake
git reset --hard HEAD~1

# Recovery: abort a broken merge
git merge feature/add-time
git merge --abort
```
