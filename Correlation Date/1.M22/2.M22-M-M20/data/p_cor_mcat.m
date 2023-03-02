% 相関計算結果データ(*****.dat)の図を描く
% ファイル名は.datを省いてキー入力する必要がある

   clear all;     % 変数のクリア
   file_name=input('input file name : ','s');
   file_name=strcat(file_name,'.dat')
   fid=fopen(file_name,'r');
   if(fid<0) 
      disp('No such file');
      return;
   end
   
   if(fid~=-1)
      bf=fgets(fid);                % My station=T3
      my_st=str2num(bf(14))
      bf=fgets(fid);                % Ping time=2006 12 19 0 0
      bf=fgets(fid);                % True sampling freq=60096
      Sfreq=str2num(bf(16:end));
      bf=fgets(fid);                % total station
      st_num=str2num(bf(16:17));       % total station number
      ST=fgets(fid);                % 相手局名
%      ST(3)=[];    
      bf=fgets(fid)
      ad_start=str2num(bf(30:37))  % calc start time(ms) 
      bf=fgets(fid);
      
      V=fread(fid,'uchar');         % 一気にデータを読み込み、Vベクトルに格納する
      fclose(fid);
   
   % Cats dataはlittle endianの4バイトである
   % Borland cはbig endianの4バイトである
      c_1=V(1:8:end);
      c_2=V(2:8:end);
      c_3=V(3:8:end);
      c_4=V(4:8:end);
      s_1=V(5:8:end);
      s_2=V(6:8:end);
      s_3=V(7:8:end);
      s_4=V(8:8:end);
      c_d=c_4*256*256*256+c_3*256*256+c_2*256+c_1;
      In=find(c_4 > 127);           % MSB bitのcheck
      c_d(In)=c_d(In)-2^32;

      s_d=s_4*256*256*256+s_3*256*256+s_2*256+s_1;
      In=find(s_4 > 127);           % MSB bitのcheck
      s_d(In)=s_d(In)-2^32;

      T=0:length(c_d)-1;
      Time=T/Sfreq;
%      start0=0;
%      offset=ad_start+Time;
      Time=Time+ad_start/1000;
   
      figure;
%       subplot(3,1,1);
%       plot(Time,c_d);
%       titlename=strcat('      ');
%       titlename=strcat(titlename,file_name);
%       title(titlename,'fontsize',15); 
%       xlabel('Travel Time (s)','fontsize',13.0,'fontweight','bold');
%       ylabel('cos','fontsize',13.0,'fontweight','bold');
%       %xlim([8.8 9.3]);
%       
%       subplot(3,1,2);
%       plot(Time,s_d);
%       xlabel('Travel Time (s)','fontsize',13.0,'fontweight','bold');
%       ylabel('sin','fontsize',13.0,'fontweight','bold');
%       %xlim([8.8 9.3]);
%       
%       subplot(3,1,3);
      cor_d=sqrt(c_d.^2+s_d.^2);
      plot(Time,cor_d/mean(cor_d),'b-','linew',1.8);
      set(gcf,'color',[0.85,0.85,0.85]); % プロットした図の外の背景
      set(gca,'color','white'); % プロットした図の中の背景
      set(gca,'xcolor','black'); % X軸の色
      set(gca,'ycolor','black'); % Y軸の色
      xlabel('Travel Time (s)','fontsize',13.0,'fontweight','bold');
      ylabel('SNR (Amp)','fontsize',13.0,'fontweight','bold');
      fig_name=strcat('Correlation Waveform','(',file_name,')')
      title(fig_name,'fontsize',15,'color','k');     
      %title('Correlation Waveform (2a310320)','fontsize',13.0,'fontweight','bold')
      %xlim([5.84 5.86]);
      
   end
