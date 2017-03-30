function r = is_octave()
%
% result = is_octave()
%
% Return true if the script is running in octave.
%
r = exist('OCTAVE_VERSION','builtin');

