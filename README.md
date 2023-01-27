param_fitter
====================

param_fitter is an object-oriented Matlab toolbox for fitting
parameters of Hodgkin-Huxley type ion channel and neuron model
parameters. It achieves this by simulating model ODEs and calculating
differences to an observed waveform output. It can simulate any ODE or
simple functions as well. 

Prerequisites
--------------------

- [Pandora Toolbox](https://github.com/cengique/pandora-matlab)

Installation:
--------------------

Use the addpath Matlab command to add the pandora/ subdirectory to the
Matlab search path. For example: 

```matlab
>> addpath my/download/dir/param_fitter-x.y.z/param_fitter
```

To avoid doing this every time you start Matlab in Windows, use the
'File->Set path' menu option and add the pandora/ directory to the
search path. Or, create a startup.m file in the '$HOME/matlab'
directory in In UNIX/Linux and 'My Documents/MATLAB' directory in
Windows with the above addpath command inside.

Documentation:
--------------------

See the embedded documentation that comes with each file using the
Matlab help browser.

Copyright:
--------------------

Copyright (c) 2010-23 Cengiz Gunay <cengique@users.sf.net>.
This work is licensed under the Academic Free License ("AFL")
v. 3.0. To view a copy of this license, please look at the COPYING
file distributed with this software or visit
http://opensource.org/licenses/afl-3.0.txt.
