#!/bin/bash
if [ `hostname` == "hestia" ]; then
  /export/fassis/MATLAB/MATLAB_Production_Server/R2015a/bin/matlab -nodisplay 
fi
if [ `hostname` == "ares" ]; then
  /export/thomas/usr/local/MATLAB/MATLAB_Production_Server/R2015a/bin/matlab -nodisplay
fi
if [ `hostname` == "francisco-dv5000" ]; then
  octave
fi
