dreamhostrails
==============

Template for deploy Ruby on Rails applications on the shared web servers at Dreamhost

Important
==========

1.  Dreamhost allows to use Rails 3.0.3 strictly on their shared servers.
2.  You must change the username on the config.ru and config/environment.rb files for your dreamhost username
3.  Your dreamhost username must be ssh enabled

How to Use
===========
You can make a clone and apply the template locally:<br> 
`rails new <appname> -d mysql -m <path/to/dremahostrails.rb>`<br>

Or you can create a new rails app aplying the template directly from github:<br>
`rails new <appname> -d mysql -m https://raw.github.com/paulsutcliffe/dreamhostrails/master/dreamhostrails.rb`<br>