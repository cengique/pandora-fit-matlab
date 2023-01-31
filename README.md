pan_fit - Pandora Matlab toolbox module for fitting neuronal models
=======================================================================

pan_fit is an object-oriented Matlab toolbox for fitting
parameters of Hodgkin-Huxley type ion channel and neuron model
parameters. It achieves this by simulating model ODEs and calculating
differences to an observed waveform output. It can simulate any ODE or
simple functions as well. 

[![View pan_fit on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/124050-pan_fit)

Prerequisites
--------------------

- Pandora Toolbox - Get from [Github](https://github.com/cengique/pandora-matlab) or [Mathworks 
  FileExchange](https://www.mathworks.com/matlabcentral/fileexchange/60237-cengique-pandora-matlab)
- Matlab Optimization Toolbox is used by default, but other methods
  can be substituted

Installation:
--------------------

Use the addpath Matlab command to add the pandora/ subdirectory to the
Matlab search path. For example: 

```matlab
>> addpath my/download/dir/pandora-fit-matlab-x.y.z/pan_fit
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
