# Git Workflow Guide

## Working on `InventoryManagement` Branch

- Do your changes locally.
- **Commit** and **Push** directly to `origin/InventoryManagement`.

Example:

```bash
git add .
git commit -m "Your message"
git push origin InventoryManagement
```

---

## Updating `main` with `InventoryManagement`

**Preferred:** Create a **Pull Request** on GitHub from `InventoryManagement` → `main` for review.

**Alternative (local merge):**

```bash
git checkout main
git fetch origin
git pull origin main           # make sure local main is up to date
git merge InventoryManagement  # merge feature branch into main
git push origin main           # push merged changes to remote
```

---

## (Optional) Keeping `InventoryManagement` Updated with `main`

If new commits are added to `main` and you want them in your branch:

```bash
git checkout InventoryManagement
git fetch origin
git merge origin/main
git push origin InventoryManagement
```
