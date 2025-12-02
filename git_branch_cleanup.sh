#!/bin/bash
##############################################################################
# Git Branch Cleanup Guide
##############################################################################

echo "Current Situation:"
echo "  • You have both 'master' and 'main' branches"
echo "  • GitHub has 'master' set as the default branch"
echo "  • You want to keep only 'main'"
echo ""
echo "Solution: Follow these steps"
echo ""

cat << 'EOF'
STEP 1: Change Default Branch on GitHub (MUST DO FIRST)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Go to: https://github.com/Manoj-Kumar-BV/DTSLBF-MPI
2. Click on "Settings" tab (top right)
3. In the left sidebar, click "Branches"
4. Under "Default branch", click the switch icon (⇄)
5. Select "main" from the dropdown
6. Click "Update"
7. Confirm by clicking "I understand, update the default branch"

✓ This MUST be done before you can delete the master branch


STEP 2: Delete Remote 'master' Branch (After Step 1)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Run this command:

    git push origin --delete master


STEP 3: Delete Local 'master' Branch (Optional)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If you have a local 'master' branch:

    git branch -d master


STEP 4: Clean Up Remote References
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    git fetch --prune
    git remote prune origin


VERIFY: Check Final State
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    git branch -a

Should show only:
  * main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main

✓ Done! You now have only 'main' branch.
EOF
