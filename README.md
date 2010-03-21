Gemify, the lightweight gemspec editor
======================================

Overview
--------

Gemify is a simple tool which helps you create and manage your gemspecs.
Instead of messing with Rakefiles and adding yet another development
dependency (like Hoe, Echoe and Jeweler), Gemify takes a much less obtrusive
approach.

Gemify works directly on the .gemspec file. In fact, when you're using Gemify,
you're only using it as an editor. If you want, you could just edit the file
manually.

Getting started
---------------

    $ gem install gemify
    $ cd myproject (might already have a gemspec)
    $ gemify
    Currently editing gemify.gemspec

    Which task would you like to invoke?
    1) Change name (required) = gemify
    2) Change summary (required) = The lightweight gemspec editor
    3) Change version (required) = 0.3
    4) Change author = Magnus Holm
    5) Change email = judofyr@gmail.com
    6) Change homepage = http://dojo.rubyforge.org/
    7) Set dependencies

    s) Save
    r) Reload (discard unsaved changes)
    m) Rename
    l) List files

    x) Exit

    > 

### Manifest

Gemify helps you manage the manifest (files which will be included in the gem). It follows these rules:

* If there's a file called **MANIFEST**, **Manifest.txt** or **.manifest**, it
  assumes this files contains a line-separated list of the manifest.

* If not, it checks if you're using Git, Mercurial, Darcs, Bazaar, Subversion
  or CVS and uses the commited files.

* If not, it just includes all the files.

You can always run `gemify -m` to see the manifest, and if you don't like what
you see you should maintain a manifest file yourself. Every time you open
Gemify and save, it will update the manifest. You can also call `gemify -u`.

### Dependencies

When you set dependencies, you can separate the version requirement by a
comma:

    $ gemify
    ...
    > 7
    Split by ENTER and press ENTER twice when you're done
    > nokogiri
    > rack, >= 1.0  

### Build and share a gem

Let's not reinvent the wheel, shall we?

    $ gem build foo.gemspec
    $ gem push foo.gem


Acknowledgements
----------------

Thanks to [Pat Nakajima](http://patnakajima.com/) for reminding me that Gemify
still has its uses.


Contributors
------------

* David A. Cuadrado
* Ben Wyrosdick
* Chris Wanstrath
* Pat Nakajima
