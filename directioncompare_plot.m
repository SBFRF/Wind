%% quick and dirty plot of speed difference (932/832) and direction
% this is to check to see. if directionality matters because at certian
% directions one gauge is downwind of another

% ***********TO DO **************
% write a code to analyze Direction difference with Direction
close all

    File932_9=load('vax_10min_Wind_speed_932_201209.mat');
    File832_9=load('vax_10min_Wind_speed_832_201209.mat');
    File732_9=load('vax_10min_Wind_speed_732_201209.mat');
    s_932_9=File932_9.stat10.speed;
    s_832_9=File832_9.stat10.speed;
    s_732_9=File732_9.stat10.speed;
    d_932_9=File932_9.stat10.vdir;
    d_832_9=File832_9.stat10.vdir;
    d_732_9=File732_9.stat10.vdir;
    diff_9=s_832_9-s_932_9;
    diff_97=s_732_9-s_932_9;
    diff_9p=(s_832_9-s_932_9)./s_932_9*100;
    diff_9p7=(s_732_9-s_932_9)./s_932_9*100;
    diff_98=s_732_9-s_832_9;
    diff_D_9=d_932_9-d_832_9;
    diff_D_9p=(d_932_9- d_832_9)./d_932_9*100;


File932_8=load('vax_10min_Wind_speed_932_201208.mat');
    File832_8=load('vax_10min_Wind_speed_832_201208.mat');
    s_932_8=File932_8.stat10.speed;
    s_832_8=File832_8.stat10.speed;
    d_932_8=File932_8.stat10.vdir;
    d_832_8=File832_8.stat10.vdir;
    diff_8=s_832_8-s_932_8;
    diff_8p=(s_832_8-s_932_8)./s_932_8*100;
    diff_D_8=d_932_8-d_832_8;
    diff_D_8p=(d_932_8- d_832_8)./d_932_8*100;
File732_8=load('vax_10min_Wind_speed_732_201208.mat');    
s_732_8=File732_8.stat10.speed;
 d_732_8=File732_8.stat10.vdir;
diff_87=s_732_8-s_932_8;
diff_88=s_732_8-s_832_8;
 diff_8p7=(s_732_8-s_932_8)./s_932_8*100;

    


File932_7=load('vax_10min_Wind_speed_932_201207.mat');
    File832_7=load('vax_10min_Wind_speed_832_201207.mat');
    s_932_7=File932_7.stat10.speed;
    s_832_7=File832_7.stat10.speed;
    d_932_7=File932_7.stat10.vdir;
    d_832_7=File832_7.stat10.vdir;
    diff_7=s_832_7-s_932_7;
    diff_7p=(s_832_7-s_932_7)./s_932_7*100;
    diff_D_7=d_932_7- d_832_7;
    diff_D_7p=(d_932_7- d_832_7)./d_932_7*100;
File732_7=load('vax_10min_Wind_speed_732_201207.mat');    
s_732_7=File732_7.stat10.speed;
 d_732_7=File732_7.stat10.vdir;
diff_77=s_732_7-s_932_7;
diff_78=s_732_7-s_832_7;
 diff_7p7=(s_732_7-s_932_7)./s_932_7*100;


File932_6=load('vax_10min_Wind_speed_932_201206.mat');
    File832_6=load('vax_10min_Wind_speed_832_201206.mat');
    s_932_6=File932_6.stat10.speed;
    s_832_6=File832_6.stat10.speed;
    d_932_6=File932_6.stat10.vdir;
    d_832_6=File832_6.stat10.vdir;
    diff_6=s_832_6-s_932_6;
    diff_6p=(s_832_6-s_932_6)./s_932_6*100;
    diff_D_6=d_932_6- d_832_6;
    diff_D_6p=(d_932_6- d_832_6)./d_932_6*100;
File732_6=load('vax_10min_Wind_speed_732_201206.mat');    
s_732_6=File732_6.stat10.speed;
 d_732_6=File732_6.stat10.vdir;
diff_67=s_732_6-s_932_6;
diff_68=s_732_6-s_832_6;
 diff_6p7=(s_732_6-s_932_6)./s_932_6*100;
    
    
File932_5=load('vax_10min_Wind_speed_932_201205.mat');
    File832_5=load('vax_10min_Wind_speed_832_201205.mat');
    s_932_5=File932_5.stat10.speed;
    s_832_5=File832_5.stat10.speed;
    d_932_5=File932_5.stat10.vdir;
    d_832_5=File832_5.stat10.vdir;
    diff_5=s_832_5-s_932_5;
    diff_5p=(s_832_5-s_932_5)./s_932_5*100;    
    diff_D_5=d_932_5- d_832_5;
    diff_D_5p=(d_932_5- d_832_5)./d_932_5*100;
File732_5=load('vax_10min_Wind_speed_732_201205.mat');    
s_732_5=File732_5.stat10.speed;
 d_732_5=File732_5.stat10.vdir;
diff_57=s_732_5-s_932_5;
diff_58=s_732_5-s_832_5;
 diff_5p7=(s_732_5-s_932_5)./s_932_5*100;

File932_4=load('vax_10min_Wind_speed_932_201204.mat');
    File832_4=load('vax_10min_Wind_speed_832_201204.mat');
    s_932_4=File932_4.stat10.speed;
    s_832_4=File832_4.stat10.speed;
    d_932_4=File932_4.stat10.vdir;
    d_832_4=File832_4.stat10.vdir;
    diff_4=s_832_4-s_932_4;
    diff_4p=(s_832_4-s_932_4)./s_932_4*100;   
    diff_D_4=d_932_4- d_832_4;
    diff_D_4p=(d_932_4- d_832_4)./d_932_4*100;
File732_4=load('vax_10min_Wind_speed_732_201204.mat');    
s_732_4=File732_4.stat10.speed;
 d_732_4=File732_4.stat10.vdir;
diff_47=s_732_4-s_932_4;
diff_48=s_732_4-s_832_4;
 diff_4p7=(s_732_4-s_932_4)./s_932_4*100;
    
    
File932_3=load('vax_10min_Wind_speed_932_201203.mat');
    File832_3=load('vax_10min_Wind_speed_832_201203.mat');
    s_932_3=File932_3.stat10.speed;
    s_832_3=File832_3.stat10.speed;
    d_932_3=File932_3.stat10.vdir;
    d_832_3=File832_3.stat10.vdir;
    diff_3=s_832_3-s_932_3;
    diff_3p=(s_832_3-s_932_3)./s_932_3*100;  
    diff_D_3=d_932_3- d_832_3;
    diff_D_3p=(d_932_3- d_832_3)./d_932_3*100;
  File732_3=load('vax_10min_Wind_speed_732_201203.mat');    
s_732_3=File732_3.stat10.speed;
 d_732_3=File732_3.stat10.vdir;
diff_37=s_732_3-s_932_3;
diff_38=s_732_3-s_832_3;
 diff_3p7=(s_732_3-s_932_3)./s_932_3*100;
    
    File932_2=load('vax_10min_Wind_speed_932_201202.mat');
    File832_2=load('vax_10min_Wind_speed_832_201202.mat');
    s_932_2=File932_2.stat10.speed;
    s_832_2=File832_2.stat10.speed;
    d_932_2=File932_2.stat10.vdir;
    d_832_2=File832_2.stat10.vdir;
    diff_2=s_832_2-s_932_2;
    diff_2p=(s_832_2-s_932_2)./s_932_2*100;  
    diff_D_2=d_932_2 - d_832_2;
    diff_D_2p=(d_932_2 - d_832_2)./d_932_2*100;
File732_2=load('vax_10min_Wind_speed_732_201202.mat');    
s_732_2=File732_2.stat10.speed;
 d_732_2=File732_2.stat10.vdir;
diff_27=s_732_2-s_932_2;
diff_28=s_732_2-s_832_2;
 diff_2p7=(s_732_2-s_932_2)./s_932_2*100;
  
 
 %%plot
  %scatter(diff,File932.stat10.vdir,2.5,'c');hold on;
  
figure
 subplot(2,2,1);  % Speeds
     scatter(diff_2,File932_2.stat10.vdir,2.5,'m'); hold on;
     scatter(diff_3,File932_3.stat10.vdir,2.5,'k');
     scatter(diff_4,File932_4.stat10.vdir,2.5,'y');
     scatter(diff_5,File932_5.stat10.vdir,2.5,'o');
     scatter(diff_6,File932_6.stat10.vdir,2.5,'c'); 
     scatter(diff_7,File932_7.stat10.vdir,2.5,'r');
     scatter(diff_8,File932_8.stat10.vdir,2.5,'g'); 
     scatter(diff_9,File932_9.stat10.vdir,2.5,'b'); 
txt=sprintf('speed difference w. direction\n btw 932/832');
title(txt,'FontSize',12)
ylabel('Direction')
xlabel('Difference (m/s)')
xlim([-3 3]);

 subplot(2,2,2);   %directions
     scatter(diff_D_2,File932_2.stat10.vdir,2.5,'m'); hold on;
     scatter(diff_D_3,File932_3.stat10.vdir,2.5,'k'); 
     scatter(diff_D_4,File932_4.stat10.vdir,2.5,'y');
     scatter(diff_D_5,File932_5.stat10.vdir,2.5,'o');
     scatter(diff_D_6,File932_6.stat10.vdir,2.5,'c');
     scatter(diff_D_7,File932_7.stat10.vdir,2.5,'r');    
     scatter(diff_D_8,File932_8.stat10.vdir,2.5,'g');   
     scatter(diff_D_9,File932_9.stat10.vdir,2.5,'b');
txt=sprintf('direction difference w. direction\n btw 932/832');
title(txt,'FontSize',12)
ylabel('Direction')
xlabel('Difference (Deg)')
xlim([-25 25]);

 subplot(2,2,4); % directions %diff
     scatter(diff_D_2p,File932_2.stat10.vdir,2.5,'m'); hold on;
     scatter(diff_D_3p,File932_3.stat10.vdir,2.5,'k'); 
     scatter(diff_D_4p,File932_4.stat10.vdir,2.5,'y');
     scatter(diff_D_5p,File932_5.stat10.vdir,2.5,'o');
     scatter(diff_D_6p,File932_6.stat10.vdir,2.5,'c');
     scatter(diff_D_7p,File932_7.stat10.vdir,2.5,'r');    
     scatter(diff_D_8p,File932_8.stat10.vdir,2.5,'g');   
     scatter(diff_D_9p,File932_9.stat10.vdir,2.5,'b');
txt=sprintf('direction difference w. direction \n as Percentage btw 932/832');
title(txt,'FontSize',10)
ylabel('Direction')
xlabel('Percentage Difference in Direction')
xlim([-10 10]);

subplot(2,2,3); % directions %diff
     scatter(diff_2p,File932_2.stat10.vdir,2.5,'m'); hold on;
     scatter(diff_3p,File932_3.stat10.vdir,2.5,'k'); 
     scatter(diff_4p,File932_4.stat10.vdir,2.5,'y');
     scatter(diff_5p,File932_5.stat10.vdir,2.5,'o');
     scatter(diff_6p,File932_6.stat10.vdir,2.5,'c');
     scatter(diff_7p,File932_7.stat10.vdir,2.5,'r');    
     scatter(diff_8p,File932_8.stat10.vdir,2.5,'g');   
     scatter(diff_9p,File932_9.stat10.vdir,2.5,'b');
txt=sprintf('speed difference w. direction \n as Percentage btw 932/832');
title(txt,'FontSize',10)
xlabel('Percentage Difference in Speed')
ylabel('Direction')
xlim([-20 20]);
figure
subplot (2,1,2)  

    scatter(diff_2p,s_932_2,2.5,'m'); hold on;
     scatter(diff_3p,s_932_3,2.5,'k'); 
     scatter(diff_4p,s_932_4,2.5,'y');
     scatter(diff_5p,s_932_5,2.5,'o');
     scatter(diff_6p,s_932_6,2.5,'c');
     scatter(diff_7p,s_932_7,2.5,'r');    
     scatter(diff_8p,s_932_8,2.5,'g');   
     scatter(diff_9p,s_932_9,2.5,'b');
     title('% Speed Difference Speed Associated', 'fontsize',14)
     xlabel('Speed Difference in %')
     ylabel('Speed of 932 (m/s)')
xlim([-20 20]);
ylim([0 20]);
subplot (2,1,1)  

    scatter(diff_2,s_932_2,2.5,'m'); hold on;
     scatter(diff_3,s_932_3,2.5,'k'); 
     scatter(diff_4,s_932_4,2.5,'y');
     scatter(diff_5,s_932_5,2.5,'o');
     scatter(diff_6,s_932_6,2.5,'c');
     scatter(diff_7,s_932_7,2.5,'r');    
     scatter(diff_8,s_932_8,2.5,'g');   
     scatter(diff_9,s_932_9,2.5,'b');
     title('Speed Difference Speed Associated', 'fontsize',14)
     xlabel('Speed Difference in m/s')
     ylabel('speed of 932 (m/s)')
     xlim([-3 3]);
     ylim([0 20]);
     
     figure
subplot (3,1,1)  
     % Speeds
     scatter(diff_27,File932_2.stat10.vdir,2.5,'m'); hold on;
     scatter(diff_37,File932_3.stat10.vdir,2.5,'k');
     scatter(diff_47,File932_4.stat10.vdir,2.5,'y');
     scatter(diff_57,File932_5.stat10.vdir,2.5,'o');
     scatter(diff_67,File932_6.stat10.vdir,2.5,'c'); 
     scatter(diff_77,File932_7.stat10.vdir,2.5,'r');
     scatter(diff_87,File932_8.stat10.vdir,2.5,'g'); 
     scatter(diff_97,File932_9.stat10.vdir,2.5,'b'); 
txt=sprintf('speed difference w. direction\n btw 932/732');
title(txt,'FontSize',12)
ylabel('Direction')
xlabel('Difference (m/s)  (732-932)')
xlim([-0 4]);
grid on;
subplot (3,1,2)  
 scatter(diff_28,File932_2.stat10.vdir,2.5,'m'); hold on;
     scatter(diff_38,File932_3.stat10.vdir,2.5,'k');
     scatter(diff_48,File932_4.stat10.vdir,2.5,'y');
     scatter(diff_58,File932_5.stat10.vdir,2.5,'o');
     scatter(diff_68,File932_6.stat10.vdir,2.5,'c'); 
     scatter(diff_78,File932_7.stat10.vdir,2.5,'r');
     scatter(diff_88,File932_8.stat10.vdir,2.5,'g'); 
     scatter(diff_98,File932_9.stat10.vdir,2.5,'b'); 
  xlim([-0 4]);   
  grid on;
  xlabel('Difference (m/s)  (732-832)')
  subplot(3,1,3)
    scatter(s_732_2,File932_2.stat10.vdir,2.5,'m'); hold on;
     scatter(s_732_3,File932_3.stat10.vdir,2.5,'k');
     scatter(s_732_4,File932_4.stat10.vdir,2.5,'y');
     scatter(s_732_5,File932_5.stat10.vdir,2.5,'o');
     scatter(s_732_6,File932_6.stat10.vdir,2.5,'c'); 
     scatter(s_732_7,File932_7.stat10.vdir,2.5,'r');
     scatter(s_732_8,File932_8.stat10.vdir,2.5,'g'); 
     scatter(s_732_9,File932_9.stat10.vdir,2.5,'b'); 
     xlim([-0 20]); grid on;
     xlabel(' Speed m/s')