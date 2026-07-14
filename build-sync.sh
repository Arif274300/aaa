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
CURRENT_G_KEY="${!var_g}"
echo $(( (G_IDX + 1) % 5 )) > .gemini_idx

[ ! -f .or_idx ] && echo 0 > .or_idx
OR_IDX=$(cat .or_idx)
var_or="OR_$OR_IDX"
CURRENT_OR_KEY="${!var_or}"
echo $(( (OR_IDX + 1) % 6 )) > .or_idx

# Map the exact naming requirements expected by the Google GenAI SDK
export GOOGLE_GENERATIVE_AI_API_KEY="$CURRENT_G_KEY"
export GEMINI_API_KEY="$CURRENT_G_KEY"
export GOOGLE_API_KEY="$CURRENT_G_KEY"
export OPENROUTER_API_KEY="$CURRENT_OR_KEY"
export OPENAI_API_KEY="$CURRENT_OR_KEY"

# 2. Run OpenCode with the correct environment variables active
opencode --auto

# 3. Automatically commit and push tracking changes up to your private GitHub backup
git add .
git commit -m "Automated cloud build update sync"
git push origin main 2>/dev/null
