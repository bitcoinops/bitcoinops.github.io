
[TOC]

- Deploy docker document https://docs.docker.com/desktop/

# Building The Site Locally By Docker


## Step 1.  Define the absolute parent path of repository bitcoinops.github.io
```bash
repath=~/git/project/
```

## Step 2.  Create the parent folder and go into the parent folder
```bash
mkdir -p ${repath}
cd ${repath}
```

## step 3.  Download the repository bitcoinops.github.io
```bash
git clone https://github.com/bitcoinops/bitcoinops.github.io
```

## Step 4.  Building the site
```bash
# Some of the dependencies can take a long time to install on some systems, so be patient.
docker run -d --name bitcoinops -p 4000:4000 -v ${repath}/bitcoinops.github.io:/root/bitcoinops.github.io -w /root/bitcoinops.github.io ruby:2.6.4-stretch /bin/bash -c "bundle install && make preview"
```

## Step 5.  Check whether building the site success
Output the bitcoinops container log
```bash
docker logs -f bitcoinops
```
The bitcoinops container prints a log like this if building the site success
```log
        Server address: http://0.0.0.0:4000/
    Server running... press ctrl-c to stop.
```

## Step 6.  Open url 127.0.0.1:4000 in browser

## Other
Edit files and save files, then refresh the site in a browser, the site will show the newest content.