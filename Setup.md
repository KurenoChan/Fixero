# Fixero Git Workflow

This document explains how our team will collaborate on the Fixero Flutter project using GitHub.

---

## 🔧 Prerequisites

1. Install **Visual Studio Code**.
2. Install Git on your computer: [Download Git](https://git-scm.com/downloads).
3. Install these VS Code extensions:

   * **GitHub Repositories**
   * **GitHub Pull Requests and Issues**

---

## 📂 Getting the Project for the First Time

1. Open VS Code.
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac) → type **"Git: Clone"**.
3. Paste the Fixero GitHub repository URL.
4. Choose a folder on your computer to save the project.
5. Open the project in VS Code.

---

## 🌱 Creating Your Own Branch

We use feature branches so everyone works separately before merging to `main`.

1. Look at the **bottom-left corner** of VS Code where the current branch name is displayed.
2. Make sure you are on `main`.
3. Click the branch name → select **"Create New Branch from..."**.
4. Name your branch using your own name or feature (e.g., `KohZhengHong` or `InventoryManagement`).
5. Click **"Publish Branch"** (this uploads your branch to GitHub).

---

## ✏️ Making Changes

1. Work on your feature in your own branch.
2. After making changes:

   * Go to **Source Control** panel in VS Code (`Ctrl+Shift+G`).
   * Write a commit message describing your changes.
   * Click **Commit**.
   * Click **Sync Changes** to push your commits to GitHub.

---

## 🔀 Creating a Pull Request (PR)

1. Once your feature is ready, go to **Source Control** → **Pull Request**.
2. Create a **New Pull Request** from your branch into `main`.
3. Add a description of what you changed.
4. Other team members can **review** your PR and leave comments.
5. After approval, click **Merge Pull Request** to merge into `main`.

---

## 👀 Testing Different Branches

* You can switch branches using the **bottom-left corner** branch name display.
* Run the project on each branch to check differences.
* Report any issues on the Pull Request page.

---

## 🔐 Firebase Setup

Firebase requires confidential keys, so these files are **not uploaded to GitHub**. Follow these steps:

1. Download the following from our shared **Google Drive**:

   * `firebase_init` folder → contains **`serviceAccountKey.json`**
     (Place this folder in your **project root**)
   * `google_services.json` → Android configuration file
     (Place this file inside **`/android/app/`**)
2. Open a terminal and run:

   ```bash
   cd firebase_init
   npm init -y
   ```

⚠️ **Do NOT upload these files or folders to GitHub.**