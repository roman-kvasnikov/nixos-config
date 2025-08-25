{
  dconf.settings = {
    "org/gnome/shell/extensions/bitcoin-markets" = {
      first-run = false;
      indicators = [
        ''{"api":"bybit","base":"GALA","quote":"USDT","attribute":"last","show_change":true,"format":"{b} {v5} $"}''
        ''{"api":"bybit","base":"ETH","quote":"USDT","attribute":"last","show_change":true,"format":"{b} {v0} $"}''
        ''{"api":"bybit","base":"BTC","quote":"USDT","attribute":"last","show_change":true,"format":"{btc} {v0} $"}''
      ];
    };
  };
}
