% Script to look at all key records to get gauge deployment times.
%
% Created 13 May 2014 - Kent Hathaway

% Loads all keys, finds unique IDs, loops through IDs to determine start
% and stop times.  Stop is any gap > TBD.
% Writes a mat file with the ID array and deploy structure:
%
%  ID"  (111, 121, 131, 932, 933, ...)
%	deploy:
%		ID
%		start
%		stop
%		type         ( gauge type numeric )
%		gtype			 ( string gauge type ) 
%		lat
%		lon
%		X
%		Y
%		Z
%		depth
%		sn
%		manufacturer
%
%  "type" and other stuff are found by reading 'VaxGaugeTypes.txt' and 'hdrInfoAll3.csv'.
%
% Assumes a change in the header signals a new deployment.


% Get the keys
a=load('allVax.key');      % big so it takes a while to read
est2Utc = 5/24;

% Get the generic text names to match numeric type 
[gt,gname,Units]=textread('VaxGaugeTypes.txt','%d %s %s');

% Get the header info 
[id, yr, mo, day, hr, mn, epoch, epoch2, name, type, sn, manufacturer, lat, lon, X, Y, Z, ...
 depth, orient, gain, bias, res, freq, daq] = textread('hdrInfoAll3.csv', ...
   '%d %d %d %d %d %d %d %d %s %d %s %s %f %f %f %f %f %f %d %f %f %d %d %d',  'delimiter', ',' , 'headerlines',1);
time1=epoch2Matlab(epoch);    % meta is UTC

% Find the unique gauge IDs from all the keys
IDs = unique(a(:,6));
ic=0;
deploy=[];

for i=1:length(IDs)
	if (IDs(i) >= 9000); continue; end;             % >= 9000 is a test gauge, skip
	if (IDs(i) < 1); continue; end;                 % negative ID is a test gauge, skip
	ic = ic + 1;
	ID(ic)=IDs(i);
	% figure out deployments
	% get times of keys
   tk=find(a(:,6) == ID(ic));       % get all records for this ID
%   hh=floor(a(tk,4)/100);   % hour
%   mm=mod(a(tk,4),100);     % minute
%   stime=datenum(a(tk,1), a(tk,2), a(tk,3), hh, mm, 0)+est2Utc;    % time of all keys for this ID
   stime=datenum(a(tk,1), a(tk,2), a(tk,3), a(tk,4), a(tk,5), 0)+est2Utc;    % time of all keys for this ID

	% number of deployment (change in headers)
   nd = find(id == ID(ic));                     % each new TS header (from hdrInfoAll3.csv)
	for j=1:length(nd)
		deploy(ic).start(j) = time1(nd(j));       % starts at change in header
		if (j == length(nd))                      % last header change
			deploy(ic).stop(j) = stime(end);       % no more header changes, stop at last key
		else                                      %  
			tt=find(stime < time1(nd(j+1)));          % all times before next deployment
			if (isempty(tt))                          % no more deployments so use last key time
				deploy(ic).stop(j) = stime(end);       % no more header changes, stop at last key
			else
				deploy(ic).stop(j) = stime(tt(end));   % stop before next change in header
			end
		end
		deploy(ic).type(j) = type(nd(j));
		gg=find(gt == type(nd(j)));
		if (isempty(gg))
			deploy(ic).gtype(j) = '';
		else
			deploy(ic).gtype(j) = gname(gg);
		end
		deploy(ic).ID = ID(ic);
		deploy(ic).name{j} = name(nd(j));
		deploy(ic).lat(j) = lat(nd(j));
		deploy(ic).lon(j) = lon(nd(j));
		deploy(ic).X(j) = X(nd(j));
		deploy(ic).Y(j) = Y(nd(j));
		deploy(ic).Z(j) = Z(nd(j));
		deploy(ic).depth(j) = depth(nd(j));
		deploy(ic).sn{j} = sn(nd(j));
		deploy(ic).manufacturer{j} = manufacturer(nd(j));
	end
end	

save('vaxDeployTimes.mat','ID','deploy');




