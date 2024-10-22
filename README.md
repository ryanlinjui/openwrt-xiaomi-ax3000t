# Xiaomi AX3000T Router Flash to OpenWrt Tutorial
> Warning! Don't brick your router!

### Requirement
- [x] OpenSSH Client (`ssh`, `scp` command)
- [x] curl
- [x] Xiaomi System Firmware 1.0.47
- [x] Model RD03: Chinese version

### Reference
- [OpenWrt](https://openwrt.org/inbox/toh/xiaomi/ax3000t)

# Flash to OpenWrt

### Linux, MacOS
```bash
bash flash.sh <your stok string>
```

# Recover to Xiaomi System

### Linux, MacOS
```bash
bash recover.sh
```

# Before flash starting. Get `stok` from your router manage website.

### 1. Choose DCHP mode (or any mode as you want).
<img src="https://github.com/user-attachments/assets/78c48094-1e27-4902-a39b-a02ae44635c7" width="70%">  

### 2. Enter password and Press next step.
<img src="https://github.com/user-attachments/assets/c454801d-f21d-490d-9d10-d83a36649fdb" width="70%">  

### 3. Go 192.168.31.1 and Input password as you at the step 2.
<img src="https://github.com/user-attachments/assets/f1e4c6ec-066f-4620-9819-5600a4d3ab18" width="70%">

### 4. Look for URL on your top of browser. Copy and get your stok string.
<img src="https://github.com/user-attachments/assets/909e9b08-3a65-40d0-89d7-6becc9786875" width="70%">
