%% *********************  CombineMET  ************************** 
%  - Reads processed code from vaxTS2_10minWind and
%  compares/combines the gauges to create a fully 
%  processed/polished output 10 min stats from the MET data 
%
%          Created Jul - 10 - 2014  - SB
%           Modified - several times final - 8-1-14
% compares between gauges
% first takes direction component between 9 and 8, always takes upwind
% gauge.  then compares 9/8 to 7 
% for  7 uses a 1-3 m/s threshold 
% for 6 uses a 5% threshold
% if any of the data doesn't have a comparison the QC flag is changed to a
% 2 for questionable


% To do: 
%  
% 

clear all
gaugeIDs= [932,933; 832,833; 732,733; 632,633]; % a list of all gauge ID's to be looked at 
gtype='Wind_speed';
th_speed=5;  %Threshold for speed comparision 
th=0.05;  % threshold for comparison values
t_high=1+th;
t_low=1-th;
D_th=7;
figOff= 1;   % 1=visible off for plots
months = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];

if ~exist( 'outputdata/derivedproduct' , 'dir')  
  mkdir( 'outputdata/derivedproduct' );
end





disp '__________________________________________________________________'
disp '_________________CombineMET CODE STARTS HERE _____________________'
disp '__________________________________________________________________'


for yr=1986         % looping through all years
   for mon=1:12     %looping through months
      disp ' ----------New Year--------------'
      M_stat10=[];
      MQC=[];
      MtsMeta=[];
%*****************Load Data Section **********************************
 %*********************************************************************
      for yy=1:4 % length(gaugeIDs)     %loop through gauges load files and set up master time
         IDsp(yy)=gaugeIDs(yy,1);    
         Mfile=sprintf('outputdata/matFile/vax_10min_%s_%d_%4d%02d.mat', gtype, IDsp(yy), yr, mon);
         if exist(Mfile,'file')
            disp(sprintf('**Loading month=%d - year=%d - gauge=%d**',mon,yr,IDsp(yy)));
            load (Mfile)
            stat10_temp=stat10;
            M_stat10=[M_stat10 stat10_temp];
         
            QC_temp=QC;
            MQC=[MQC QC_temp];
            
            M_tsMeta_temp=tsMeta;
            MtsMeta=horzcat(MtsMeta, M_tsMeta_temp);
  
         else
            disp(sprintf('MET Data file: %s does not exist.*****', Mfile));            
         end
      end
      if isempty(M_stat10)
         break
      end
%Test SEction      
      % Delete these after testing - this is just to kill three 932
      % records, shuld then try 832, 732, ...
%      M_stat10(1).time(10) = NaN;
%      M_stat10(1).time(100) = NaN;
%      M_stat10(1).time(1000) = NaN;
%      M_stat10(1).qcFlag(5:10)=3;
%      M_stat10(2).qcFlag(5:10)=3;
%        M_stat10(1).vdir(5:100)=300;
%        M_stat10(2).vdir(5:100)=300;
%%********************* Output Record Initilization**********************
%output file names
matFile=sprintf('outputdata/derivedproduct/wind_Derived_%4d%02d.mat', yr, mon);
fnamePNG = sprintf('outputdata/derivedproduct/windQC_Derived_%d%02d.png', yr, mon);
t_min=[];t_max=[];
        M_t=[];
        for  ss=1:length(M_stat10)
            t_min(ss)=min(M_stat10(ss).time);
            t_max(ss)=max(M_stat10(ss).time);
        end
        tmin=min(t_min);
        tmax=max(t_max);
        %datestr(tmin)
        %datestr(tmax)

        t=10/(60*24);  %decimal days for 1/10 min
        M_t=tmin:t:tmax;

        % Initialize M_Stat10(5) output data  ***************

        M_stat10(5).ID=-999;
        M_stat10(5).file=-999;
        M_stat10(5).type=-999;
        M_stat10(5).name='check meta';
        M_stat10(5).magcorr='check meta';
        M_stat10(5).filename='check meta';
        M_stat10(5).timezone='check meta';
        M_stat10(5).lat='check meta';
        M_stat10(5).lon='check meta';
        M_stat10(5).depth='check meta';
        M_stat10(5).depthP='check meta';
        M_stat10(5).time=-999;
        M_stat10(5).speed=-999;
        M_stat10(5).vspeed=-999;
        M_stat10(5).sust=-999;
        M_stat10(5).gust=-999;
        M_stat10(5).vdir=-999;
        M_stat10(5).maxSp=-999;
        M_stat10(5).minSp=-999;
        M_stat10(5).stdSp=-999;
        M_stat10(5).metaNum=-999;
        M_stat10(5).qcNum=-999;
        M_stat10(5).qcFlag=-999;
%write the tsMeta for every gauge
            a=size(MtsMeta);
            for pp=1:a(1,1)
   
                M_tsMeta(pp).ID= MtsMeta(pp).id;
                M_tsMeta(pp).lat=MtsMeta(pp).lat;
                M_tsMeta(pp).lon= MtsMeta(pp).lon;
                M_tsMeta(pp).X=MtsMeta(pp).X;
                M_tsMeta(pp).Y= MtsMeta(pp).Y;
                M_tsMeta(pp).Z=MtsMeta(pp).Z;
                M_tsMeta(pp).manufacturer= MtsMeta(pp).manufacturer;
                M_tsMeta(pp).sn=MtsMeta(pp).sn;
            end





        rn=1;  % initialize output record counter

        
%**********************************************************************
%%********************* Data Manipulation Section**********************
%**********************************************************************      
        for tt=1:length(M_t)     %run through 10 min increments every record
            WI=0;  % resetting the write index 
            %ii=1;
            % Get a time record index for each gauge, set = ii for appropriate gauge decision
            AA1=find(abs(M_stat10(1).time-M_t(tt)) < 10e-6); 
            AA2=find(abs(M_stat10(2).time-M_t(tt)) < 10e-6);
            AA3=find(abs(M_stat10(3).time-M_t(tt)) < 10e-6);
            AA4=find(abs(M_stat10(4).time-M_t(tt)) < 10e-6);
            % was finding 2 values at times in AA's  
            if length(AA1)>1        
                AA1=AA1(1);
            end
            if length(AA2)>1
                AA2=AA2(1);
            end
            if length(AA3)>1
                AA3=AA3(1);
            end
            if length(AA4)>1
                AA4=AA4(1);
            end
               
            
            
%_________________________1_______(flag 1)_____________________________
            if ~isempty(AA1) && M_stat10(1).qcFlag(AA1)<=1  % if 932 exist & qc check
                if ~isempty(AA2) && M_stat10(2).qcFlag(AA2)<=1  % 832 exist & QC check
                   if (M_stat10(1).ID==932) && (M_stat10(2).ID == 832)  % direction Comparison/Decision
                      
                       %check if it's in the 932 preferable shadow range
                       if (M_stat10(1).vdir(AA1) <=150 ) && (M_stat10(1).vdir(AA1) >= 60) || (M_stat10(2).vdir(AA2) <=150 ) && (M_stat10(2).vdir(AA2) >= 60) % large 932 check 
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3  % large value, in the shadow zone
                                WI=1;ii=AA1; %take 1
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=1;ii=AA1; % take 932
                              elseif abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=1;ii=AA1;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                WI=1;ii=AA1; % take 932
                              elseif  (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                  if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                  else
                                      WI=1;ii=AA1;
                                  end
                              else
                                  WI=1;ii=AA1;
                              end
                          else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end 
                      %check to see if its in the 832 preferable shadow range      
                      elseif (M_stat10(2).vdir(AA2) <= 330) && (M_stat10(2).vdir(AA2) >=240) || (M_stat10(1).vdir(AA1) <= 330) && (M_stat10(1).vdir(AA1) >=240)% if its between 240 and 330 use 832
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3  % large value, in the shadow zone
                                WI=2;ii=AA2; %take 2
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=2;ii=AA2; % take 832
                              elseif abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=1;ii=AA1;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(1).qcFlag(AA1)<=2
                                        WI=1;ii=AA1;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=2;ii=AA2;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                WI=2;ii=AA2; % take 832
                              elseif  (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(1).qcFlag(AA1)<=1
                                        WI=1;ii=AA1;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(1).qcFlag(AA1)<=2
                                        WI=1;ii=AA1;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                  if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                  else
                                      WI=2;ii=AA2;
                                  end
                              else
                                  WI=2;ii=AA2;
                              end
                          else
                                WI=2;ii=AA2;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end 
                         
                      %check to see if it's in a non-shadow effected
                      %direction
                      elseif ((M_stat10(1).vdir(AA1)>150 && M_stat10(1).vdir(AA1)<240) || M_stat10(1).vdir(AA1)>330 || M_stat10(1).vdir(AA1) <60) || ((M_stat10(2).vdir(AA2)>150 && M_stat10(2).vdir(AA2)<240) || M_stat10(2).vdir(AA2)>330 || M_stat10(2).vdir(AA2) <60)%    small 932 check
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=1  % large value, in the shadow zone
                                WI=1;ii=AA1; %take 1
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=1;ii=AA1; % take 932
                              elseif abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=1;ii=AA1;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                  WI=1;ii=AA1; % take 932
                              elseif  (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                    if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    else
                                      WI=1;ii=AA1;
                                    end
                              else
                                  WI=1;ii=AA1;
                              end
                          else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end  
                      
                      else
                        disp 'directions do not FIT  for 932 & 832 '
                      end
                  % gauge ID's aren't 1 and 2 - 932/832   - this shouldn't happen (very often)               
                elseif (M_stat10(1).ID  ~=932) || (M_stat10(2).ID ~= 832)
                            if  ~isempty(AA2) &&  abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))>=1  % 1 compares to 3, between 1 and 3 m/s  % 1 compares to 3
                                WI=1;ii=AA1; % take 932
                            elseif ~isempty(AA3) && (M_stat10(1).speed(AA1)>= M_stat10(3).speed(AA3)*t_low && M_stat10(1).speed(AA3)<= M_stat10(3).speed(AA3)*t_high)  % 1 compares to 4
                                WI=1;ii=AA1; % take 932
                            elseif ~isempty(AA4) 
                                if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                                    WI=1;ii=AA1; % take 932
                                elseif (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    else
                                        WI=1;ii=AA1;
                                    end
                                end
                            else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2; 
 %                               disp(sprintf('<DAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                            end
                end
                  
%2 doesn't exist, compare 1 to 3 / 4    
                elseif ~isempty(AA3)  && M_stat10(3).qcFlag(AA3)<=1
                           % 1-3m/s threshold for comparing 1 to 3, 
                           % no speed thres for 4, use 5%
                        if  ~isempty(AA3) && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1 % 1 compares to 3, between 1 and 3 m/s
                                WI=1;ii=AA1; % take 932
                        elseif ~isempty(AA4)   % if 4 exists and good check against 1 and 3 
                             if(M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                                WI=1;ii=AA1; % take 932
                             elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                WI=3;ii=AA3; % take 732                       
                             end
                        else
                            WI=1;ii=AA1;
%                            M_stat10(1).qcFlag(AA1)=2; % change qcFlag when can't compare to anything
%                            disp(sprintf('<EAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                        end
% 2 doesn't exist, compare 1 to 4        
                elseif ~isempty(AA4) && M_stat10(4).qcFlag(AA4)<=1  % if 4 is good
                       if(M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                           WI=1;ii=AA1; % take 932
                       end
% There are no QC flags 1 or below for gauges >2
% 2 becomes acceptable to take data, still prefer 1 (1 has QC flag of >1)
                elseif ~isempty(AA2) && M_stat10(2).qcFlag(AA2)<=2
                    if (M_stat10(1).ID==932) && (M_stat10(2).ID == 832)  % direction Comparison/Decision
                      
                        %check if it's in the 932 preferable shadow range
                       if (M_stat10(1).vdir(AA1) <=150 ) && (M_stat10(1).vdir(AA1) >= 60) || (M_stat10(2).vdir(AA2) <=150 ) && (M_stat10(2).vdir(AA2) >= 60) % large 932 check 
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3  % large value, in the shadow zone
                                WI=1;ii=AA1; %take 1
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=1;ii=AA1; % take 932
                              elseif abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=1;ii=AA1;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                WI=1;ii=AA1; % take 932
                              elseif  (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                  if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                  else
                                      WI=1;ii=AA1;
                                  end
                              else
                                  WI=1;ii=AA1;
                              end
                          else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end 
                      %check to see if its in the 832 preferable shadow range      
                     elseif (M_stat10(2).vdir(AA2) <= 330) && (M_stat10(2).vdir(AA2) >=240) || (M_stat10(1).vdir(AA1) <= 330) && (M_stat10(1).vdir(AA1) >=240)% if its between 240 and 330 use 832
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3  % large value, in the shadow zone
                                WI=2;ii=AA2; %take 2
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=2;ii=AA2; % take 832
                              elseif abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=1;ii=AA1;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(1).qcFlag(AA1)<=2
                                        WI=1;ii=AA1;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=2;ii=AA2;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                WI=2;ii=AA2; % take 832
                              elseif  (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                  if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                  else
                                      WI=2;ii=AA2;
                                  end
                              else
                                  WI=2;ii=AA2;
                              end
                          else
                                WI=2;ii=AA2;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end 
                         
                         
                      %check to see if it's in a non-shadow effected
                      %direction
                      elseif ((M_stat10(1).vdir(AA1)>150 && M_stat10(1).vdir(AA1)<240) || M_stat10(1).vdir(AA1)>330 || M_stat10(1).vdir(AA1) <60) || ((M_stat10(2).vdir(AA2)>150 && M_stat10(2).vdir(AA2)<240) || M_stat10(2).vdir(AA2)>330 || M_stat10(2).vdir(AA2) <60)%    small 932 check
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=1  % large value, in the shadow zone
                                WI=1;ii=AA1; %take 1
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=1;ii=AA1; % take 932
                              elseif abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=1;ii=AA1;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                  WI=1;ii=AA1; % take 932
                              elseif  (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                    if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    else
                                      WI=1;ii=AA1;
                                    end
                              else
                                  WI=1;ii=AA1;
                              end
                          else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end  
                      
                      else
                        disp 'directions do not FIT  for 932 & 832 '
                      end
                  % gauge ID's aren't 1 and 2 - 932/832   - this shouldn't happen (very often)               
                elseif (M_stat10(1).ID  ~=932) || (M_stat10(2).ID ~= 832)
                            if  ~isempty(AA2) &&  abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))>=1  % 1 compares to 3, between 1 and 3 m/s  % 1 compares to 3
                                WI=1;ii=AA1; % take 932
                            elseif ~isempty(AA3) && (M_stat10(1).speed(AA1)>= M_stat10(3).speed(AA3)*t_low && M_stat10(1).speed(AA3)<= M_stat10(3).speed(AA3)*t_high)  % 1 compares to 4
                                WI=1;ii=AA1; % take 932
                            elseif ~isempty(AA4) 
                                if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                                    WI=1;ii=AA1; % take 932
                                elseif (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    else
                                        WI=1;ii=AA1;
                                    end
                                end
                            else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2; 
%                                disp(sprintf('<DAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                            end
                end
                                    
% 1's and 2's don't work even with QC flag=2                   
                 elseif ~isempty(AA3)  && M_stat10(3).qcFlag(AA3)<=2
                           %no speed threshold for comparing 1 to 3/4
                        if  ~isempty(AA2) &&  abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))>=1  % 1 compares to 3, between 1 and 3 m/s  % 1 compares to 3
                                WI=1;ii=AA1; % take 932
                        elseif ~isempty(AA4) && M_stat10(4).qcFlag(AA4)<=2  % if 4 exists and good check against 1 and 3 
                             if(M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                                WI=1;ii=AA1; % take 932
                             elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                WI=3;ii=AA3; % take 732                       
                             end
                        else
                             WI=1;ii=AA1;
%                              M_stat10(1).qcFlag(AA1)=2; 
%                               disp(sprintf('<JAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                        end
                % 2 doesn't exist, compare 1 to 4        
                elseif ~isempty(AA4) && M_stat10(4).qcFlag(AA4)<=2  % if 4 is good
                       if(M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                           WI=1;ii=AA1; % take 932
                       end
                else
                    WI=1;ii=AA1;
%                    M_stat10(1).qcFlag(AA1)=2; % change qcFlag when can't compare to anything
%                    disp(sprintf('<KAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                end
 % __________________2_________(flag 1)___________________________               
 % 1 is NO GOOD, bad flag or doesn't exist               
 % 1 is empty or doesn't pass test - -- 2 compare 3/4   - TAKE 2
            elseif ~isempty(AA2) && M_stat10(2).qcFlag(AA2)<=1  % if 2 is good has flag of 1
                if ~isempty(AA3) &&  abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1  % 2 compares to 3, between 1 and 3 m/s  % 2 compares to 3
                           WI=2;ii=AA2; % take 2     
                elseif  ~isempty(AA4) &&(M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high) %4 exist
                           WI=2; ii=AA2; % take 2
                else
                    WI=2;ii=AA2;
%                    M_stat10(2).qcFlag(AA2)=2; % change qcFlag when can't compare to anything
%                    disp(sprintf('<LAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                end
 % __________________3_________(flag 1)___________________________                 
            % 1 and 2 are empty / don't pass - check 3
            elseif ~isempty(AA3) && M_stat10(3).qcFlag(AA3)<=1 % 3 exists and checks
                if ~isempty(AA4 ) && (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high) % 4 exists and compares 
                    WI=3;ii=AA3; % take 3
                else
                     WI=3;ii=AA3; % take 3
%                     M_stat10(3).qcFlag(AA3)=2; % change qcFlag when can't compare to anything
%                    disp(sprintf('<MAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                end
% __________________4_________(flag 1)___________________________                
                % 1 and 2 and 3 are empty/don't pass - check 4
            elseif ~isempty(AA4) && M_stat10(4).qcFlag(AA4)<=1
               WI=4;ii=AA4;
%               M_stat10(4).qcFlag(AA4)=2; % change qcFlag when can't compare to anything
%***********************QC>=2***********************************
%all flags are 2 or above
% __________________1_________(flag 2)___________________________
            elseif ~isempty(AA1) && M_stat10(1).qcFlag(AA1)<=2  % if 932 exist & qc check
                if ~isempty(AA2) && M_stat10(2).qcFlag(AA2)<=2  % 832 exist & QC check
                    if (M_stat10(1).ID==932) && (M_stat10(2).ID == 832)  % direction Comparison/Decision
                    
                        %check if it's in the 932 preferable shadow range
                       if (M_stat10(1).vdir(AA1) <=150 ) && (M_stat10(1).vdir(AA1) >= 60) || (M_stat10(2).vdir(AA2) <=150 ) && (M_stat10(2).vdir(AA2) >= 60) % large 932 check 
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3  % large value, in the shadow zone
                                WI=1;ii=AA1; %take 1
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=1;ii=AA1; % take 932
                              elseif abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=1;ii=AA1;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                WI=1;ii=AA1; % take 932
                              elseif  (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                  if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                  else
                                      WI=1;ii=AA1;
                                  end
                              else
                                  WI=1;ii=AA1;
                              end
                          else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end 
                      %check to see if its in the 832 preferable shadow range      
                      elseif (M_stat10(2).vdir(AA2) <= 330) && (M_stat10(2).vdir(AA2) >=240) || (M_stat10(1).vdir(AA1) <= 330) && (M_stat10(1).vdir(AA1) >=240)% if its between 240 and 330 use 832
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3  % large value, in the shadow zone
                                WI=2;ii=AA2; %take 2
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=2;ii=AA2; % take 832
                              elseif abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=1;ii=AA1;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(1).qcFlag(AA1)<=2
                                        WI=1;ii=AA1;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=2;ii=AA2;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                WI=2;ii=AA2; % take 832
                              elseif  (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(1).qcFlag(AA1)<=1
                                        WI=1;ii=AA1;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(1).qcFlag(AA1)<=2
                                        WI=1;ii=AA1;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                  if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                  else
                                      WI=2;ii=AA2;
                                  end
                              else
                                  WI=2;ii=AA2;
                              end
                          else
                                WI=2;ii=AA2;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end 
                         
                      %check to see if it's in a non-shadow effected
                      %direction
                      elseif ((M_stat10(1).vdir(AA1)>150 && M_stat10(1).vdir(AA1)<240) || M_stat10(1).vdir(AA1)>330 || M_stat10(1).vdir(AA1) <60) || ((M_stat10(2).vdir(AA2)>150 && M_stat10(2).vdir(AA2)<240) || M_stat10(2).vdir(AA2)>330 || M_stat10(2).vdir(AA2) <60)%    small 932 check
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=1  % large value, in the shadow zone
                                WI=1;ii=AA1; %take 1
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=1;ii=AA1; % take 932
                              elseif abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=1;ii=AA1;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                  WI=1;ii=AA1; % take 932
                              elseif  (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                    if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    else
                                      WI=1;ii=AA1;
                                    end
                              else
                                  WI=1;ii=AA1;
                              end
                          else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end  
                      
                      else
                        disp 'directions do not FIT  for 932 & 832 '
                      end
                  % gauge ID's aren't 1 and 2 - 932/832   - this shouldn't happen (very often)               
                elseif (M_stat10(1).ID  ~=932) || (M_stat10(2).ID ~= 832)
                            if  ~isempty(AA2) &&  abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))>=1  % 1 compares to 3, between 1 and 3 m/s  % 1 compares to 3
                                WI=1;ii=AA1; % take 932
                            elseif ~isempty(AA3) && (M_stat10(1).speed(AA1)>= M_stat10(3).speed(AA3)*t_low && M_stat10(1).speed(AA3)<= M_stat10(3).speed(AA3)*t_high)  % 1 compares to 4
                                WI=1;ii=AA1; % take 932
                            elseif ~isempty(AA4) 
                                if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                                    WI=1;ii=AA1; % take 932
                                elseif (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    else
                                        WI=1;ii=AA1;
                                    end
                                end
                            else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2; 
%                                disp(sprintf('<DAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                            end
                end
                    
%2 doesn't exist, compare 1 to 3 / 4    
                elseif ~isempty(AA3)  && M_stat10(3).qcFlag(AA3)<=1
                           % 1-3m/s threshold for comparing 1 to 3, 
                           % no speed thres for 4, use 5%
                        if  ~isempty(AA3) && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1 % 1 compares to 3, between 1 and 3 m/s
                                WI=1;ii=AA1; % take 932
                        elseif ~isempty(AA4)   % if 4 exists and good check against 1 and 3 
                             if(M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                                WI=1;ii=AA1; % take 932
                             elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                WI=3;ii=AA3; % take 732                       
                             end
                        else
                            WI=1;ii=AA1;
%                            M_stat10(1).qcFlag(AA1)=2; % change qcFlag when can't compare to anything
%                            disp(sprintf('<RAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                        end
% 2 doesn't exist, compare 1 to 4        
                elseif ~isempty(AA4) && M_stat10(4).qcFlag(AA4)<=1  % if 4 is good
                       if(M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                           WI=1;ii=AA1; % take 932
                       end
% There are no QC flags 1 or below for gauges >2
% 2 becomes acceptable to take data, still prefer 1 (1 has QC flag of >1)
                elseif ~isempty(AA2) && M_stat10(2).qcFlag(AA2)<=2
                    if (M_stat10(1).ID==932) && (M_stat10(2).ID == 832)  % direction Comparison/Decision
                      
                        %check if it's in the 932 preferable shadow range
                       if (M_stat10(1).vdir(AA1) <=150 ) && (M_stat10(1).vdir(AA1) >= 60) || (M_stat10(2).vdir(AA2) <=150 ) && (M_stat10(2).vdir(AA2) >= 60) % large 932 check 
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3  % large value, in the shadow zone
                                WI=1;ii=AA1; %take 1
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=1;ii=AA1; % take 932
                              elseif abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=1;ii=AA1;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                WI=1;ii=AA1; % take 932
                              elseif  (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                  if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                  else
                                      WI=1;ii=AA1;
                                  end
                              else
                                  WI=1;ii=AA1;
                              end
                          else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end 
                      %check to see if its in the 832 preferable shadow range      
                      elseif (M_stat10(2).vdir(AA2) <= 330) && (M_stat10(2).vdir(AA2) >=240) || (M_stat10(1).vdir(AA1) <= 330) && (M_stat10(1).vdir(AA1) >=240)% if its between 240 and 330 use 832
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3  % large value, in the shadow zone
                                WI=2;ii=AA2; %take 2
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=2;ii=AA2; % take 832
                              elseif abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=1;ii=AA1;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(1).qcFlag(AA1)<=2
                                        WI=1;ii=AA1;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=2;ii=AA2;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                WI=2;ii=AA2; % take 832
                              elseif  (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(1).qcFlag(AA1)<=1
                                        WI=1;ii=AA1;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(1).qcFlag(AA1)<=2
                                        WI=1;ii=AA1;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                  if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                  else
                                      WI=2;ii=AA2;
                                  end
                              else
                                  WI=2;ii=AA2;
                              end
                          else
                                WI=2;ii=AA2;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end 
                         
                      %check to see if it's in a non-shadow effected
                      %direction
                      elseif ((M_stat10(1).vdir(AA1)>150 && M_stat10(1).vdir(AA1)<240) || M_stat10(1).vdir(AA1)>330 || M_stat10(1).vdir(AA1) <60) || ((M_stat10(2).vdir(AA2)>150 && M_stat10(2).vdir(AA2)<240) || M_stat10(2).vdir(AA2)>330 || M_stat10(2).vdir(AA2) <60)%    small 932 check
                          if abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=1  % large value, in the shadow zone
                                WI=1;ii=AA1; %take 1
                          elseif  ~isempty(AA3)  
                              if  abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(3).speed(AA3)))>=1    % 1 compares to 3, between 1 and 3 m/s
                                    WI=1;ii=AA1; % take 932
                              elseif abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1    % 2 compares to 3, between 1 and 3 m/s
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    else
                                        WI=1;ii=AA1;
                                    end
                              else   
                                  WI=1;ii=AA1;
                              end
                          elseif ~isempty(AA4) 
                              if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4 
                                  WI=1;ii=AA1; % take 932
                              elseif  (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)   % 2 compares to 4, 
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    end 
                              elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                    if M_stat10(3).qcFlag(AA3)<=1
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(3).qcFlag(AA3)<=2
                                        WI=3;ii=AA3;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    else
                                      WI=1;ii=AA1;
                                    end
                              else
                                  WI=1;ii=AA1;
                              end
                          else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2;
%                                disp(sprintf('<AAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                          end  
                      
                      else
                        disp 'directions do not FIT  for 932 & 832 '
                      end
                  % gauge ID's aren't 1 and 2 - 932/832   - this shouldn't happen (very often)               
                elseif (M_stat10(1).ID  ~=932) || (M_stat10(2).ID ~= 832)
                            if  ~isempty(AA2) &&  abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))>=1  % 1 compares to 3, between 1 and 3 m/s  % 1 compares to 3
                                WI=1;ii=AA1; % take 932
                            elseif ~isempty(AA3) && (M_stat10(1).speed(AA1)>= M_stat10(3).speed(AA3)*t_low && M_stat10(1).speed(AA3)<= M_stat10(3).speed(AA3)*t_high)  % 1 compares to 4
                                WI=1;ii=AA1; % take 932
                            elseif ~isempty(AA4) 
                                if (M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                                    WI=1;ii=AA1; % take 932
                                elseif (M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high)
                                    if M_stat10(2).qcFlag(AA2)<=1
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=1
                                        WI=4;ii=AA4;
                                    elseif M_stat10(2).qcFlag(AA2)<=2
                                        WI=2;ii=AA2;
                                    elseif M_stat10(4).qcFlag(AA4)<=2
                                        WI=4;ii=AA4;
                                    else
                                        WI=1;ii=AA1;
                                    end
                                end
                            else
                                WI=1;ii=AA1;
%                                M_stat10(1).qcFlag(AA1)=2; 
%                                disp(sprintf('<DAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                            end
                end
                  
% 1's and 2's don't work even with QC flag=2                   
                 elseif ~isempty(AA3)  && M_stat10(3).qcFlag(AA3)<=2
                           %no speed threshold for comparing 1 to 3/4
                        if  ~isempty(AA2) &&  abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))<=3 && abs((M_stat10(1).speed(AA1)-M_stat10(2).speed(AA2)))>=1  % 1 compares to 3, between 1 and 3 m/s  % 1 compares to 3
                                WI=1;ii=AA1; % take 932
                        elseif ~isempty(AA4) && M_stat10(4).qcFlag(AA4)<=2  % if 4 exists and good check against 1 and 3 
                             if(M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                                WI=1;ii=AA1; % take 932
                             elseif (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high)  % 3 compares to 4
                                WI=3;ii=AA3; % take 732                       
                             end
                        else
                             WI=1;ii=AA1;
%                               M_stat10(1).qcFlag(AA1)=2; 
%                               disp(sprintf('<WAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                        end
                % 2 doesn't exist, compare 1 to 4        
                elseif ~isempty(AA4) && M_stat10(4).qcFlag(AA4)<=2  % if 4 is good
                       if(M_stat10(1).speed(AA1)>= M_stat10(4).speed(AA4)*t_low && M_stat10(1).speed(AA1)<= M_stat10(4).speed(AA4)*t_high)  % 1 compares to 4
                           WI=1;ii=AA1; % take 932
                       end
                else
                    WI=1;ii=AA1;
%                    M_stat10(1).qcFlag(AA1)=2; % change qcFlag when can't compare to anything
%                    disp(sprintf('<XAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                end
% __________________2_________(flag 2)___________________________                
                % 1 is empty or doesn't pass test - -- 2 compare 3/4   - TAKE 2
            elseif ~isempty(AA2) && M_stat10(2).qcFlag(AA2)<=2  % if 2 is good
                if ~isempty(AA3) &&  abs((M_stat10(2).speed(AA2)-M_stat10(2).speed(AA3)))<=3 && abs((M_stat10(2).speed(AA2)-M_stat10(3).speed(AA3)))>=1  % 2 compares to 3, between 1 and 3 m/s  % 2 compares to 3
                           WI=2;ii=AA2; % take 2     
                elseif  ~isempty(AA4) &&(M_stat10(2).speed(AA2)>= M_stat10(4).speed(AA4)*t_low && M_stat10(2).speed(AA2)<= M_stat10(4).speed(AA4)*t_high) %4 exist
                           WI=2; ii=AA2; % take 2
                else
                    WI=2;ii=AA2;
%                    M_stat10(2).qcFlag(AA2)=2; % change qcFlag when can't compare to anything
%                    disp(sprintf('<YAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
                end
% __________________3_________(flag 2)___________________________                
                % 1 1 and 2 are empty / don't pass
            elseif ~isempty(AA3) && M_stat10(3).qcFlag(AA3)<=2 % 3 exists and checks
               if ~isempty(AA4 ) && (M_stat10(3).speed(AA3)>= M_stat10(4).speed(AA4)*t_low && M_stat10(3).speed(AA3)<= M_stat10(4).speed(AA4)*t_high) % 4 exists and compares 
                    WI=3;ii=AA3; % take 3
               else
                     WI=3;ii=AA3; % take 3
%                     M_stat10(3).qcFlag(AA3)=2; % change qcFlag when can't compare to anything
%                    disp(sprintf('<ZAA> Maybe Change The "th" threshold: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 
               end
% __________________4_________(flag 2)___________________________                
                % 1 and 2 and 3 are empty/don't pass
          
            elseif ~isempty(AA4) && M_stat10(4).qcFlag(AA4)<=2
               WI=4;ii=AA4;
% &&&&&&&&&&&&& PECULULIAR SCENARIO &&&&&&&&&&&&&&&
%            elseif (M_stat10(1).qcFlag(AA1)>2 && M_stat10(2).qcFlag(AA2)>2) || (M_stat10(1).qcFlag(AA1)>2 && M_stat10(2).qcFlag(AA2)>2 && M_stat10(3).qcFlag(AA3)>2)
%                WI=0;
            else %if (isempty(AA2) && isempty(AA3) && isempty(AA4)) || (M_stat10(2).qcFlag(AA2)>2 && M_stat10(3).qcFlag(AA3)>2 && M_stat10(4).qcFlag(AA4)>2) || (M_stat10(2).qcFlag(AA2)>2 && M_stat10(3).qcFlag(AA3)>2)  || (M_stat10(2).qcFlag(AA2)>2 && M_stat10(4).qcFlag(AA4)>2)|| (M_stat10(4).qcFlag(AA4)>2 && M_stat10(3).qcFlag(AA3)>2)  % 2 /3 /4 don't exist don't pass, 
                WI=0;
%                disp(sprintf(' Peculiar Scenario ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt)) 

%            else
%               disp ' you got a problem ' 
%               break;
            end
                
                
%------------------------------------------------------------------------
%                         Begin Write Process
%_______________________________________________________________________     
            
            % Was there a valid time for any gauge?  
            %- the end of the 3 hr  record
            if (WI == 0)   % did not find galid this for any gauge
                
                if rem(tt,18)==0
                   continue
                
                else
%                 disp(sprintf('<ZZ>  PRoblem point: ii=%d %s rn=%d tt=%d',ii, datestr(M_t(tt)), rn, tt))
                 xxtime=M_t(tt);
                    continue     % to next time
                end
            end
            
            % Save/Write the data 
%            ii=ii2;      % find ii again for keeper gauge
            
            M_stat10(5).ID(rn)=M_stat10(WI).ID;
           
            M_stat10(5).time(rn)=M_stat10(WI).time(ii);
            M_stat10(5).speed(rn)=M_stat10(WI).speed(ii);
            M_stat10(5).vspeed(rn)=M_stat10(WI).vspeed(ii);
            M_stat10(5).sust(rn)=M_stat10(WI).sust(ii);
            M_stat10(5).gust(rn)=M_stat10(WI).gust(ii);
            M_stat10(5).vdir(rn)=M_stat10(WI).vdir(ii);
            M_stat10(5).maxSp(rn)=M_stat10(WI).maxSp(ii);
            M_stat10(5).minSp(rn)=M_stat10(WI).minSp(ii);
            M_stat10(5).stdSp(rn)=M_stat10(WI).stdSp(ii);
            M_stat10(5).metaNum(rn)=M_stat10(WI).metaNum(ii);
            M_stat10(5).qcNum(rn)=WI;
            M_stat10(5).qcFlag(rn)=M_stat10(WI).qcFlag(ii);

%            M_QC.time(rn)=MQC(WI).time(ii);
%            M_QC.mean(rn)=MQC(WI).mean(ii);
%            M_QC.meanStd(rn)=MQC(WI).meanStd(ii);
%            M_QC.stdMean(rn)=MQC(WI).stdMean(ii);
%            M_QC.stdStd(rn)=MQC(WI).stdStd(ii);
%            M_QC.ptsEdited(rn)=MQC(WI).ptsEdited(ii);
%            M_QC.ptsEdited2(rn)=MQC(WI).ptsEdited2(ii);
%            M_QC.bitFlagS(rn)=MQC(WI).bitFlagS(ii);
%            M_QC.bitFlagD(rn)=MQC(WI).bitFlagD(ii);
            
            %         disp(sprintf('Gauge Written = %d Write Record Number =%d',  M_stat10(5).ID(rn),rn));
       
        rn = rn + 1;    % increment record counter - note it will be 
                            % one more than valid data when finished
           
        end       % for tt loop run through 10 min increments
%% ______________plotting Section______________________________

% (((((((((((((((((((((((  PLOT 1  )))))))))))))))))))))))))))))))))))
if (figOff == 1)
	f1=figure('visible','off');
else
	f1=figure;
end

AI([1,2])=subplot (2,2,[1,2]);  % Speeds 
    scatter(M_stat10(5).time,M_stat10(5).speed,'filled');hold on;
    scatter(M_stat10(1).time,M_stat10(1).speed,'x'); 
    scatter(M_stat10(2).time,M_stat10(2).speed,'x');
    scatter(M_stat10(3).time,M_stat10(3).speed,'x');  
    scatter(M_stat10(4).time,M_stat10(4).speed,'x');
  
datetick( 'x',2, 'keepticks')
txt_T=sprintf('Derived Speeds ');
txt_x=sprintf('Month: %d Year: %d',mon,yr);
txt_y=sprintf('speed m/s');
title (txt_T)
xlabel(txt_x)
ylabel(txt_y)
if ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(2).ID) && ~isempty(M_stat10(3).ID) && ~isempty(M_stat10(4).ID)  && ~isempty(M_stat10(5).ID) 
    legend('Speed-Derived','Speed-932','Speed-832','Speed-732','Speed-632');
elseif  ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(2).ID) && ~isempty(M_stat10(3).ID) && ~isempty(M_stat10(5).ID) 
    legend('Speed-Derived','Speed-932','Speed-832','Speed-732');
elseif ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(2).ID)  && ~isempty(M_stat10(5).ID) 
    legend('Speed-Derived','Speed-932','Speed-832');
elseif ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(3).ID)  && ~isempty(M_stat10(5).ID) 
     legend('Speed-Derived','Speed-932','Speed-732');
elseif ~isempty(M_stat10(2).ID) && ~isempty(M_stat10(3).ID)  && ~isempty(M_stat10(5).ID) 
     legend('Speed-Derived','Speed-832','Speed-732');
elseif ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(5).ID)
    legend('Speed-Derived','Speed 932')
end
    
    grid on;

AI(3)=subplot (2,2,3);  %IDS
    scatter(M_stat10(5).time,M_stat10(5).ID,4); hold on;

datetick( 'x',2, 'keepticks')
txt_T=sprintf('Chosen Gauge IDs  ');
txt_x=sprintf('Month: %d Year: %d',mon,yr);
txt_y=sprintf(' ID number ');
title (txt_T)
xlabel(txt_x)
ylabel(txt_y)
grid on;

AI(4)=subplot(2,2,4);% QC FLAGS
   scatter(M_stat10(5).time,M_stat10(5).qcFlag,'filled','b'); hold on;
   scatter(M_stat10(1).time,M_stat10(1).qcFlag,'r','x');
   scatter(M_stat10(2).time,M_stat10(2).qcFlag,'g', 'x');
   scatter(M_stat10(3).time,M_stat10(3).qcFlag,'c','x');
   
datetick( 'x',2, 'keepticks')
txt_T=sprintf(' QC Flags of All Gauges ');
txt_x=sprintf('Month: %d Year: %d',mon,yr);
txt_y=sprintf('QC Flag Value');
title (txt_T)
%xlabel(txt_x)
ylabel(txt_y)
if ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(2).ID) && ~isempty(M_stat10(3).ID) && ~isempty(M_stat10(4).ID)  && ~isempty(M_stat10(5).ID) 
    legend('QC-Derived','Q-932','QC-832','QC-732','QC-632');
elseif  ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(2).ID) && ~isempty(M_stat10(3).ID) && ~isempty(M_stat10(5).ID) 
    legend('QC-Derived','QC-932','QC-832','QC-732');
elseif ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(2).ID)  && ~isempty(M_stat10(5).ID) 
    legend('QC-Derived','QC-932','QC-832');
elseif ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(3).ID)  && ~isempty(M_stat10(5).ID) 
     legend('QC-Derived','QC-932','QC-732');
elseif ~isempty(M_stat10(2).ID) && ~isempty(M_stat10(3).ID)  && ~isempty(M_stat10(5).ID) 
     legend('QC-Derived','QC-832','QC-732');
elseif ~isempty(M_stat10(1).ID) && ~isempty(M_stat10(5).ID)
    legend('QC-Derived','QC-932')
end
grid on
linkaxes(AI,'x')

%subplot(2,2,2)% Directions
%    plot(M_stat10(5).time,M_stat10(5).vdir,'.');
%datetick( 'x',2, 'keepticks')
%txt_T=sprintf(' Direction ');
%txt_x=sprintf('Month: %d',mon);
%txt_y=sprintf(' Degrees ');
%title (txt_T)
%xlabel(txt_x)
%ylabel(txt_y)    
    

%ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');

%text(0.5, 1,'\bf QC check ','HorizontalAlignment','center','VerticalAlignment', 'Top')    

%% Save output    
stat10=M_stat10(5);
%QC=M_QC;
tsMeta=M_tsMeta;
%save the picture
print(f1, '-dpng','-r300', fnamePNG)    
%save matlab file 
 if (length(stat10.time) > 1)
	save(matFile,'stat10','tsMeta');    %,'QC'
 end
    
   
   end            % month loop
end               % year loop
        
 
