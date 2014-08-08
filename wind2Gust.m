function [sp, vsp, maxSp, minSp, dr, gust, sust, wstd, wtime]= wind2Gust(S,D,stime,aveTime,dt)
% function [sp, dr, gust, sust, wstd, timeAve]=wind2Gust(S,D,stime,aveTime)
%
% Rev 9 May 2014 - Kent Hathaway
%
%  Compute average speed, dir, gust, sustainied, and standard deviatiom of a wind speed 
%  and direction record.  10-minute averages (sustained, max, gust).
%  Generally run for 10-minute aveTime.
%
% Input: S=speed, D=direction, stime=time for each point, aveTime=time to average over 
% (10/1440 of a day), dt=sample interval.
%
% Output: sp=ave speed. vsp=vector ave speed, maxSp=max single speed, minSp=min single
%   speed, dr=vector ave dir, gust=5s peak ave, sust=1 minute peak speed, wstd=speed standard 
%   deviation, wtime=start time of average
%

r2d=180/pi;
%  filtfilt filters for gust (5 seconds) and sustained (1 minute)
b1m=ones(1,ceil(60/dt))/(60/dt);
b5s=ones(1,ceil(5/dt))/(5/dt);

% East and North components
[N, E]=pol2cart(D/r2d, S);

% Filter entire record first then do 10-minute stats
m10=ceil( (stime(end)-stime(1))/aveTime);        % number of aveTime increments to start time
% determine first 10-min segment
dv=datevec(stime(1));
dv(5)=floor(dv(5)/10)*10;
t0=datenum(dv);
minPts=0.5*aveTime*24*3600/dt;   % want at least 50% of the data for an ave interval 

N1m=filtfilt(b1m, 1, N);
N5s=filtfilt(b5s, 1, N);
E1m=filtfilt(b1m, 1, E);
E5s=filtfilt(b5s, 1, E);

[D1m, S1m]=cart2pol(N1m, E1m);
[D5s, S5s]=cart2pol(N5s, E5s);

rc=0;
sp=[]; vsp=[]; maxSp=[]; minSp=[]; dr=[]; gust=[]; sust=[]; wstd=[]; wtime=[];

for nh=1:m10
	pt=find(stime >= t0+(nh-1)*aveTime & stime < t0+nh*aveTime);
	if (isempty(pt)); continue; end;   % skip looping, no more data
	if (length(pt) > minPts)           % have enough points
		rc=rc+1;
		wtime(rc)=stime(pt(1));
		sp(rc)=mean(S(pt));
		vsp(rc)=sqrt(mean(E(pt)).^2 + mean(N(pt)).^2);
		minSp(rc)=min(S(pt));
		maxSp(rc)=max(S(pt));
		sust(rc)=max(S1m(pt));
		gust(rc)=max(S5s(pt));
		dr(rc)=mod(atan2(mean(E(pt)), mean(N(pt)))*r2d, 360);
		wstd(rc)=std(S(pt));
	end
end

return


