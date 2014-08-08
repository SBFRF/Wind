% vaxTs2_10minWind
%
% Created by Kent Hathaway, 8 May 2014
%
% Rev 8 May 2014 
%
% Makes 10-minute wind stats from Vax timeseries.  Saves matlab and ascii (columnar) files. 
% Stats: (mean, min, max, gust, sustained, std). 
% The timeseries is unedited so this code does the QC.

% Called from perl which needs to set ID, year, mon.  The program will read the 
% gauge type from the metadata to determine threshold QC settings (in vaxQcCheckWind,m).
%
% Call vaxQcCheckWind.m to edit timeseries 
% QC: 
%   qcFlag =  0=passed, 1=passed but edited, 2=questionable, 3=failed, 4=unchecked (should not see this)
%   bitFlag is a bitflag, int16 bits set for:  1=points were edited, 2=funky mean, 3=unstable mean, 
%      4=low std, 5=high std, 6= std of std , 7=low SN ratio 8=superfail
%   ptsEdited = total number of points edited

% Valid gauge types for this analysis:
% Type   Gauge             units  Tresh-tested
%   6    Wind speed        (m/s)     N
%   7    Wind direction    (deg)     N

% TODO:

%IDsp=932;
%IDdir=933;
%yr = 2010;
%mon=5;
%% SB Code insert
%intro and variable definitions
disp '-------------------------------------------------------------------'
disp '|                     Data Crunch code                            |'
disp '|                     10 min wind stats                           |'
disp '-------------------------------------------------------------------'
%load 'vaxTS_200605_unedited.mat';

%the gauges that will be checked and run
gaugeIDs= [532,533; 602,603; 612,613; 642,643; 672,673; 682,683];  %[932,933; 832,833; 732,733; 632,633];


%IDsp=932;  % gauge number for Speed?
%IDdir=933; % gauge number for Direction?
yr=1980:2013;   % year for loaded file
mon=1:12;     % month for loaded file



%% check
% Quick check if the gauge and times are valid
load vaxDeployTimes.mat
% see if ID is valid----------------MOVED BELOW -SB
%ii=find (IDsp == ID);   
%if (isempty(ii) )
%	disp(['<WW> ID not valid'])
%	return 
%end;

% see if the time is valid, at least possibly valid month
%d1=datenum(yr, mon, 1, 0, 0, 0);
%d2=datenum(yr, mon+1, 1, 0, 0, 0);
%below removed by SB,  d1 wouldn't match up with deploy(ii).start
%jj=find (deploy(ii).start < d1 & deploy(ii).stop > d1);  
%if (isempty(jj) )
%	disp(['<WW> Year=' num2str(yr) ' Month=' num2str(mon) ' not	available'])
%	return 
%end;



%diary on

r2d=180/pi;
aveTime=10/1440;     % 10 minutes
%if (~exist('IDsp','var') || ~exist('IDdir','var') )
%	disp('<EE> ID not set, calling this program from manyVaxWindStat10.pl')
%	return 
%end;

%if (~exist('yr','var') || ~exist('mon','var') )
%	disp('<EE> year or month not set, calling this program from manyVaxWindStat10.pl')
%	return 
%end;

%% Get input timeseries file - removed for SB version, below
%       think its same thing
%matTsFile=sprintf('vaxTS_%4d%02d_unedited.mat', yr, mon);

%if (exist(matTsFile,'file'))
%	disp(['<II> Loading ' matTsFile])
%	load(matTsFile);
%else
%	disp(['No TS file ' matTsFile])
%	return;
%end;

%% load multiple files - SB
% check to see if the output directorys exist
% if not, create them
if ~exist('outputdata/asciiFile', 'dir')  
  mkdir('outputdata/asciiFile');
end
if ~exist('outputdata/matFile', 'dir')  
  mkdir('outputdata/matFile');
end
missingdata=[];

for yy = 3:6 % do 4 seperately    %length(gaugeIDs)  this is removing gauge 632
    IDsp=gaugeIDs(yy,1);
    IDdir=gaugeIDs(yy,2);
    disp('**************new gauge**************')
    disp(sprintf('Gauge ID: %d & DIR:%d',IDsp, IDdir));
    
    %moved from above( copied, place holder still there)
    ii=find (IDsp == ID);   
    if (isempty(ii) )
        disp('<WW> ID not valid')
        return 
    end;
    if (~exist('IDsp','var') || ~exist('IDdir','var') )
        disp('<EE> ID not set, calling this program from manyVaxWindStat10.pl')
        return 
    end;

    if (~exist('yr','var') || ~exist('mon','var') )
        disp('<EE> year or month not set, calling this program from manyVaxWindStat10.pl')
        return 
    end;
    
    
for yr=1985:2013  %SB loop
     for mon=1:12
        matTsFile=sprintf('/RawData/vaxTS_%4d%02d_unedited.mat', yr, mon);
        if exist(matTsFile, 'file')
             disp(sprintf('**Loading month=%d - year=%d**',mon,yr));
             load (matTsFile);
        else
            disp(sprintf('***MET Data file: %s does not exist.', matTsFile));
           continue 
        end
        
        
        


% find time series indicies for this gauge
ti=find(vaxTS.ID == IDsp);
ti2=find(vaxTS.ID == IDdir);
if (length(ti) ~= length(ti2))
	disp '<WW> Number of speed and direction records do not match'
    continue
end
% get range of meta structures for this gauge
m1=min(vaxTS.metaNum(ti));
m2=max(vaxTS.metaNum(ti));
% gage num index in meta fields
gn=find(vaxTS.meta(1).id == IDsp);
gn2=find(vaxTS.meta(1).id == IDdir);

if (isempty(gn) || isempty(gn2))
	disp(['<WW> No data: year=' num2str(yr) '  month=' num2str(mon)])
    missingdatatemp=[mon, yr, IDsp, IDdir];
    missingdata = [missingdata; missingdatatemp];
else
   %return;


% extract timeseries meta data for this gauge
tsMeta=[];
mc=0;
for i=m1:m2
	if (~isnan(vaxTS.meta(i).gain(gn2)));
		mc=mc+1;
		tsMeta(mc).time = vaxTS.meta(i).time;
		tsMeta(mc).id = vaxTS.meta(i).id(gn);
		tsMeta(mc).name = char(vaxTS.meta(i).name{gn});
		tsMeta(mc).type = char(vaxTS.meta(i).type{gn});
		tsMeta(mc).type2 = char(vaxTS.meta(i).type{gn2});
		tsMeta(mc).gtype = char(vaxTS.meta(i).gtype{gn});
		tsMeta(mc).gtype2 = char(vaxTS.meta(i).gtype{gn2});
		tsMeta(mc).manufacturer = char(vaxTS.meta(i).manufacturer{gn});
		tsMeta(mc).sn = char(vaxTS.meta(i).sn{gn});
		tsMeta(mc).lat = vaxTS.meta(i).lat(gn);
		tsMeta(mc).lon = vaxTS.meta(i).lon(gn);
		tsMeta(mc).X = vaxTS.meta(i).X(gn);
		tsMeta(mc).Y = vaxTS.meta(i).Y(gn);
		tsMeta(mc).Z = vaxTS.meta(i).Z(gn);
		tsMeta(mc).depth = vaxTS.meta(i).depth(gn);
		tsMeta(mc).orient = vaxTS.meta(i).orient(gn);
		tsMeta(mc).gain1 = vaxTS.meta(i).gain(gn);
		tsMeta(mc).bias1 = vaxTS.meta(i).bias(gn);
		tsMeta(mc).gain2 = vaxTS.meta(i).gain(gn2);
		tsMeta(mc).bias2 = vaxTS.meta(i).bias(gn2);
		tsMeta(mc).freq = vaxTS.meta(i).freq;
		tsMeta(mc).units = char(vaxTS.meta(i).units{gn});
		tsMeta(mc).res = vaxTS.meta(i).res(gn);
		tsMeta(mc).daq = vaxTS.meta(i).daq;
	end
end

% clear analysis meta
meta=[];
QC=[];

% for adding gauge generic gauge name from VaxGaugeTypes.txt.  Assumes 'type' doesn't change
%gti = find(ismember(gt, tsMeta(1).type) == 1);     % index number of types 
%gtype=char(gname(gti));                     % text name for that type
gtype=char(tsMeta(1).gtype);                     % text name for that type
Units=char(tsMeta(1).units);                     % text name for that type

% output file name
matFile=sprintf('outputdata/matFile/vax_10min_%s_%d_%4d%02d.mat', gtype, IDsp, yr, mon);
asciiFile=sprintf('outputdata/asciiFile/vax_10min_%s_%d_%4d%02d_UTC.txt', gtype, IDsp, yr, mon);

% initialize
stat10=[];
stat10.ID=IDsp;
stat10.file=matTsFile;
stat10.type='10-min ave';
stat10.name=tsMeta(1).name;
stat10.magcorr=0;                % 1D spectra
stat10.filename=matTsFile;
stat10.timezone=0;               % everything should be UTC
stat10.lat=tsMeta(1).lat;        % just first occurance in meta
stat10.lon=tsMeta(1).lon;        %  "
stat10.depth=-tsMeta(1).depth;
%stat10.nomDepth=-tsMeta(1).depth;
stat10.depthP=tsMeta(1).Z;
        
rc=0;         % record counter for stat10 (one per 10-minute ave)
qn=0;         % record counter for QC (one per record, nX4096 point)

for ii=1:length(ti)	  % loop each timeseries index
%for ii=1:1
	n=ti(ii);           % input record number
	mn=find([tsMeta.time] <= vaxTS.time(n));
	if (isempty(mn))
		disp(['<EE> No meta data ' datestr(vaxTS.time(n))])
		%break
        continue
	else
		mn=mn(end);
	end

	% get sampling rate and set fft parameters 
	fs=tsMeta(mn).freq;       % sample rate
	dt=1./fs;                 %  sampling interval (0.25, 0.5, or 1)
	
	% check that there's a matching time for the direction data
    %if ii<length(ti2)  % SB add  ** this loop if on allows for the error
    %of the D and S not matching up
         if (vaxTS.time(n) ~= vaxTS.time(ti2(ii)))      % time indicies are off, find matching time
            tt=find(vaxTS.time(ti2) == vaxTS.time(n));
            if (isempty(tt))
                disp(['<EE> Not direction data for ' datestr(vaxTS.time(ti2(ii)))])
                missingdatatemp=[mon, yr, IDsp, IDdir];
                missingdata = [missingdata; missingdatatemp];
                break
                %continue
            
            end
        else
            tt=ti2(ii);
        end
  % end

		% convert int16 to data in engr units
	S = (double(vaxTS.D{n})' ./ 1000  - tsMeta(mn).bias1) * tsMeta(mn).gain1; 
		
	% convert int16 to data in engr units
	D = (double(vaxTS.D{tt})' ./ 1000  - tsMeta(mn).bias2) * tsMeta(mn).gain2;

	% time sequence for this data
	t=0:dt:(length(D)-1)*dt;
	t=t/(3600*24) + vaxTS.time(ti(ii));
	
		          % QC checks
		% do a check for S - S2 will be spike edited.
		% Then check D channel but don't use modified data (D2), just use the bitFlag 
		% Future - maybe need to umwrap dir, remove trend for checker?
		
	minPts=0.5*aveTime*24*3600/dt;   % want at least 50% of the data for an ave interval 
   
    
    
    [S2, qc, bitFlag, ptsEdited]=vaxQcCheckMet(S, tsMeta(mn).type, -tsMeta(mn).depth, dt, minPts);
	[D2, qc2, bitFlag2, ptsEdited2]=vaxQcCheckMet(D, tsMeta(mn).type2, -tsMeta(mn).depth, dt, minPts);
%	[N, E]=pol2cart(D/r2d, S);
%	[N2, qc2, bitFlag2, ptsEdited2]=vaxQcCheckMet(N, tsMeta(mn).type, -tsMeta(mn).depth, dt, minPts);
%	[E2, qc3, bitFlag3, ptsEdited3]=vaxQcCheckMet(E, tsMeta(mn).type, -tsMeta(mn).depth, dt, minPts);
%	[D2, S2]=cart2pol(N2, E2);
%	D2=mod(D2*r2d, 360);                % radian to degree, 0-360;

    D2=D;                % use unedited - direction can have false spikes between 0 and 360
  
    
   
   
     bitFlag12=bitor(bitFlag, bitshift(bitFlag2, 8));         % combine bitFlags for speed and dir (high byte)
   
	[sp, vsp, maxSp, minSp, dr, gust, sust, wstd, wtime]= wind2Gust(S2,D2,t,aveTime,dt);
	
	% loop through 10-min segments
	qn=qn+1;
	
	for mm=1:length(sp)
		rc=rc+1;
		stat10.time(rc)=wtime(mm);
		stat10.speed(rc)=sp(mm);
		stat10.vspeed(rc)=vsp(mm);
		stat10.sust(rc)=sust(mm);
		stat10.gust(rc)=gust(mm);
		stat10.vdir(rc)=dr(mm);
		stat10.maxSp(rc)=maxSp(mm);
		stat10.minSp(rc)=minSp(mm);
		stat10.stdSp(rc)=wstd(mm);
		stat10.metaNum(rc)=mn;          % to track TS meta to stats
		stat10.qcNum(rc)=qn;            % to track QC meta to stats
%		stat10.qcFlag(rc) = bitor(bitFlag, bitshift(bitFlag2, 8));   % dir flags in high byte

		% Set QC flag
		stat10.qcFlag(rc) = 0;                   % Assume it's OK, then test if not
		if ((ptsEdited + ptsEdited2) > 0);         
            stat10.qcFlag(rc) = 1;          % edited but maybe OK
        end;   
		if ( bitFlag12 > 0)                        % something wrong, how bad?  How many bits set?
			if (bitand(bitFlag12, uint16(255)))         % fail if > 2% of the points are edited (test bits 1 and 9)
				if ((ptsEdited + ptsEdited2) > 0.05*length(S))   % edited  > 5% of each record, surely failed  
					stat10.qcFlag(rc) = 3;             % Failed
				else
					stat10.qcFlag(rc) = 2;             % Questionable
				end
			end                                  
			if (stat10.qcFlag(rc) < 3)                % if not failed yet see if other flags are set
				if (bitxor(bitFlag12, uint16(255)) > 0)   % Mask out edited bits 1 and 9
					stat10.qcFlag(rc)=2;                % Questionable 
				end
            end
        end
       %SB insert - loop for failing if multiple flags are set (more than 2)
       flagsum=0;   % set indicies to zero for every time loop
       for pp=1:16        % loop for failing if multiple flags are set (more than 2)
            flagtype=bitget(bitFlag12,pp);
            flagsum=flagsum+flagtype;
        end
        if flagsum >= 2    %fail if >2 flags set
            stat10.qcFlag(rc)=3;
        end                     %end of SB insert  
            
    
    end 

	QC.time(qn) = vaxTS.time(n);
	QC.mean(qn)=qc.mean;
	QC.meanStd(qn)=qc.meanStd;
	QC.stdMean(qn)=qc.stdMean;
	QC.stdStd(qn)=qc.stdStd;
	QC.ptsEdited(qn) = ptsEdited;
	QC.ptsEdited2(qn) = ptsEdited2;
	QC.bitFlagS(qn)=bitFlag;
	QC.bitFlagD(qn)=bitFlag2;
end     % through each record    

%% Save mat and ascii files

%if ~exist('stat10.time','var')  ** this was done to try to get around the
%stat10.time not being displayed.  found it caused more indicie problems
 %    disp ' Wonkey data - Stat10 was never created'   %stat10.time was never created, has to do with indicies ii ti2/meta data
%else
    if (length(stat10.time) > 1)
	save(matFile,'stat10', 'QC','tsMeta');

	% Save ascii file
	fout=fopen(asciiFile,'w');
	fprintf(fout,'year mm dd hh MM     speed   vspeed    gust     sust    vdir   stdSpd\n');
	fprintf(fout,'                     (m/s)    (m/s)   (m/s)    (m/s)   (degN)   (m/s)\n');

	for ii=1:rc	  % loop each stat
		dv=datevec(stat10.time(ii));
		if (QC.bitFlagS(stat10.qcNum(ii)) < 2)            % Speed OK
			if (QC.bitFlagD(stat10.qcNum(ii)) == 0)         % Dir OK
				fprintf(fout,'%4d %2d %2d %2d %2d %8.2f %8.2f %8.2f %8.2f %6.0f %8.2f\n', ...
					dv(1), dv(2), dv(3), dv(4), dv(5), stat10.speed(ii), stat10.vspeed(ii), ...
					stat10.gust(ii), stat10.sust(ii), stat10.vdir(ii), stat10.stdSp(ii) );
			else                                            % Dir bad
				fprintf(fout,'%4d %2d %2d %2d %2d %8.2f     NaN  %8.2f %8.2f   NaN  %8.2f\n', ...
					dv(1), dv(2), dv(3), dv(4), dv(5), stat10.speed(ii), ...
					stat10.gust(ii), stat10.sust(ii), stat10.stdSp(ii) );
			end
		end
	end
	disp(sprintf('%s gauge #%d ---  month=%02d year=%4d processed successfully', gtype, IDsp, mon, yr))
    fclose(fout);
    else
        disp(sprintf('%s gauge #%d ---  month=%02d year=%4d NOT PROCESSED', gtype, IDsp, mon, yr'));
   end
%end
  
    
    


 
end     % gauge number end no data
   end  %month end
end    %year end
end     %end from gauge number      

%diary off
 
 disp ' All available data Crunched!!!!'