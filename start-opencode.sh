#!/bin/bash
cd "$(dirname "$0")"

# Load variables securely from hidden configuration file
if [ -f .env ]; then
    source .env
fi

while true; do
  clear
  
  # --- POOL 1: ROTATE GEMINI KEYS ---
  [ ! -f .gemini_idx ] && echo 0 > .gemini_idx
  G_IDX=$(cat .gemini_idx)
  var_g="GEMINI_$G_IDX"
  CURRENT_G_KEY="${!var_g}"
  echo $(( (G_IDX + 1) % 5 )) > .gemini_idx

  # --- POOL 2: ROTATE OPENROUTER KEYS ---
  [ ! -f .or_idx ] && echo 0 > .or_idx
  OR_IDX=$(cat .or_idx)
  var_or="OR_$OR_IDX"
  CURRENT_OR_KEY="${!var_or}"
  echo $(( (OR_IDX + 1) % 6 )) > .or_idx

  # Export both groups into the background environment
  export GOOGLE_GENERATIVE_AI_API_KEY="$CURRENT_G_KEY"
  export GEMINI_API_KEY="$CURRENT_G_KEY"
  export GOOGLE_API_KEY="$CURRENT_G_KEY"
  export OPENROUTER_API_KEY="$CURRENT_OR_KEY"
  export OPENAI_API_KEY="$CURRENT_OR_KEY"

  echo "----------------------------------------"
  echo " Workspace Path: ~/aaa | Manual Model Choice Mode"
  echo " Current Gemini Key: #$G_IDX | OpenRouter Key: #$OR_IDX"
  echo "----------------------------------------"
  echo "Launching OpenCode interface..."
  sleep 1
  
  # Launch OpenCode smoothly with no forced settings
  opencode --auto

  # Codespace Backup Sync Action
  echo "💾 Syncing changes to GitHub repository..."
  git add .
  git commit -m "Codebase dynamic update sync"
  git push origin main 2>/dev/null
  
  echo "🔄 Press [ENTER] to rotate keys and restart, or Ctrl+C to exit."
  read tmp
done
