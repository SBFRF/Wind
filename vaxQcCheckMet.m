function [D, qc, bitFlag, ptsEdited]=vaxQcCheckMet(D,typ,depth,dt,seg)
% [qcFlag1, qcFlag2]=vaxQcCheck(d,typ,depth,dt,seg) 
%
% vaxQcCheckMet.m to edit vax timeseries
% Created 8 May 2014 - Kent Hathaway
% Rev     9 May 2014 - KH.  Changed trend removal to each segment, was poly over all points. 
% Rev     26 June 2014 - SB added 8th bit for 'super fail' ( 20% above/below threshold)
%  Hacked from vaxQcCheck.m
% 
% Input:
%   D = timeseries,  typ = gauge type, depth = gauge -Z (positive number), dt = sample interval (0.5s), 
%   seg = segment size for mean variance check
% Output
%   D = edited data
%   qc structure with fields: mean, var, meanStd, stdMean, and stdStd
%   bitFlag is a bitflag, int16 bits set for: 
%   1=points were edited, 
%   2=Mean out of Threashold range, 
%   3=unstable mean (high stdMean)
%   4=low std, 
%   5=high std,
%   6=high std of std (normalized), ...
%   7= ???? Nothing Yet
%   8= 'superfail' 20% above threshold value, used to see if points are giant outliers
%   (creates second flag for --> qcflag3 (failed)
%  ptsEdited = total number of points edited

% Valid gauge types for this analysis:
% Type   Gauge             units  Tresh-tested
%   6    Wind speed        (m/s)      N
%   7    Wind direction    (deg)      N
%   8    Air temperature   (C)        N
%   9    Barometer         (mbar)     N
%  13    Rain              (mm)       N

% initialize
Gtypes={'6','7','8','9','13'};
gti=find(ismember(Gtypes, typ) == 1);   % index for threshold values
qcFlag=0;
bitFlag=uint16(0);
ptsEdited=0;
qc=[];
if (isempty(gti))
	disp(['<WW> Invalid gauge type for this QC: ', typ]);
	return 
end       % not a valid gauge type for this edit

% Set thresholds: min, max, stdMean, meanStd, stdStd
thMin=[0.01, -0.1, -20, 920, -0.01 ];   % min mean
thMax=[42, 600, 48, 1050, 20];          % max mean
thMaxStdMean=[5, 200, 2, 3, 10];        % max std of mean
% thMaxStdMeanNorm=[0.1, 400, 2, 0.5, 10];        % max std of mean
thMinStd=[0.03, 0.4, 0.01, 0.001, 0];       % low std (wind speed is normalized)- of mean SB
thMaxStd=[3, 200, 5, 4, 20];                % high std (wind speed is normalized)
thMaxStdStd=[10, 100, 5, 2, 20];                % max std of std (normalized by total std?)

%thMin=[0.01, -0.1, -20, 920, -0.01 ];   % min mean
%thMax=[42, 600, 48, 1050, 20];          % max mean
%thMaxStdMean=[5, 200, 2, 3, 10];        % max std of mean
%$$$ thMaxStdMeanNorm=[0.1, 400, 2, 0.5, 10];        % max std of mean
%thMinStd=[0.02, 0.4, 0.01, 0.001, 0];       % low std (wind speed is %normalized) - of mean SB
%thMaxStd=[3, 200, 5, 4, 20];                % high std (wind speed is normalized)
%thMaxStdStd=[10, 100, 5, 2, 20];                % max std of std (normalized by total std?)





% First QC check for wacko points - spikes
% Future - had modify threshold here based on Gtype
t=0:dt:(length(D)-1)*dt;
totalBad=0;
for AA=1:5             % 2 iterations to fix bad points &&& changed to 5 - SB
	[pf,pfs,mu]=polyfit(t, D, 3);
	pi3=polyval(pf,t, pfs, mu);
	pStd=std(D - pi3);
	ibad=find( abs((D - pi3)) > 5*pStd);
	D(ibad)= NaN;
	NaNs=isnan(D);
	igood=find(NaNs == 0);
	ibad=find(NaNs == 1);
	if (~isempty(ibad))
		totalBad=totalBad+length(ibad);
		intValues= interp1(t(igood),D(igood),t(ibad));
%  deal with endpoints where interp is NaN
		if (ibad(1)==1); intValues(1)=pi3(1); end;
		if (ibad(end)==length(D)); intValues(end)=pi3(end); end;
		D(ibad)=intValues;
	end
end

ptsEdited=totalBad;
if (ptsEdited > 0.02*length(D));    % > 2% of points ed
    bitFlag = bitset(bitFlag, 1); 
end;       

% compute means, std of the mean, std of the std, mean std,  
Dmean = mean(abs(D));       % use abs for N and E wind components

% Mean variance check - remove quadratic fit and look at variance of the mean in 'overlap-point' segments

nseg=floor(length(D)/seg);     % integer number of segs in data
t2=t(1:seg);
for jj=1:nseg
	d2=D((jj-1)*seg+1:jj*seg);              % may truncate
%	[pf,pfs,mu]=polyfit(t2, d2, 3);
%	pi3=polyval(pf,t2, pfs, mu);     % polyfit of each point to data
%	d2=d2-pi3;                       % data with trend removed
	meanQC(jj) = mean(d2);                % mean over nseg segments
	stdQC(jj) = std(d2);           % mean of the std over nseg segments, not prf correctrd
end

qc.mean = mean(meanQC);       % std of the mean over nseg segments
qc.stdMean = std(meanQC);     % std of the mean over nseg segments
qc.meanStd = mean(stdQC);     % std of the mean over nseg segments
qc.stdStd = std(stdQC) ./ qc.meanStd;       % normalized std of the std over nseg segments, not prf corrected

if (gti == 1)                          % use min values for wind speed, normalize stdQC
	minMean=min(meanQC);                  % look for the lowest mean 
	minStd=mean(stdQC)./mean(meanQC);                  % look for the lowest mean 
else
	[sx,sxi]=sort(meanQC,'ascend');
	minMean=mean(meanQC(sxi(1:2)));       % look for the two lowest means 
%	minMean=mean(meanQC);                  % look for the lowest mean 
%	minStd=mean(stdQC);                  % look for the lowest mean 
	[sx,sxi]=sort(stdQC,'ascend');     % look for the lowest std's
	minStd=mean(stdQC(sxi(1:2)));       % look for the two lowest std's 
end

% save gg

% New - look for min segment mean and segment std 
% Mean check - valid range, thresholds 
if ( qc.mean > thMax(gti) || minMean < thMin(gti))% mean excedded range, wide range 
 	bitFlag = bitset(bitFlag, 2);
    if ( qc.mean > thMax(gti)*1.2 || minMean < thMin(gti)*0.8)  % 20% above/below threshold 
        bitFlag = bitset(bitFlag, 8); 
    end
end
if ( qc.stdMean > thMaxStdMean(gti) )      % std of mean 
	bitFlag = bitset(bitFlag, 3);
    if (qc.stdMean > thMaxStdMean(gti)*1.2)  %  20% above threshold
        bitFlag=bitset(bitFlag,8);
    end
end
if ( minStd < thMinStd(gti))       % low std 
	bitFlag = bitset(bitFlag, 4);
    if ( minStd < thMinStd(gti)*0.85)  %  20% below threshold
        bitFlag = bitset(bitFlag,8);
    end
end
if ( qc.meanStd > thMaxStd(gti))     % high std
	bitFlag = bitset(bitFlag, 5);
    if ( qc.meanStd > thMaxStd(gti)*1.2)  %  20% above threshold
        bitFlag = bitset(bitFlag,8);
    end
end
if ( qc.stdStd > thMaxStdStd(gti))  % high std of the std
	bitFlag = bitset(bitFlag, 6);
    if (qc.stdStd > thMaxStdStd(gti)*1.2)  % 20% above threshold
        bitFlag = bitset(bitFlag,8);
    end     
end

   

return

% Test code
D=1:16000;
D2=zeros(1,16000);
jj=find(mod(floor(D/5000),2) == 1);
D2(jj)=360;
plot(D2)
nseg=floor(length(D2)/seg);
D2=D2(1:nseg*seg);
AA=reshape(D2,seg,nseg);

mean(AA)
std(AA)
mean(std(AA))
std(mean(AA))
std(std(AA))
%  


aveTime=10/1440;     % 10 minutes
gn=find(vaxTS.meta(1).id == 121);
ti=find(vaxTS.ID == 121);
m1=min(vaxTS.metaNum(ti));
m2=max(vaxTS.metaNum(ti));
tsMeta=[];
mc=0;
for i=m1:m2
	mc=mc+1;
	tsMeta(mc).time = vaxTS.meta(i).time;
	tsMeta(mc).id = vaxTS.meta(i).id(gn);
	tsMeta(mc).name = char(vaxTS.meta(i).name{gn});
	tsMeta(mc).type = char(vaxTS.meta(i).type{gn});
	tsMeta(mc).gtype = char(vaxTS.meta(i).gtype{gn});
	tsMeta(mc).manufacturer = char(vaxTS.meta(i).manufacturer{gn});
	tsMeta(mc).sn = char(vaxTS.meta(i).sn{gn});
	tsMeta(mc).lat = vaxTS.meta(i).lat(gn);
	tsMeta(mc).lon = vaxTS.meta(i).lon(gn);
	tsMeta(mc).X = vaxTS.meta(i).X(gn);
	tsMeta(mc).Y = vaxTS.meta(i).Y(gn);
	tsMeta(mc).Z = vaxTS.meta(i).Z(gn);
	tsMeta(mc).depth = vaxTS.meta(i).depth(gn);
	tsMeta(mc).orient = vaxTS.meta(i).orient(gn);
	tsMeta(mc).gain = vaxTS.meta(i).gain(gn);
	tsMeta(mc).bias = vaxTS.meta(i).bias(gn);
	tsMeta(mc).freq = vaxTS.meta(i).freq;
	tsMeta(mc).units = char(vaxTS.meta(i).units{gn});
	tsMeta(mc).res = vaxTS.meta(i).res(gn);
	tsMeta(mc).daq = vaxTS.meta(i).daq;
end

rc=0;
for ii=1:length(ti)	  % loop each timeseries index
	n=ti(ii);           % input record number
	mn=vaxTS.metaNum(n);
	fs=tsMeta(mn).freq;       % sample rate
	dt=1./fs;                 %  sampling interval (0.25, 0.5, or 1)
	D = (double(vaxTS.D{n})' ./ 1000  - tsMeta(mn).bias) * tsMeta(mn).gain; 
	t=0:dt:(length(D)-1)*dt;
	t=t/(3600*24) + vaxTS.time(n);
	m10=ceil((t(end)-t(1))/aveTime);        % number of aveTime increments to start time
	dv=datevec(t(1));
	dv(5)=floor(dv(5)/10)*10;
	t0=datenum(dv);
	minPts=0.5*aveTime*24*3600/dt;

	for nh=1:m10
		pt=find(t >= t0+(nh-1)*aveTime & t < t0+nh*aveTime);
		if (isempty(pt)); continue; end;   % skip looping, no more data
		if (length(pt) > minPts)           % have enough points
			rc=rc+1;
			stat10.time(rc)=t(pt(1));
			stat10.mean(rc)=mean(D(pt));			
		end
	end
end

 dd=[stat10.mean(171:182) stat10.mean(211:224) stat10.mean(183:210) stat10.mean(225:260)];
tt=[stat10.time(171:182) stat10.time(211:224) stat10.time(183:210) stat10.time(225:260)];

 