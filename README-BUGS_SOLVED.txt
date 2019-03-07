---- Does WorMachine cause an error when trying to analyze all your worms? ----

Our WorMachine program requires a specific toolbox to run, which many don't seem to install in the latest matlab version:

Curve Fitting Toolbox:
https://www.mathworks.com/products/curvefitting.html 

The required function from this toolbox is:
fit.m
https://www.mathworks.com/help/curvefit/fit.html 

Type the following command in the matlab command line: which -all fit 
do you see this path anywhere in MATLAB's output?
"...curvefit/fit"

If you DO see this path then your problem is different, please email us with your issue: adamhakim@mail.tau.ac.il
and attach an "errorlog.txt" file if wormachine produced one for you.

If you DO NOT see this path, then you must install this toolbox. continue reading for further instructions

----- HOW TO INSTALL -----
When you install MATLAB, you have the option to customize and choose the toolboxes you want to install. 
Simply tick the checkbox “Curve Fitting Toolbox” when installing matlab.

If MATLAB is already installed, there is an option to install only specific toolboxes when running the installer.

Start the installer using the downloaded installation files or MATLAB installation exe. 
When prompted for a typical/custom installation, choose the custom option. 
Select only the additional toolboxes and complete the installation.
For more info:
https://www.researchgate.net/post/How_could_I_add_a_new_toolbox_in_MATLAB 

If there are any further issues, please let us know:
adamhakim@mail.tau.ac.il

Best of luck!