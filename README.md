Gemify, the gemspec generator
=============================

Overview
--------

Gemify is a simple tool which helps you generate gemspecs (which are
used for building gems) and verify that your project follows the common
and proven way to structure your Ruby packages.

Getting started
---------------

Generating gemspec:

    $ gem install gemify
    $ cd myproject (which doesn't have a gemspec yet)
    $ gemify
    Gemify needs to know a bit about your project, but should be
    able to guess most of the information. Type the value if you
    need to correct it, or press ENTER to accept the suggestion by Gemify.

    Project name:        gemify? 
    Namespace:           Gemify? 
    Library:             lib/gemify? 

    *** Verifying the structure of lib/
    [+] Please consider to define Gemify::VERSION in lib/gemify/version.rb
    [.] Done

    *** Verifying the structure of bin/
    [.] Done

    *** Verifying the structure of ext/
    [.] Done

    *** Generating a gemspec
    [.] Done

    Please open gemify.gemspec in your text editor and fill out the details.

    You should fix any warnings that was reported above. You won't need to
    generate a new gemspec after you've fixed them.

    You must also define Gemify::VERSION in lib/gemify/version.rb.
    Gemify has automatically created the file for you, so simply
    open it in your text editor and fill in the current version.
    
Or if you just want to verify it:

    $ gemify -v

### Build and share a gem

Let's not reinvent the wheel, shall we?

    $ gem build foo.gemspec
    $ gem push foo.gem


Acknowledgements
----------------

Thanks to [Pat Nakajima](http://patnakajima.com/) for reminding me that
Gemify still has its uses.


Contributors
------------

* David A. Cuadrado
* Ben Wyrosdick
* Chris Wanstrath
* Pat Nakajima
* Vincent Landgraf

