## How to run?
```
brew install clamav
cp /opt/homebrew/etc/clamav/freshclam.conf.sample /opt/homebrew/etc/clamav/freshclam.conf
cp /opt/homebrew/etc/clamav/clamd.conf.sample /opt/homebrew/etc/clamav/clamd.conf
# Comment out Example line from conf
freshscan
npm install
docker compose up
node index.js
```

## Requirements
- At least 2gb ram --> 2048mb cpu, 4096mb ram
