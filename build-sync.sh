#!/bin/bash
cd "$(dirname "$0")"

# 1. Fetch any remote updates first
git pull origin main 2>/dev/null

# 2. Inject environment keys from your hidden .env profile
if [ -f .env ]; then
    source .env
fi

# Rotate keys cleanly for the active background runtime session
[ ! -f .gemini_idx ] && echo 0 > .gemini_idx
G_IDX=$(cat .gemini_idx)
var_g="GEMINI_$G_IDX"
export GEMINI_API_KEY="${!var_g}"
echo $(( (G_IDX + 1) % 5 )) > .gemini_idx

[ ! -f .or_idx ] && echo 0 > .or_idx
OR_IDX=$(cat .or_idx)
var_or="OR_$OR_IDX"
export OPENROUTER_API_KEY="${!var_or}"
echo $(( (OR_IDX + 1) % 6 )) > .or_idx

# 3. Fire OpenCode directly to handle the build task execution
opencode --auto

# 4. Instantly push all build output up to the GitHub repository backup
git add .
git commit -m "Automated cloud build update"
git push origin main 2>/dev/null
