param(
    [switch]$AutoApplyStash
)

function Get-CurrentBranch {
    $b = git rev-parse --abbrev-ref HEAD 2>$null
    return $b.Trim()
}

$frontBranch = Get-CurrentBranch
Write-Output "Front branch: $frontBranch"

$targetBranch = if ($frontBranch -and $frontBranch -ne '') { $frontBranch } else { 'main' }
Write-Output "Syncing backend to branch: $targetBranch"

# Check for local changes in backend
$backendStatus = git -C backend-repo status --porcelain 2>$null
if ($backendStatus) {
    Write-Output "Backend has local changes. Saving stash..."
    git -C backend-repo stash push -u -m "autostash before pull $targetBranch" | Out-Null
}

Write-Output "Fetching origin in backend..."
git -C backend-repo fetch origin --prune

# If the branch exists on origin, try to checkout and fast-forward pull
$remoteExists = git -C backend-repo ls-remote --heads origin $targetBranch
if ($remoteExists) {
    Write-Output "Checking out $targetBranch in backend and pulling..."
    & git -C backend-repo checkout -B $targetBranch origin/$targetBranch 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Checkout from origin failed, creating/forcing local $targetBranch"
        git -C backend-repo checkout -B $targetBranch
    }
    git -C backend-repo pull --ff-only origin $targetBranch
}
else {
    Write-Output "Branch $targetBranch not found on backend origin. Falling back to main."
    & git -C backend-repo checkout main 2>$null
    if ($LASTEXITCODE -ne 0) {
        git -C backend-repo checkout -B main
    }
    git -C backend-repo pull --ff-only origin main
}

Write-Output "Ultimo commit no backend:" 
git -C backend-repo log -1 --oneline

Write-Output "Backend sync complete."
