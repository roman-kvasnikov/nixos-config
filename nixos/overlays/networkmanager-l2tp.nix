(self: super: {
  networkmanager-l2tp = super.networkmanager-l2tp.override {
    strongswan = self.libreswan;
  };
})
