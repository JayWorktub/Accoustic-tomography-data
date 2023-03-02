% 20160712 mcat生データ図
% SH7706LSRはlittle　endianである
% 受信生データ(*****.raw)の図を描かせる

% ファイル名は.rawを省いてキー入力する
   clear all;     % 変数のクリア
   % key_input parameters
   base_file_name=input('input file name : ','s');
   raw_file_name=strcat(base_file_name,'.raw');

% close all
   space1=' ';

   fid=fopen(raw_file_name,'r');
   if(fid<0)
      disp('can not find such file');
      return;
   end
   
   if(fid~=-1)
      fgets(fid);                      % Version= 2011.6_eject_4800
      bf=fgets(fid);                   % My station=T3
      my_station=bf(12:end)
      
      fgets(fid);                      % Mod number= 3 code_name=M10
      bf=fgets(fid);                   % repeat number= 1
      repeat=str2num(bf(15:end))
      
      fgets(fid);                      % position= 3448.9180N 13249.9233E
      bf=fgets(fid);                   % Ping time=  2006 12 18  3 383
      ping_time=bf(11:end);
      bf=fgets(fid);                   % True sampling freq=1620
      freq=str2num(bf(15:end));

      bf=fgets(fid);                   % data start time(usec)= 188987
      ad_start=str2num(bf(23:end));    % ad_start(msec) 
                   
      bf=fgets(fid);                   % data number= 54043
      data_number=str2num(bf(15:end))  % cos,sinのpair data数
      
      V=fread(fid,data_number*4,'uchar'); % 一気にデータを読み出す
      fclose(fid);

      % little endian
      c_l=V(1:4:end);         % 先頭から4個飛ばしにデータを最後まで取り出さす
      c_h=V(2:4:end);         % 2個目から4個飛ばしに
      s_l=V(3:4:end);         % 3個目から4個飛ばしに
      s_h=V(4:4:end);         % 4個目から4個飛ばしに

      c_d=c_h*256+c_l-512;    % A/D変換値はstraight binaryなので512引く
      s_d=s_h*256+s_l-512;

      T=0:length(c_d)-1;
      Time=T*1000/freq;
      Time=Time+ad_start;    

      figure;
      
      subplot(2,1,1);
      plot(Time,c_d);
      fig_name=strcat(my_station,'-')
      fig_name=strcat(fig_name,raw_file_name)
      title(fig_name,'fontsize',15);     
%      ylim([-512 512]);
      subplot(2,1,2);
      plot(Time,s_d);
%      ylim([-512 512]);
      hold on;
   end
