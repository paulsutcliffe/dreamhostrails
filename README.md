dreamhostrails
==============

Template for deploy Ruby on Rails applications on the shared web servers at Dreamhost

Important
==========

1.  Dreamhost allows to use Rails 3.0.3 strictly on their shared servers.
2.  Your dreamhost username must be ssh enabled
3.  Dreamhost create a public directory automatically, YOU MUST REMOVE this directory via ssh, to let Capistrano do the job. I recommend  `rm -rf directoryname` where directoryname is autocreated by dreamhost after setup a new domain or subdomain on their panel.
4.  You should fill your Capistrano setup (config/deploy.rb) with your info.

How to Use
===========

Even though Dreamhost guys tells you that you can't deploy your rails app with Passenger on shared servers and the only way is with FastCGI, that has known bugs with rails. Thanks to `https://github.com/jgeiger`, now you have to make some dirty stuff to get your rails app working smooth with Phussion Passenger. Awesome.<br>

The full article is here: `http://blog.joeygeiger.com/2010/05/17/i-beat-dreamhost-how-to-really-get-rails-3-bundler-and-dreamhost-working/`<br>

But if you are lazy or desperate, you can just do the following:<br>

Add this to your .bashrc:

    export PATH=$HOME/.gems/bin:$HOME/opt/bin:$PATH
    export GEM_HOME=$HOME/.gems
    export GEM_PATH="$GEM_HOME"
    export RUBYLIB="$HOME/opt/lib:$RUBYLIB"

    alias gem="nice -n19 ~/opt/bin/gem"

This will setup your shell to use local gems installed in your .gems directory, setup the path to check there first and opt/bin as well. Next we need to install a newer version of rubygems:

    mkdir ~/src
    mkdir ~/opt
    cd src
    wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
    tar xvfz rubygems-1.3.7.tgz
    cd rubygems-1.3.7
    ruby setup.rb --prefix=$HOME/opt
    cd ~/opt/bin/
    ln -s gem1.8 gem
    gem update --system
    gem install bundler
    gem install rake`<br>

You can make a clone and apply the template locally:<br>
`rails new <appname> -d mysql -m <path/to/dremahostrails.rb>`<br>

Or you can create a new rails app aplying the template directly from github:<br>
`rails new <appname> -d mysql -m https://raw.github.com/paulsutcliffe/dreamhostrails/master/dreamhostrails.rb`<br>

Contact
=======

Don't hesitate contact me paul@kosmyka.com
