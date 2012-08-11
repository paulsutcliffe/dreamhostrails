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
You can make a clone and apply the template locally:<br> 
`rails new <appname> -d mysql -m <path/to/dremahostrails.rb>`<br>

Or you can create a new rails app aplying the template directly from github:<br>
`rails new <appname> -d mysql -m https://raw.github.com/paulsutcliffe/dreamhostrails/master/dreamhostrails.rb`<br>
	
Contact
=======

Don't hesitate contact me paul@kosmyka.com