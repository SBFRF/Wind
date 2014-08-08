function [] = getVaxDeployInfo(deploy, gt)
% function [] = getVaxDeployInfo(deploy, ID, gt)
%
% Created by Kent Hathaway, 14 May 2014
%
% Reads the deploy structure from vaxDeployTimes.mat.
% Finds:
%   1) all IDs for specified gauge type (gt)
%   2) 
% Rev 14 May 2014 
%
% Makes 10-minute wind stats from Vax timeseries.  Saves matlab and ascii (columnar) files. 
%  Stats: (mean, min, max, gust, sustained, std). 
% The timeseries is unedited so this code does the QC.

% Called from perl which needs to set ID, year, mon.  The program will read the 
% gauge type from the metadata to determine threshold QC settings (in vaxQcCheckWind,m).
%
% Call vaxQcCheckWind.m to edit timeseries 
% QC: 
%   qcFlag =  0=passed, 1=passed but edited, 2=questionable, 3=failed, 4=unchecked (should not see this)
%   bitFlag is a bitflag, int16 bits set for:  1=points were edited, 2=funky mean, 3=unstable mean, 
%      4=low std, 5=high std, 6=low SN ratio, 7=?
%   ptsEdited = total number of points edited

% Valid gauge types for this analysis:
% Type   Gauge             units  Tresh-tested
%   6    Wind speed        (m/s)        N
%   7    Wind direction    (deg)     N

% TODO:

%IDsp=932;
%IDdir=933;
%yr = 2010;
%mon=5;
%% SB Code
%load 'vaxTS_201302_unedited.mat' 



%%
% Quick check if the gauge and times are valid
load vaxDeployTimes.mat
% see if ID is valid
ii=find (IDsp == ID);   
if (isempty(ii) )
	disp(['<WW> ID not valid'])
	return 
end;

% see if the time is valid, at least possibly valid month
d1=datenum(yr, mon, 1, 0, 0, 0);
%d2=datenum(yr, mon+1, 1, 0, 0, 0);
jj=find (deploy(ii).start < d1 & deploy(ii).stop > d1);
if (isempty(jj) )
	disp(['<WW> Year=' num2str(yr) ' Month=' num2str(mon) ' not available'])
	return 
end;
