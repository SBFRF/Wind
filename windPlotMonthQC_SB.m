%  metPlotMonthQC - reads the monthly vax_10min_Wind_speed_932_198812.mat files 
%   and make wide plots (*W.png).
%  
%  Created 9 May 2014 - Kent Hathaway
%
%	Creates a 2 panel stat plot of wind speeds (mean, gust, sust) and direction
%	Creates a 5 panel stat plot of wind speed, direction, bitFlag (0 or 1), 
%  meanStd & steMean, and stdStd.
%

%Mfile='vax_10min_Wind_speed_932_198810.mat';
%Mfile='2012/12-Dec/wind932/vax_10min_Wind_speed_932_201212.mat';
%Mfile='2010/10-Oct/wind932/vax_10min_Wind_speed_932_201010.mat';
%Mfile='vax_10min_Wind_speed_932_200605.mat';

%%SB load Section
%yearsload=1989:2012;   % year for loaded file
%monthsload=1:12;     % month for loaded file  $$$ loaded at the loops now

% check to see if output directories exist
% if not, create them
if ~exist( 'outputdata/processedMET' , 'dir')  
  mkdir( 'outputdata/processedMET' );
end
if ~exist( 'outputdata/RawStats' , 'dir')  
  mkdir( 'outputdata/RawStats' );
end

gaugeIDs= [932,933; 832,833; 732,733; 632,633];

figOff= 1;   % 1=visible off

width=12;
height=width/1.4;
months = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];
gtype= 'Wind_speed';

for yr=1987:2013
   
    for mon=1:12
        for yy=    1:length(gaugeIDs) 
           IDsp=gaugeIDs(yy,1);
           IDdir=gaugeIDs(yy,2);
           disp('**************new gauge**************')
           disp(sprintf('Gauge ID: %d & DIR:%d',IDsp, IDdir));

        
        Mfile=sprintf( 'outputdata/matFile/vax_10min_%s_%d_%4d%02d.mat' , gtype, IDsp, yr, mon);
        if (~exist('Mfile', 'var'))
        disp '<EE> Do not see input mat-file variable Mfile'
            continue
        end
        if exist(Mfile, 'file')
             disp(sprintf('loading month=%d - year=%d',mon,yr));
             load (Mfile);
        else
             disp(['<EE> Do not see input mat-file: ' Mfile]);
             continue
        end
        
     
    

%###########################################################
%###################  PLOTS  ###############################
%###########################################################

gap=6/24;      % put gap if > 6 hours

% Plot1: 1) wind speeds          ( uses bitFlag to edit bad points 
%        2) direction
% Plot2 QC: 1) wind speed
%           2) direction
%			   3) bitFlag (0 or 1)
%			   4) menaStd and stdMean
%			   5) stdstd

% -------------- Plot 1 --------------------------------

if (figOff == 1)
	f1=figure('visible','off');
else
	f1=figure;
end

set(gcf, 'PaperUnits', 'inches');
set(f1,'PaperSize',[width,height]);
myfiguresize = [0.5, 0.25, width , height-0.75];
%set(gcf, 'PaperPosition', myfiguresize);
 set(gcf, 'PaperPositionMode', 'auto');

% Make an edited copy for plot #1, plot QC=2 and smaller
%, unedited gets plotted in plot #2 
gust=stat10.gust;
sust=stat10.sust;
speed=stat10.speed;
vdir=stat10.vdir;

subplot(211)     %  Wind speeds

bd=find(stat10.qcFlag > 2);
if (~isempty(bd))
	gust(bd) = NaN;
	sust(bd) = NaN;
	speed(bd) = NaN;
	vdir(bd) = NaN;
end
[stG dG]=nanGaps(stat10.time, gust, gap);
plot(stG, dG,'r')
hold on

[stG dG]=nanGaps(stat10.time, speed, gap);
plot(stG, dG,'g')

[stG dG]=nanGaps(stat10.time, sust, gap);
plot(stG, dG,'k')

dateaxis('x',7);
set(gca,'XLim',[floor(stat10.time(1)) ceil(stat10.time(end))+5]);
set(gca,'XMinorGrid','on');
grid
set(gca,'XTickLabel',[]);
ylabel('Speed','FontSize',12);
lh=legend('Gust','Mean','Sust');
set(lh,'FontSize',12);
txt=sprintf('Winds: Gauge=%d, %s \n Polished Output Data', IDsp, stat10.name);
title(txt,'FontSize',14)

subplot(212)      % Dir
[stG dG]=nanGaps(stat10.time, vdir, gap);
plot(stG, dG, 'b')
grid
dateaxis('x',7);
set(gca,'XMinorGrid','on')
set(gca,'XLim',[floor(stat10.time(1)) ceil(stat10.time(end))+5]);
set(gca,'FontSize', 12);
ylabel('Direction (deg N)','FontSize',12);

dv=datevec(stat10.time(1));
xlabel([months(dv(2),:) ' ' num2str(dv(1))],'fontsize',12);

fnamePNG = sprintf('outputdata/processedMET/wind_%d_%d%02d.png', stat10.ID, dv(1), dv(2));
print(f1, '-dpng','-r160', fnamePNG)

% -------------- Plot 2 --------------------------------

gap=6.5/24;      % put gap if > 6.5 hours

if (figOff == 1)
	f2=figure('visible','off');
else
	f2=figure;
end

set(gcf, 'PaperUnits', 'inches');
set(f2,'PaperSize',[width,height]);
myfiguresize = [0.5, 0.25, width , height-0.75];
%set(gcf, 'PaperPosition', myfiguresize);
set(gcf, 'PaperPositionMode', 'auto');

subplot2(511)     %  wind speeds
[stG dG]=nanGaps(stat10.time, stat10.gust, gap);
plot(stG, dG,'r')
hold on
[stG dG]=nanGaps(stat10.time, stat10.speed, gap);
plot(stG, dG,'g')
[stG dG]=nanGaps(stat10.time, stat10.sust, gap);
plot(stG, dG,'k')
dateaxis('x',7);
axis tight
set(gca,'XLim',[floor(stat10.time(1)) ceil(stat10.time(end))+5]);
grid on
set(gca,'XMinorGrid','on')
set(gca,'XTickLabel',[]);
ylabel('Speed (m/s)','FontSize',12);

txt=sprintf('Winds: Gauge=%d, %s -- Raw Data and Stats', IDsp, stat10.name);
title(txt,'FontSize',14)

bb2=find(stat10.qcFlag == 3);       % failed
bb=find(stat10.qcFlag == 2);       % questionable
if (~isempty(bb)) && (~isempty(bb2))
	plot(stat10.time(bb), stat10.speed(bb),'gd')
    plot(stat10.time(bb2), stat10.speed(bb2),'rd')
    legend('Gust','Mean','Sust','questionable','failed' );
elseif ~isempty(bb)
    plot(stat10.time(bb),stat10.speed(bb),'gd')
    legend('Gust','Mean','Sust','questionable')
elseif ~isempty(bb2)
    plot(stat10.time(bb2), stat10.speed(bb2),'rd')
    legend('Gust','Mean','Sust','failed') 
else
    legend('Gust','Mean','Sust')
end




subplot2(512)      % Dir
bb=find(stat10.qcFlag == 2);       % questionable
if (~isempty(bb))
	plot(stat10.time(bb), stat10.speed(bb),'gd')
end
bb=find(stat10.qcFlag == 3);       % failed
if (~isempty(bb))
	plot(stat10.time(bb), stat10.speed(bb),'rd')
end

[stG dG]=nanGaps(stat10.time, stat10.vdir, gap);
plot(stG, dG, 'b')
grid minor
set(gca,'XLim',[floor(stat10.time(1)) ceil(stat10.time(end))+5]);
dateaxis('x',7);
grid on
set(gca,'XMinorGrid','on')
set(gca,'XTickLabel',[]);
ylabel('Dir (deg N)','FontSize',12);

subplot2(513)      % QC speed bitFlag (limit to 10) and stat10 flag
smb=['b+';'b+';'b+';'b+';'b+';'b+';'b+';'b+'];
smb2=['r+';'r+';'r+';'r+';'r+';'r+';'r+';'r+'];


[stG, dG]=nanGaps(stat10.time, stat10.qcFlag, gap);      % stat10 flag
plot(stG, dG, 'r','LineWidth',2); hold on
for j=1:8  % running through each bit
	bi_s=find(bitget(QC.bitFlagS, j) == 1);
	bi_d=find(bitget(QC.bitFlagD, j) == 1);
    if (~isempty(bi_s))
		plot(QC.time(bi_s), j,'c^-', 'MarkerSize',5)
    end
    if (~isempty(bi_d))
        plot(QC.time(bi_d), j, 'o-b','MarkerSize', 5)
	end 
end


legend('stat10.qcFlag','Speed Flag #','Direction Flag #')%,'bad mean','high stdMean','low stdMean','high meanStd','high stdStd','superfail');

dateaxis('x',7);
set(gca,'XLim',[floor(stat10.time(1)) ceil(stat10.time(end))+5]);
set(gca,'YLim',[0 10]);
grid on
set(gca,'XMinorGrid','on')
set(gca,'YMinorGrid','on')
set(gca,'XTickLabel',[]);
ylabel('Bit Flag','FontSize',12);

subplot2(514)      % meanStd & stdMean
[stG dG]=nanGaps(QC.time, QC.meanStd, gap);
plot(stG, dG, 'b')
hold on
[stG dG]=nanGaps(QC.time, QC.stdMean, gap);
plot(stG, dG, 'r')
legend('meanStd','stdMean')
dateaxis('x',7);
set(gca,'XLim',[floor(stat10.time(1)) ceil(stat10.time(end))+5]);
grid on
set(gca,'XMinorGrid','on')
set(gca,'XTickLabel',[]);
ylabel('mean-std (m/s)','FontSize',12);

subplot2(515)      % stdstd
[stG dG]=nanGaps(QC.time, QC.stdStd, gap);
plot(stG, dG, 'b')
dateaxis('x',7);
grid on
set(gca,'XMinorGrid','on')
set(gca,'XLim',[floor(stat10.time(1)) ceil(stat10.time(end))+5]);
ylabel('std-std','FontSize',12);

xlabel([months(dv(2),:) ' ' num2str(dv(1))],'fontsize',12);
	
fnamePNG = sprintf('outputdata/RawStats/windQC_%d_%d%02d.png', stat10.ID, dv(1), dv(2));
print(f2, '-dpng','-r160', fnamePNG)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (figOff == 1)
	%clear all
	%close all
end
    end
end
end