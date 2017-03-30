function m = readcsvmat( filename )
%READCSV
%   Reads data matrix from a CSV data file with dimensions row x col.
%   Detect separating character automatically by counting in a line
%
%   Syntax: m=readcsv( filename ) 
%
%   Inputs:
%     filename	-	name of the data file in CSV format
%
%   Outputs:
%     m		-	row x col data matrix

f = fopen(filename,'rt');
if f==-1
	fprintf('Cannot open file ''%s''\n', filename);
	m = [];
	return
end
% count number of lines
k = 0;
sepchardetected = false;
numtabs = 0; numblanks = 0; numcomma = 0; numsemicolon = 0;
while ~feof(f)
	l = fgetl(f);	% don't call it 'line', since this overwrites the function 'line'
	%fprintf('Line #%4d = ''%s''\n', k+1, l );

	if ~sepchardetected && k > 0
		%fprintf('Line #%4d = ''%s'' numtabs=%d numblanks=%d numsemicolon=%d\n',...
		%	k+1, l, numtabs, numblanks, numsemicolon );
		numtabs = length(find(l==char(9)));
		numblanks = length(find(l==' '));
		numcomma = length(find(l==','));
		numsemicolon = length(find(l==';'));
		sepchardetected = true;
	end
	k = k + 1;
end
fclose(f);
row = k;

f = fopen(filename,'rt');

%[maxval,maxpos] = max([numtabs numblanks numcomma numsemicolon]);
sepchars = [char(9) ',' ';'];
[maxval,maxpos] = max([numtabs numcomma numsemicolon]);

col = maxval;
sepchar = sepchars(maxpos);

m = zeros(row,col);

k = 1;
while ~feof(f)
	l = fgetl(f);	% don't call it 'line', since this overwrites the function 'line'
	cols = strsplit(l,sepchar);
	for j=1:col
		%fprintf('Line #%4d j=%d cols(%d)=%f\n', k+1, j, j, str2double(cols(j)) );
		m(k,j) = str2double(cols(j));
	end
	k = k + 1;
end
fclose(f);

%return

end
