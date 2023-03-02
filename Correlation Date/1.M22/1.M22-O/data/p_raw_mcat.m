% 20160712 mcat���f�[�^�}
% SH7706LSR��little�@endian�ł���
% ��M���f�[�^(*****.raw)�̐}��`������

% �t�@�C������.raw���Ȃ��ăL�[���͂���
   clear all;     % �ϐ��̃N���A
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
      data_number=str2num(bf(15:end))  % cos,sin��pair data��
      
      V=fread(fid,data_number*4,'uchar'); % ��C�Ƀf�[�^��ǂݏo��
      fclose(fid);

      % little endian
      c_l=V(1:4:end);         % �擪����4��΂��Ƀf�[�^���Ō�܂Ŏ��o����
      c_h=V(2:4:end);         % 2�ڂ���4��΂���
      s_l=V(3:4:end);         % 3�ڂ���4��΂���
      s_h=V(4:4:end);         % 4�ڂ���4��΂���

      c_d=c_h*256+c_l-512;    % A/D�ϊ��l��straight binary�Ȃ̂�512����
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
