---- Does WorMachine cause an error when trying to analyze all your worms? ----

Our WorMachine program requires specific toolboxes to run, which you might not have installed.
Type "ver" in MATLAB's command line, in order to view your installed toolboxes.
Here is a non-comprehensive list of the main toolboxes required by WorMachine:

***Image Processing Toolbox (For Image Processor)
 
***Statistics and Machine Learning Toolbox (For Machine Learner)

***Computer Vision Toolbox (for flourescent analysis)

***Deep Learning Toolbox (for WormNet)

***Parallel Computing Toolbox (for WormNet)

***Curve Fitting Toolbox (for fit.m)
To check if "fit.m" function is available in your installation, type the following command in the matlab command line: which -all fit 
do you see this path anywhere in MATLAB's output?	"...curvefit/fit"
If you DO NOT see this path, then you must install this toolbox.  If you DO see this path then your problem is different. 

If installing all of the above toolboxes did not resolve your issue, please email us with details: adamhakim@mail.tau.ac.il
and attach an "errorlog.txt" file if wormachine produced one for you.


----- HOW TO INSTALL TOOLBOXES IN MATLAB-----
When you install MATLAB, you have the option to customize and choose the toolboxes you want to install. 
Simply tick the checkbox for the desired toolboxes when installing matlab.

If MATLAB is already installed, you can install ONLY specific toolboxes by running the MATLAB installer again, without having to reinstall the entire program.

Start the installer using the downloaded installation file or MATLAB installation exe. 
If prompted for a typical/custom installation, choose the custom option. 
Advance through all the prompts, and click install when the installation path appears.
Matlab will take a few moments to recognize your installation directory, and then present you with a list of possible toolboxes.
Select only the additional desired toolboxes and complete the installation.
For more info:
https://www.researchgate.net/post/How_could_I_add_a_new_toolbox_in_MATLAB 

If there are any further issues, please let us know:
adamhakim@mail.tau.ac.il

Best of luck!