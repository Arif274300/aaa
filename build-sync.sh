#!/bin/bash
cd "$(dirname "$0")"

# 1. Sync remote updates from your backup
git pull origin main 2>/dev/null

if [ -f .env ]; then
    source .env
fi

# Rotate keys cleanly for this session
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

# 2. Rebuild the visual knowledge graph map for your AI assistant
echo "📊 Reindexing workspace architectural mapping data..."
graphify build . 2>/dev/null

# 3. Fire OpenCode directly to handle your build instructions
opencode --auto

# 4. Push code changes alongside the updated graph structures to GitHub
git add .
git commit -m "Automated cloud build & graph update sync"
git push origin main 2>/dev/null
