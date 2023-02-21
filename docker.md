
## Building The Site Locally By Docker

```bash
repath=~/git/project/ # The folder path of repository bitcoinops.github.io

cd ${repath}

git clone https://github.com/bitcoinops/bitcoinops.github.io

docker run -d --name bitcoinops -p 4000:4000 -v ${repath}/bitcoinops.github.io:/root/bitcoinops.github.io -w /root/bitcoinops.github.io ruby:2.6.4-stretch /bin/bash -c "bundle install && make preview"

# open url 127.0.0.1:4000 in browser

docker stop bitcoinops
# edit file
docker start bitcoinops
```