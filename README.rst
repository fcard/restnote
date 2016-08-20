********
RestNote
********

A GUI that makes editing easier for notebooks intended to be converted to reStructuredText.

Currently it only allows previewing (with restview_) and compiling.

Installation
============

.. code:: bash
  
  $ git clone https://github.com/fcard/restnote
  $ cd restnote
  $ ./deps.sh # install dependencies and prepare ~/.restnote

Then you can run it with

.. code:: bash

  $ ./restnote.sh
  
  
Dependencies
============

 - restview_
 - jupyter_
 - NW.js_

If you don't have those the :code:`deps.sh` script can download and install them locally on :code:`~/.restnote/`.
It will also try to download and build any dependency of these that you don't have (e.g. pip3, nodejs, it will tell you those it can't find and might install if needed).
If you have restview/jupyter or any of their dependencies installed locally you should make their binaries
visible in PATH before calling :code:`deps.sh` to avoid downloading/building them again.

.. _restview: https://github.com/mgedmin/restview
.. _jupyter: http://jupyter.org/
.. _NW.js: https://nwjs.io/
