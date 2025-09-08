#!/bin/bash

# Cache directory
CACHE_DIR="$HOME/.cache/waybar/crypto-rates"
mkdir -p "$CACHE_DIR"

# Command line parameters processing
while getopts "c:r:" opt; do
  case $opt in
  c)
    COIN=$(echo "$OPTARG" | tr '[:lower:]' '[:upper:]') # Convert to uppercase
    ;;
  r)
    if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
      ROUND=$OPTARG
    else
      echo "Error: Round parameter must be a positive number"
      exit 1
    fi
    ;;
  \?)
    echo "Usage: $0 [-c COIN] [-r ROUND]"
    echo "Example: $0 -c BTC -r 2"
    exit 1
    ;;
  esac
done

# Get rate from Bybit API
response=$(curl -s "https://api.bybit.com/v5/market/tickers?category=spot&symbol=${COIN}USDT")

# Check if there's an error in response
if echo "$response" | jq -e '.retCode != 0' >/dev/null; then
  error_msg=$(echo "$response" | jq -r '.retMsg')
  echo "Error: $error_msg"
  echo "Please check if the coin name is correct (example: BTC, ETH, SOL)"
  exit 1
fi

# Cache file
PRICE_FILE="$CACHE_DIR/$COIN-rate"

# Get price and 24h change
CURRENT_PRICE=$(echo "$response" | jq -r '.result.list[0].lastPrice')
PRICE_CHANGE_24H=$(echo "$response" | jq -r '.result.list[0].price24hPcnt')

# Format 24h change with sign and percentage
FORMATTED_CHANGE=$(printf "%+.2f%%" "$(echo "$PRICE_CHANGE_24H * 100" | bc -l)")

if [ -f "$PRICE_FILE" ]; then
  PREVIOUS_PRICE=$(cat "$PRICE_FILE")
  if awk -v curr="$CURRENT_PRICE" -v prev="$PREVIOUS_PRICE" 'BEGIN { exit !(curr > prev) }'; then
    CLASS="rate-up"
    ICON="up"
  elif awk -v curr="$CURRENT_PRICE" -v prev="$PREVIOUS_PRICE" 'BEGIN { exit !(curr < prev) }'; then
    CLASS="rate-down"
    ICON="down"
  else
    CLASS="rate-same"
    ICON="same"
  fi
else
  CLASS="rate-same"
  ICON="same"
fi

# Это условие можно убрать, тогда каждое обновление будет считаться зеленая цена или красная
# Set icon based on 24h price change
if (($(echo "$PRICE_CHANGE_24H > 0" | bc -l))); then
  CLASS="rate-up"
  ICON="up"
else
  CLASS="rate-down"
  ICON="down"
fi

# Save current price to cache file
echo "$CURRENT_PRICE" >"$PRICE_FILE"

# Format price for better output with specified decimal places
FORMATTED_PRICE=\$$(printf "%'.*f" $ROUND $CURRENT_PRICE)

# Combine price and 24h change in the output
echo "{\"text\": \"$FORMATTED_PRICE ($FORMATTED_CHANGE)\", \"class\": \"$CLASS\", \"alt\": \"$ICON\"}"
