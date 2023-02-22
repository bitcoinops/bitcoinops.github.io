
[TOC]

- Deploy docker document https://docs.docker.com/desktop/

## Building The Site Locally By Docker

1. Define the absolute parent path of repository bitcoinops.github.io .
    ```bash
    repath=~/git/project/
    ```

2. Create the parent folder and go into the parent folder.
    ```bash
    mkdir -p ${repath}
    cd ${repath}
    ```

3. Download the repository bitcoinops.github.io .
    ```bash
    git clone https://github.com/bitcoinops/bitcoinops.github.io
    ```

4. Building the site.
    ```bash
    # Some of the dependencies can take a long time to install on some systems, so be patient.
    docker run -d --name bitcoinops -p 4000:4000 -v ${repath}/bitcoinops.github.io:/root/bitcoinops.github.io -w /root/bitcoinops.github.io ruby:2.6.4-stretch /bin/bash -c "bundle install && make preview"
    ```

5. Check whether building the site success.
    ```bash
    # Output the bitcoinops container log
    docker logs -f bitcoinops
    ```

6. The bitcoinops container prints a log like this if building the site success.
    ```log
            Server address: http://0.0.0.0:4000/
        Server running... press ctrl-c to stop.
    ```

6. Visit URL 127.0.0.1:4000 in your browser to view the site.

7. Edit files and save files, then refresh the site in a browser, the site will show the newest content.