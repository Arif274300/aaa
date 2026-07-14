#!/bin/bash
cd "$(dirname "$0")"

if [ -f .env ]; then
    source .env
fi

while true; do
  clear
  
  # --- ROTATE GEMINI ---
  [ ! -f .gemini_idx ] && echo 0 > .gemini_idx
  G_IDX=$(cat .gemini_idx)
  var_g="GEMINI_$G_IDX"
  CURRENT_G_KEY="${!var_g}"
  echo $(( (G_IDX + 1) % 5 )) > .gemini_idx

  # --- ROTATE OPENROUTER ---
  [ ! -f .or_idx ] && echo 0 > .or_idx
  OR_IDX=$(cat .or_idx)
  var_or="OR_$OR_IDX"
  CURRENT_OR_KEY="${!var_or}"
  echo $(( (OR_IDX + 1) % 6 )) > .or_idx

  # Global Key Mapping Setup
  export GOOGLE_GENERATIVE_AI_API_KEY="$CURRENT_G_KEY"
  export GEMINI_API_KEY="$CURRENT_G_KEY"
  export GOOGLE_API_KEY="$CURRENT_G_KEY"
  export OPENROUTER_API_KEY="$CURRENT_OR_KEY"
  export OPENAI_API_KEY="$CURRENT_OR_KEY"

  echo "----------------------------------------"
  echo " Engine: Gemini (Primary) -> OpenRouter (Backup)"
  echo " Auto-Rotating Active Production Keys Safely..."
  echo "----------------------------------------"
  
  # Run using the verified native model format from your search list
  opencode --model gemini/gemini-flash-latest --auto

  # Dynamic Fallback: Swaps seamlessly if the key runs out of quota limits
  if [ $? -ne 0 ]; then
      echo "⚠️ Gemini limit encountered! Deploying OpenRouter fallbacks instantly..."
      sleep 2
      opencode --model openrouter/openrouter/free --auto
  fi

  # Cloud Repository Sync Update
  echo "💾 Syncing application files to GitHub repository..."
  git add .
  git commit -m "Auto-save codebase progress check"
  git push origin main 2>/dev/null
  
  echo "🔄 Press [ENTER] to rotate keys, or Ctrl+C to exit."
  read tmp
done
