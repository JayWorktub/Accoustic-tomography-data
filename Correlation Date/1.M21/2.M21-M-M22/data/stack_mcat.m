clear all;
close all;
!dir/b/o:n *.dat > filename.txt
fid1=fopen('filename.txt','r');
%SNR=5;  % ???;
kk=0;
a=[];
Date_p=[];
Time_p=[];
cor_x=[];
snr_x=[];

while(1) % WHILE�͕s��񐔂̌J��Ԃ��X�e�[�g�����g;
         %  WHILE�X�e�[�g�����g�̈�ʓI�ȏ����́A���̂悤�ɂȂ�܂��B;
         %       WHILE expression;
         %         statements;
         %       END;
         
         
         
    filename=fgetl(fid1);       %file�������1�s�ڂ�file����filename�ɑ��;
    if filename==-1
        fclose(fid1);
        view([0 78]);
        break;
    end
    if isempty(filename)     
        fclose(fid1);
        view([0 78]);
        break;
    end
    fid=fopen(filename,'r');    %filename�ɑ������1�s�ڂ�file��open;
    if(fid<0)
        disp('NO such a file.');
        return;
    end

    if(fid~=-1)

        bf=fgets(fid);                % My station=T3    % my_st=str2num(bf(14)); %�����ł͍s��i�߂邾��;
        bf=fgets(fid);

        Dat=str2num(bf(20:21))+(str2num(bf(24:25))+9)/24+str2num(bf(27:28))/1440; % Ping time=  2006(����)8(��)19(��)0(��=1or2)0
                                 % Ping time=  2006(����)8(��)19(��)0(��=1or2)0
        bf=fgets(fid);           % True sampling freq=60096
        Sfreq=str2num(bf(15:end));
        bf=fgets(fid);
        sta_num=str2num(bf(15:16));

        for    i=1:(sta_num-1)
            ST=fgets(fid);                % ����ǖ�
            ST(3)=[];
            bf=fgets(fid);
            cor_start=str2num(bf(30:end));  % ad_count num=4747
            
            bf=fgets(fid);
            data_num=str2num(bf(14:end));
            V=fread(fid,data_num*8,'uchar');
            if(i==1)
                
                % little endian
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
                
                T=0:length(c_d)-1;        %�Ō�̍s��disp(T)�Ƃ�����0�`1599��.mat��ɂłĂ���;
                Time1=T/Sfreq; %(s)
                Time=Time1+cor_start/1000; %(s)

                cor_d=sqrt(c_d.^2+s_d.^2);
                cor_ave=mean(cor_d);
                cor_max=max(cor_d);
                SNR=cor_d/cor_ave;
                Date=ones(size(c_d))*Dat;
            %  Ind=find(cor_d/cor_ave > SNR);
             if cor_max >= 1.0e+2

                 Ind=find((SNR >= 1.0*max(SNR))&(SNR>1));
                 if length(Ind)==0
                     continue;
                 end

                
                kk=kk+1;

             %   if max(cor_d)/cor_ave > SNR
                    a=[a kk];
                    Date_p=[Date_p;Date(Ind(1))];
                    Time_p=[Time_p;Time(Ind(1))];
                    cor_x=[cor_x;cor_d(Ind(1))];
                    snr_x=[snr_x;SNR(Ind(1))];
              %  end
              plot3(Time,Date,SNR,'b-','linew',1.8);
              set(gcf,'color',[0.85,0.85,0.85]); % �v���b�g�����}�̊O�̔w�i
              set(gca,'color','white'); % �v���b�g�����}�̒��̔w�i
              set(gca,'xcolor','black'); % X���̐F
              set(gca,'ycolor','black'); % Y���̐F
            hold on;
             end
            end
        end


        fclose(fid);

    end

end
view([0 78]);
xlim([1.70 1.92]);
%ylim([14,17]);
plot3(Time_p,Date_p,snr_x,'ro','markersize',10,'linew',2); 
        % �v�f�ł���_��ʂ郉�C����3������ԂɃv���b�g;
        % �����镡���̃��C�����v���b�g���܂��B;
xlabel('Travel Time (s)','fontweight','bold','fontsize',12.0);hold on;
ylabel('Day from January 1, 2022','fontweight','bold','fontsize',12.0);
zlabel('SNR','fontweight','bold','fontsize',12.0);
datetick('y','HH:MM');
% PLOT3(X,Y,Z)�́AX�AY�AZ�������T�C�Y�̍s��̂Ƃ�;
                                                                                                                                            
%save TT3_data Date_p Time_p cor_x;
