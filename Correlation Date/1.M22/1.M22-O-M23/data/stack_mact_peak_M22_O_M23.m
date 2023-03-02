clear all;
%%
%作者：许世杰
%创作时间：2021.11.15
%更新时间：2022.03.16
%找峰程序
%% specify the start and end time *******************************;
display_start_sec = 1.5 % 计算域时间>展示域
display_end_sec = 1.8
start_sec = 1.515; % 展示域时间
end_sec = 1.55;

start_num = display_start_sec * 10000 + 1;
end_num = display_end_sec * 10000 + 1;
% % ****************************************************************;
%%
%Finish
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
%         view([0 78]);
        break;
    end
    if isempty(filename)
        fclose(fid1);
%         view([0 78]);
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
            data_num=str2num(bf(14:18));
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
%%
[M,N]=size(Time_p);
%  snr_sum=zeros(M,N);
%  for ig=6:N-5;
%      snr_sum(:,ig)=sum(snr_x(:,ig-5:ig+5),2);
%  end

for inum = 1 : 4%峰数量
    eval(['Date_m',num2str(inum),'=[];'])
    eval(['Time_m',num2str(inum),'=[];'])
    eval(['snr_m',num2str(inum),'=[];'])
end

[im_max,ig_max]=max(snr_x);
min_peak_distance = 8;%两峰之间的最小间隔数
for i=1:N
    SNR_M=snr_x(:,i);
    %寻找一个固定峰
    %ｵﾚﾒｻｸ袒ｵ
    threshold1 = 30;
    np1 = 100;
    start1 = 40;
    end1 = 500;
    %search the first peak
    Date11 = Date(np1+start1:np1+end1);
    Time11 = Time(np1+start1:np1+end1);
    SNR11 = SNR_M(np1+start1:np1+end1);

    [SNR_k1,num_k1]= findpeaks(SNR11,'minpeakheight', threshold1,'minpeakdistance',min_peak_distance);
    %num_k1 = [num_k1;find(SNR11 == max(SNR11))];
    if length(num_k1) == 0
        continue;
    end
    % 排序
    [sort_snr1,sort_num1]=sort(SNR_k1,'descend');
    num_change_k1 = num_k1(1,:);
%     if length(num_k1) == 1
%         num_change_k1 = 1;
%     else
%         if num_k1(sort_num1(1)) < num_k1(sort_num1(2))
%             num_change_k1 = sort_num1(1);
%         else
%             num_change_k1 = sort_num1(2);
%         end
%     end
%    
    Ind1=num_k1(1)+np1+start1-1;
    
    Date_m1=[Date_m1;Date_p(Ind1,i)];
    Time_m1=[Time_m1;Time_p(Ind1,i)];
    snr_m1=[snr_m1;snr_x(Ind1,i)];
    
%     %ｵﾚｶ�\ﾈ�ｸ袒ｵ
    threshold2 = 8;
    start2 = 5;
    end2 = 20;
    Time_02=(Time(Ind1) - display_start_sec)*10000;%5000｣ｺfrequency
    np2=round(Time_02); %Index number until the largest peak%;
    
    %search the second peak
    Date2 = Date(np2+start2:np2+end2);
    Time2 = Time(np2+start2:np2+end2);
    SNR2 = SNR_M(np2+start2:np2+end2);
    
    [SNR_k2,num_k2]= findpeaks(SNR2,'minpeakheight', threshold2,'minpeakdistance',min_peak_distance);
    if length(num_k2) == 0
        continue;
    end
    % 排序
    [sort_snr2,sort_num2]=sort(SNR_k2,'descend');
    num_change_k2 = sort_num2(1,:);
    %     if length(num_k2) == 1
    %         num_change_k2 =  1;
    %     else
    %         if num_k1(sort_num2(1)) < num_k1(sort_num2(2))
    %             num_change_k2 = sort_num2(1);
    %         else
    %             num_change_k2 = sort_num2(2);
    %         end
    %     end
    %
    Ind2=num_k2(num_change_k2)+ np2 + start2 - 1;
    
    Date_m2=[Date_m2;Date_p(Ind2,i)];
    Time_m2=[Time_m2;Time_p(Ind2,i)];
    snr_m2=[snr_m2;snr_x(Ind2,i)];
     
%     %ｵﾚｶ�\ﾈ�ｸ袒ｵ
    threshold3 = 8;
    start3 = 15;
    end3 = 30;
    Time_03=(Time(Ind1) - display_start_sec)*10000;%5000｣ｺfrequency
    np3=round(Time_03); %Index number until the largest peak%;
    
    %search the second peak
    Date3 = Date(np3+start3:np3+end3);
    Time3 = Time(np3+start3:np3+end3);
    SNR3 = SNR_M(np3+start3:np3+end3);
    
    [SNR_k3,num_k3]= findpeaks(SNR3,'minpeakheight', threshold3,'minpeakdistance',min_peak_distance);
    if length(num_k3) == 0
        continue;
    end
    % 排序
    [sort_snr3,sort_num3]=sort(SNR_k3,'descend');
    num_change_k3 = sort_num3(1,:);
    
    Ind3=num_k3(num_change_k3)+ np3 + start3 - 1;
    
    Date_m3=[Date_m3;Date_p(Ind3,i)];
    Time_m3=[Time_m3;Time_p(Ind3,i)];
    snr_m3=[snr_m3;snr_x(Ind3,i)];
    
 
    
end
figure;
plot3(Time_p,Date_p,snr_x,'k-','linew',0.8);hold on;
set(gcf,'position',[0,0,1000,500])
plot3(Time_m1,Date_m1,snr_m1,'o','markersize',10,'linew',1,'MarkerFaceColor','#e63946','color','#e63946');hold on;
plot3(Time_m2,Date_m2,snr_m2,'o','markersize',10,'linew',1,'MarkerFaceColor','#71B6DC','color','#71B6DC');hold on;
plot3(Time_m3,Date_m3,snr_m3,'o','markersize',10,'linew',1,'MarkerFaceColor','#003051','color','#003051');hold on;
% plot3(Time_m4,Date_m4,snr_m4,'mo','markersize',10,'linew',2);hold on;
view([0 80]);
xlim([start_sec end_sec]);
xlabel('Travel Time (s)','fontweight','bold','fontsize',18.0);hold on;
ylabel('Day from June 26th, 2022','fontweight','bold','fontsize',18.0);
zlabel('SNR','fontweight','bold','fontsize',18.0);
datetick('y','HH:MM');
% xlim([start_sec,end_sec])
set(gca,'fontweight','bold','fontsize',18.0);

time_choose = [Time_m1;Time_m2;Time_m3];
%% ﾎﾂｶﾈﾍｼ
figure('color',[1,1,1])
b = surf(Time_p,Date_p,snr_x,snr_x);
shading interp;
% c = contourf(Time_p,Date_p,snr_x,10);
view(2)
colorbar;
colormap(parula);
xlabel('Travel Time (s)','fontweight','bold','fontsize',18.0);hold on;
ylabel('Day from June 26th, 2022','fontweight','bold','fontsize',18.0);
set(gca,'fontweight','bold','fontsize',18.0);
xlim([start_sec end_sec])
set(gca, 'CLim', [0 150]);
datetick('y','HH:MM');
%% 时刻解答
date_all  = Date_p(1,:)';
for inum = 1:3
    time_all(length(date_all),inum) = 0;
    eval(['date_median = Date_m',num2str(inum),';']);
    eval(['time_median = Time_m',num2str(inum),';']);
    for jnum = 1:length(date_median)
        median_num(jnum,:) = find(date_median(jnum) == date_all); 
        time_all(median_num(jnum,:),inum) = time_median(jnum,:);
    end   
end
%% save
for inum = 1 : 3%ｸﾝｷ袒ｵﾊ�ﾁｿﾈｷｶｨ
    eval(['dateM22_O_M23_m',num2str(inum),' = Date_m',num2str(inum),';'])
    eval(['snrM22_O_M23_m',num2str(inum),' = snr_m',num2str(inum),';'])
    eval(['timeM22_O_M23_m',num2str(inum),' = Time_m',num2str(inum),';'])
end
Time_M22_O_M23 = Time_p;
Date_M22_O_M23 = Date_p;
snr_M22_O_M23 = snr_x;
save M22_O_M23_4peak dateM22_O_M23_m1 dateM22_O_M23_m2 dateM22_O_M23_m3 ...
    snrM22_O_M23_m1 snrM22_O_M23_m2 snrM22_O_M23_m3 ...
    timeM22_O_M23_m1 timeM22_O_M23_m2 timeM22_O_M23_m3 ... 
    Time_M22_O_M23 Date_M22_O_M23 snr_M22_O_M23;

