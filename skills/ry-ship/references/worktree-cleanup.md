# Safe Branch & Worktree Cleanup (Windows Junction Guard)

Read this reference **only after the provider reports `MERGED`** and a task worktree (or linked branch) needs cleanup.

## Preconditions

- **Remote branch:** delete only if its tip equals the merged head and it is not default, protected, integration, or used by another open PR.
- **Task worktree:** remove only if created for this task, on the merged branch, clean (no uncommitted/untracked files and no commits beyond the merged head), and unused by any active session or process. Leave the main checkout, current working tree, and host-managed worktrees intact.
- **Local branch:** delete once no worktree holds it and no commits exist beyond the merged head (compare against the merged head since squash merges break ancestry checks).

## Windows-Safe Junction & Symlink Guard (Critical)

Worktrees frequently contain junctions or symlinks into the main checkout (`.venv`, `node_modules`, build caches) ignored by Git. On Windows, `git worktree remove` or recursive deletes can follow junctions and wipe targets in the main checkout. Before removing any worktree:

1. List every reparse point / link pointing outside the worktree:
   - Windows PowerShell: `Get-ChildItem -LiteralPath <worktree> -Recurse -Force -Attributes ReparsePoint`
   - macOS/Linux: `find <worktree> -type l`
2. Remove **only the link itself**, never its contents (`cmd /c rmdir "<link>"` for Windows junctions, `rm "<link>"` for symlinks). Re-list and confirm zero remain.
3. Run `git worktree remove <worktree>` **without `--force`**.
4. Verify the main checkout is intact (`git status` shows no unexpected deletions and linked target directories retain their contents).

If any link cannot be removed or cleanup fails, stop immediately and report `merged; cleanup pending` — never retry the merge.
