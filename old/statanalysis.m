is_octave = exist('octave_config_info','builtin'); % Octave or Matlab
if( is_octave )
	% Do Octave stuff
else
	% Do Matlab stuff
end

datadir = './NEW_DATA/';

classifiers = {'KNNRBF^{*}'; 'KNNRBF-2^{*}'; 'ELM'; 'ELM^{*}'; 'KNN'; 'KNN^{*}'; 'SVM'; 'SVM^{*}'; 'DT'; 'DT^{*}' ; 'RF'; 'RF^{*}'}
performancefiles = {
	'modelnr_m1_norm_2_data_ufes_filtro.csv',
	'modelnr_m2_norm_2_data_ufes_filtro.csv',
	'modelnr_0_norm_0_data_ufes_filtro.csv',
	'modelnr_0_norm_2_data_ufes_filtro.csv',
	'modelnr_1_norm_0_data_ufes_filtro.csv',
	'modelnr_1_norm_2_data_ufes_filtro.csv',
	'modelnr_2_norm_0_data_ufes_filtro.csv',
	'modelnr_2_norm_2_data_ufes_filtro.csv',
 	'modelnr_3_norm_0_data_ufes_filtro.csv',
 	'modelnr_3_norm_2_data_ufes_filtro.csv',
 	'modelnr_4_norm_0_data_ufes_filtro.csv',
 	'modelnr_4_norm_2_data_ufes_filtro.csv',
% 	'modelnr_5_norm_0_data_ufes_filtro.csv',
% 	'modelnr_5_norm_2_data_ufes_filtro.csv',
};

numfiles = size(performancefiles,1);

boxplotmat = [];
boxplotstats = [];
for i=1:numfiles
	fn = [datadir performancefiles{i}];
	m = readcsvmat(fn);
	x = m(:)';
	if is_octave
		boxplotstats = [boxplotstats ; [min(x) max(x) quantile(x',[.25 .5 .75])' mean(x)]];
	else
		boxplotstats = [boxplotstats ; [min(x) max(x) quantile(x,[.25 .5 .75]) mean(x)]];
	end
	boxplotmat = [boxplotmat; x];
end


fprintf('%10s%10s%10s%10s%10s%10s\n', 'min', 'max', 'q25', 'q50', 'q75', 'mean' );
boxplotstats
h = figure;
boxplot(boxplotmat');

fontsize = 8;
hax = gca; % Current axis object
xtick = get(hax,'XTick');
numxticks = size(xtick,2);
set(hax,'xticklabel',[]); % clear x axis labels
for i=1:numxticks
	txtick = text( xtick(i), 0.42, classifiers{i} ,'FontSize',fontsize );
        set(txtick, 'HorizontalAlignment','center','VerticalAlignment','middle')
end
%xlabel('Classifier');
ylabel('F-measure');




% Dump colored encapsulated PostScript
FIGWIDTHCM = 8.89;
FIGHEIGHTCM = 4.4;
aspectfig = FIGWIDTHCM/FIGHEIGHTCM;
%h = figure;
figdir = './';

figwidthcm = FIGWIDTHCM;	% 3.5 inch = 252.0pt In LaTeX visualize with: \typeout{####### The column width is \the\columnwidth}
figheightcm = FIGHEIGHTCM;
%figheightcm = figwidthcm;
cm2inch = 2.54;
inch2points = 72.0;
cm2points = inch2points/cm2inch;
if( ~is_octave )
    paddingMarginPoints = 18;
    paddingMarginPoints = 12;
    cm2points = cm2points + paddingMarginPoints;
end
% In the 'print' driver an explicit use of 'points' is done. So use a priori this units
figwidth = figwidthcm * cm2points;
figheight = figheightcm * cm2points;
set(h,'Resize','off');
set(h,'PaperUnits','points');
set(h,'Position',[0 0 figwidth figheight]);
set(h,'PaperSize',[figwidth figheight]);
set(h,'PaperPosition',[0 0 figwidth figheight]);
set(h,'PaperPositionMode','auto');
set(h,'Clipping','off');
print([figdir 'boxplot'], '-depsc2');
%fprintf('<Enter> to close ...\n'); pause;
%close(h);

