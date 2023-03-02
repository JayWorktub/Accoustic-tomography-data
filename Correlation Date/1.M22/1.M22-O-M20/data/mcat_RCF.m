% 20170112 mcat��M���f�[�^(*****.raw)�̐}�Ƒ��֌v�Z���ʐ}��`������
% mcat raw.dat��little endian
% ���֌v�Z���ʂ̃f�[�^�t�@�C���������B
% �t�@�C������.raw���Ȃ��ăL�[���͂���

% �t�@�C������.raw���Ȃ��ăL�[���͂���
   clear all;     % �ϐ��̃N���A
   close all;
   % key_input parameters

   base_file_name=input('input file name : ','s');
   code_no=input('Please input code number (0-15):');
   start_time=input('Please input expected travel time (ms) :');
   calc_width_ms=input('Please input calc length time (ms) :');

   raw_file_name=strcat(base_file_name,'.raw');
   space1=' ';

   fid=fopen(raw_file_name,'r');
   if(fid<0)
      disp('can not find such file');
      return;
   end
   
   if(fid~=-1)
      fgets(fid);                      % Version= 2011.6_eject_4800
      bf=fgets(fid);                   % My station=T3
      my_station=bf(12:end);
      
      fgets(fid);                      % Mod number= 3 code_name=M10
      bf=fgets(fid);                      % repeat number= 1
      repeat=str2num(bf(15:16));
      
      fgets(fid);                      % position= 3448.9180N 13249.9233E
      bf=fgets(fid);                   % Ping time=  2006 12 18  3 383
      ping_time=bf(11:end);
      bf=fgets(fid);                   % True sampling freq=1620
      Sfreq=str2num(bf(15:end));

      bf=fgets(fid);                   % data start time(usec)= 188987
      ad_start=str2num(bf(23:end));    % ad_start(msec) 
                   
      bf=fgets(fid);                   % data number= 54043
      data_number=str2num(bf(15:end)); % cos,sin��pair data��
      
      V=fread(fid,data_number*4,'uchar'); % ��C�Ƀf�[�^��ǂݏo��
      fclose(fid);

      % little endian
      c_l=V(1:4:end);         % �擪����4��΂��Ƀf�[�^���Ō�܂Ŏ��o����
      c_h=V(2:4:end);         % 2�ڂ���4��΂���
      s_l=V(3:4:end);         % 3�ڂ���4��΂���
      s_h=V(4:4:end);         % 4�ڂ���4��΂���

%      Index_0=find(c_h > 3)           % MSB bit��check

      c_d=c_h*256+c_l-512;     % A/D�ϊ��l��straight binary�Ȃ̂�512����
      s_d=s_h*256+s_l-512;

      T=0:length(c_d)-1;
      Time=T*1000/Sfreq;      % msec
      Time=Time+ad_start;    

      % ******** ��M���f�[�^(*****.raw)�̐}��`������ ********
      figure;
      subplot(2,1,1);
      plot(Time,c_d);
      ylabel('cos','fontsize',15.0,'fontweight','bold');
      fig_name=strcat(my_station,'-');
      fig_name=strcat(fig_name,raw_file_name);
      title(fig_name,'fontsize',15);     
%      ylim([-512 512]);
      subplot(2,1,2);
      plot(Time,s_d);
      xlabel('Travel Time (ms)','fontsize',13.0,'fontweight','bold');
      ylabel('sin','fontsize',15.0,'fontweight','bold');
%      ylim([-512 512]);
      hold on;
   end
%return   
   % ************ ���֌v�Z���s�킹�� *****************
   space1=' ';
   code_char=num2str(code_no);
   start_char=num2str(start_time);
   duration_char=num2str(calc_width_ms);
   com0='!corr_mcat.exe ';
   com1=[com0 space1 code_char space1];
   com2=[com1 start_char space1 duration_char];
   command0=[com2 space1 base_file_name];
   eval(command0);

   % ���֌v�Z���ʃf�[�^(*****.dat)�̐}��`��
   file_name=base_file_name;
   file_name=strcat(file_name,'-');
   code_no_char=num2str(code_no);
   file_name=strcat(file_name,code_no_char);
   file_name=strcat(file_name,'.dat');
   fid=fopen(file_name,'r');
   if(fid==-1) disp('No such file');end
   if(fid==-1) return;end
   
   if(fid~=-1)
      bf=fgets(fid);                % My station=T3
      my_st=str2num(bf(14));
      bf=fgets(fid);                % Ping time=2006 12 19 0 0
      bf=fgets(fid);                % True sampling freq=60096
      Sfreq=str2num(bf(15:end));
      bf=fgets(fid);                % total station
      st_num=str2num(bf(15:end));   % total station number
      ST=fgets(fid);                % ����ǖ�
      bf=fgets(fid);
      calc_start=str2num(bf(30:end));  % calc start time(ms) 
      bf=fgets(fid);                % pair data no
      pair_data_no=str2num(bf(14:end));
      
      V=fread(fid,'uchar');   % �f�[�^��ǂݍ��݁AV�x�N�g���Ɋi�[����
      fclose(fid);
   
      % corr.exe�̌���(Borland c)��little endian��4�o�C�g�ł���
      c_1=V(1:8:end);
      c_2=V(2:8:end);
      c_3=V(3:8:end);
      c_4=V(4:8:end);
      s_1=V(5:8:end);
      s_2=V(6:8:end);
      s_3=V(7:8:end);
      s_4=V(8:8:end);
      c_d=c_4*256*256*256+c_3*256*256+c_2*256+c_1;
      In=find(c_4 > 127);           % MSB bit��check
      c_d(In)=c_d(In)-2^32;

      s_d=s_4*256*256*256+s_3*256*256+s_2*256+s_1;
      In=find(s_4 > 127);           % MSB bit��check
      s_d(In)=s_d(In)-2^32;

      T=0:length(c_d)-1;
      Time=T*1000/Sfreq;            % msec
      Time=Time+calc_start;         % msec
      %Dist=Time/1000/2*1.5;   %{km}
      
      figure_name=file_name;

      figure;
      subplot(3,1,1);
      plot(Time,c_d);
      titlename=strcat('      ');
      titlename=strcat(titlename,figure_name);
      title(titlename,'fontsize',15);    
      ylabel('cos','fontsize',15.0,'fontweight','bold');
      subplot(3,1,2);
      plot(Time,s_d);
      ylabel('sin','fontsize',13.0,'fontweight','bold');
      
      subplot(3,1,3);
      cor_d=sqrt(c_d.^2+s_d.^2);
      plot(Time,cor_d/mean(cor_d));
      xlabel('Travel Time (ms)','fontsize',13.0,'fontweight','bold');
      ylabel('SNR','fontsize',15.0,'fontweight','bold');
      max(cor_d);
      mean(cor_d);
      max(cor_d)/mean(cor_d);
   end
   return
   