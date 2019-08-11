# bitcoinops.github.io
The Bitcoin Operations Technology Group (Optech) works to bring the best
open source technologies and techniques to Bitcoin-using businesses in
order to lower costs and improve customer experiences.

An initial focus for the group is working with its member organizations to
reduce transaction sizes and minimize the effect of subsequent transaction fee
increases.

Long-term goals include providing documentation and training materials, a
weekly newsletter, original research, and facilitating improved relations
between businesses and the open source community.

Optech does not exist to make a profit, and all materials and documentation
produced are placed in the public domain. We are supported by our generous
founding sponsors and contributions from member companies.

If you're an engineer or manager at a Bitcoin company or an open source contributor and you'd like to be a part of this, please
contact us at [info@bitcoinops.org](mailto:info@bitcoinops.org).

## Building The Site Locally

To build the site, you need to go through a one-time installation
procedure that takes 15 to 30 minutes.  After that you can build the
site an unlimited number of times with no extra work.

##### Install The Dependencies

**Install RVM**

Install RVM using either the [easy instructions](https://rvm.io/) or the
[more secure instructions](https://rvm.io/rvm/security).

Read the instructions printed to your console during setup to enable the
`rvm` command in your shell.  After installation, you need to run the
following command:

    source ~/.rvm/scripts/rvm

**Install Ruby 2.5.1**

To install Ruby 2.5.1, simply run this command:

    rvm install 2.5.1

Sometimes this will find a pre-compiled Ruby package for your Linux
distribution, but sometimes it will need to compile Ruby from scratch
(which takes about 15 minutes).

After Ruby 2.5.1 is installed, make it your default Ruby:

    rvm alias create default ruby-2.5.1

And tell your system to use it:

    rvm use default

(Note: you can use a different default Ruby, but if you ever change
your default Ruby, you must re-run the `gem install bundle` command
described below before you can build the site. If you ever receive a
"eval: bundle: not found" error, you failed to re-run `gem install
bundle`.)

**Install Bundle**

When you used RVM to install Ruby, it also installed the `gem` program.
Use that program to install bundle:

    gem install bundle

**Install the Ruby dependencies**

Change directory to the top-level of your local repository (replace
`bitcoinops.github.io` with the full path to your local repository clone):

    cd bitcoinops.github.io

And install the necessary dependencies using Bundle:

    bundle install

Some of the dependencies can take a long time to install on some systems, so be
patient.

Once Bundle completes successfully, you can preview or build the site.

##### Preview The Site

To preview the website in your local browser, make sure you're in the
`bitcoinops.github.io` directory and run the following command:

    make preview

This will build the site and then print a message like this:

    Server address: http://0.0.0.0:4000
    Server running... press ctrl-c to stop.

Visit the indicated URL in your browser to view the site.

##### Build The Site

To build the site exactly like we do for the deployment server, make
sure you're in the `bitcoinops.github.io` directory and run:

    make

The resulting HTML for the entire site will be placed in the `_site`
directory.  The following alternative options are available:

    ## After you build the site, you can run all of the tests (may take awhile)
    make test

## Contributing

If you would like to contribute to the Bitcoin Optech project, please review the
[contributing guidelines](CONTRIBUTING.md).