#!/bin/bash
cd "$(dirname "$0")"

[ -f .env ] && source .env

while true; do
  clear
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

  export GOOGLE_GENERATIVE_AI_API_KEY="$CURRENT_G_KEY"
  export GEMINI_API_KEY="$CURRENT_G_KEY"
  export GOOGLE_API_KEY="$CURRENT_G_KEY"
  export OPENROUTER_API_KEY="$CURRENT_OR_KEY"
  export OPENAI_API_KEY="$CURRENT_OR_KEY"

  echo "----------------------------------------"
  echo " Workspace Path: ~/aaa | Keys Auto-Rotating"
  echo "----------------------------------------"
  
  opencode --model gemini/gemini-3.5-flash --auto

  if [ $? -ne 0 ]; then
      echo "⚠️ Gemini limit reached. Shifting over to OpenRouter backup..."
      sleep 2
      opencode --model openrouter/openrouter/free --auto
  fi

  echo "💾 Syncing changes smoothly up to GitHub repository..."
  git add .
  git commit -m "Auto-save payload update"
  git push origin main 2>/dev/null
  
  echo "🔄 Press [ENTER] to rotate keys, or Ctrl+C to exit."
  read tmp
done
