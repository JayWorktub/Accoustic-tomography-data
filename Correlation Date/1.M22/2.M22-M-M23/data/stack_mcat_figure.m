clear all;
close all;
%%
start_sec = 2; % 展示域时间
end_sec = 2.3;

start_num = start_sec * 10000 + 1;
end_num = end_sec * 10000 + 1;
%%
!dir/b/o:n *.dat > filename.txt
fid1=fopen('filename.txt','r');
%SNR=5;  % ???;
kk=0;
a=[];
Date_p=[];
Time_p=[];
cor_x=[];
snr_x=[];

while(1) % WHILEは不定回数の繰り返しステートメント;
    %  WHILEステートメントの一般的な書式は、つぎのようになります。;
    %       WHILE expression;
    %         statements;
    %       END;
    
    
    
    filename=fgetl(fid1);       %file名羅列の1行目のfile名をfilenameに代入;
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
    fid=fopen(filename,'r');    %filenameに代入した1行目のfileをopen;
    if(fid<0)
        disp('NO such a file.');
        return;
    end
    
    if(fid~=-1)
        
        bf=fgets(fid);                % My station=T3    % my_st=str2num(bf(14)); %ここでは行を進めるだけ;
        bf=fgets(fid);
        
        Dat=str2num(bf(20:21))+(str2num(bf(24:25))+8)/24+str2num(bf(27:28))/1440; % Ping time=  2006(□□)8(□)19(□)0(□=1or2)0
        % Ping time=  2006(□□)8(□)19(□)0(□=1or2)0
        bf=fgets(fid);           % True sampling freq=60096
        Sfreq=str2num(bf(15:end));
        bf=fgets(fid);
        sta_num=str2num(bf(15:16));
        
        for    i=1:(sta_num-1)
            ST=fgets(fid);                % 相手局名
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
                In=find(c_4 > 127);           % MSB bitのcheck
                c_d(In)=c_d(In)-2^32;
                
                s_d=s_4*256*256*256+s_3*256*256+s_2*256+s_1;
                In=find(s_4 > 127);           % MSB bitのcheck
                s_d(In)=s_d(In)-2^32;
                
                T=0:length(c_d)-1;        %最後の行にdisp(T)とおくと0～1599が.mat上にでてくる;
                Time1=T/Sfreq; %(s)
                Time=Time1+cor_start/1000; %(s)
                
                cor_d=sqrt(c_d.^2+s_d.^2);
                cor_ave=mean(cor_d);
                cor_max=max(cor_d);
                SNR=cor_d/cor_ave;
                Date=ones(size(c_d))*Dat;
                %  Ind=find(cor_d/cor_ave > SNR);
%                 if cor_max >= 1.0e+2
%                     
%                     Ind=find((SNR >= 1.0*max(SNR))&(SNR>1));
%                     if length(Ind)==0
%                         continue;
%                     end
%                     
%                     
%                     kk=kk+1;
%                     
%                     %   if max(cor_d)/cor_ave > SNR
%                     a=[a kk];
%                     Date_p=[Date_p;Date(Ind(1))];
%                     Time_p=[Time_p;Time(Ind(1))];
%                     cor_x=[cor_x;cor_d(Ind(1))];
%                     snr_x=[snr_x;SNR(Ind(1))];
%                     %  end
%                     plot3(Time,Date,SNR,'k-','linew',1.5);
%                     set(gcf,'color',[0.85,0.85,0.85]); % プロットした図の外の背景
%                     set(gca,'color','white'); % プロットした図の中の背景
%                     set(gca,'xcolor','black'); % X軸の色
%                     set(gca,'ycolor','black'); % Y軸の色
%                     hold on;
%                     
%                 end
                Date = Date(start_num:end_num);
                Time = Time(start_num:end_num);
                SNR = SNR(start_num:end_num);
                
                kk=kk+1;
                
                %   if max(cor_d)/cor_ave > SNR
                a=[a kk];
                
                Date_p=[Date_p,Date];
                Time_p=[Time_p,Time'];
                cor_x=[cor_x,cor_d];
                snr_x=[snr_x,SNR];
            end
        end
        
        
        fclose(fid);
        
    end
    
end
view([0 78]);
xlim([1.8 2.3]);
%ylim([14,17]);
set(gcf,'position',[0,0,1500,800]);
% plot3(Time_p,Date_p,snr_x,'ro','markersize',10,'linew',2);
% 要素である点を通るラインを3次元空間にプロット;
% 得られる複数のラインをプロットします。;
xlabel('Travel Time (s)','fontweight','bold','fontsize',12.0);hold on;
ylabel('Day from January 1, 2020','fontweight','bold','fontsize',12.0);
zlabel('SNR','fontweight','bold','fontsize',12.0);
datetick('y','HH:MM');
% PLOT3(X,Y,Z)は、X、Y、Zが同じサイズの行列のとき;
%% ﾎﾂｶﾈﾍｼ
figure('color',[1,1,1]);
set(gcf,'position',[0,0,1000,500]);
b = surf(Time_p,Date_p,snr_x,snr_x);
% c = mesh(Time_p,Date_p,snr_x);
shading interp;
view(2)
colorbar;
colormap(parula);
xlabel('Travel Time (s)','fontweight','bold','fontsize',18.0);hold on;
ylabel('Day from June 26th, 2022','fontweight','bold','fontsize',18.0);
set(gca,'fontweight','bold','fontsize',18.0);
xlim([2 2.3]);
% ylim([26.41 26.61]);
set(gca, 'CLim', [0 50]);
datetick('y','HH:MM');

%%
save TT3_data Date_p Time_p cor_x;