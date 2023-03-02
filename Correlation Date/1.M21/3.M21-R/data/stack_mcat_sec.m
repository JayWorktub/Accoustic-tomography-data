clear all;
close all;

%Added by NGO and AK on Oct 16, 2016
% % specify the start and end time *******************************;
 display_start_sec=input('Please input display start time(s) :');
 display_end_sec=input('Please input display end time(s) :');
% % ****************************************************************;
%Finish

!dir/b/o:n *.dat > filename.txt
fid1=fopen('filename.txt','r');
%SNR=5;  % ???;
kk=0;
a=[];
Date_p=[];
Time_p=[];
Dist_p=[];
cor_x=[];
snr_x=[];
Date_max=[];
Time_max=[];
%Dist_max=[];
snr_max=[];
while(1) % WHILEは不定回?狽ﾌ繰り返しステ?[ト?ント;
     filename=fgetl(fid1);       %file名羅列の1?s目のfile名をfilenameに代入;
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
    fid=fopen(filename,'r');    %filenameに代入した1?s目のfileをopen;
    if(fid<0)
        disp('NO such a file.');
        return;
    end

    if(fid~=-1)

        bf=fgets(fid);                % My station=T3    % my_st=str2num(bf(14)); %ここでは?sを?iめるだけ;
        bf=fgets(fid);
      %UTC to Bali Time
        Dat=str2num(bf(20:21))+(str2num(bf(24:25))+9)/24+str2num(bf(27:28))/1440; % Ping time=  2006(???8(??19(??0(??1or2)0
                                 % Ping time=  2006(???8(??19(??0(??1or2)0
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
                c_1=V(1:8:end);
                c_2=V(2:8:end);
                c_3=V(3:8:end);
                c_4=V(4:8:end);
                s_1=V(5:8:end);
                s_2=V(6:8:end);
                s_3=V(7:8:end);
                s_4=V(8:8:end);
                %c_d=c_1*256*256*256+c_2*256*256+c_3*256+c_4;
                c_d=c_4*256*256*256+c_3*256*256+c_2*256+c_1;
                In=find(c_4 > 127);           % MSB bitのcheck
                c_d(In)=c_d(In)-2^32;
                %s_d=s_1*256*256*256+s_2*256*256+s_3*256+s_4;
                s_d=s_4*256*256*256+s_3*256*256+s_2*256+s_1;
                In=find(s_4 > 127);           % MSB bitのcheck
                s_d(In)=s_d(In)-2^32;
                
                T=0:length(c_d)-1;        
                Time1=T/Sfreq; %(s)
                Time=Time1+cor_start/1000; %(s)

%Added by NGO and AK on Oct 16, 2016               
% ***** pick-up the data from start to end ******
	for is=1:length(c_d)-1
		if (Time(is) >= display_start_sec) break;
        end 
    end
    
    for ie=1:length(c_d)-1
        if (Time(ie) >= display_end_sec) break; 
        end
    end 
    
	istart=is;
    iend=ie;
	c_d_new=c_d(is:iend);
	s_d_new=s_d(is:iend);
	Time_new=Time(is:iend);
	c_d=c_d_new;
	s_d=s_d_new;
	Time=Time_new;
    %Dist=Time/2*1500; %[m]
% *****************************************************
%finish

                cor_d=sqrt(c_d.^2+s_d.^2);
                cor_ave=mean(cor_d);

                cor_max=max(cor_d);
                SNR=cor_d/cor_ave;
                Date=ones(size(c_d))*Dat;
                
            kk=kk+1;    
            a=[a kk];
           Date_p=[Date_p,Date];
           Time_p=[Time_p,Time'];
           %Dist_p=[Dist_p,Dist'];
           cor_x=[cor_x,cor_d];
           snr_x=[snr_x,SNR];  
           
             end
            end
        end


        fclose(fid);

end

   [M,N]=size(Time_p);
%  snr_sum=zeros(M,N);
%  for ig=6:N-5;
%      snr_sum(:,ig)=sum(snr_x(:,ig-5:ig+5),2);
%  end
 
  plot3(Time_p,Date_p,snr_x,'b-','linew',1.8);hold on;
[im_max,ig_max]=max(snr_x);
 for i=1:N;
     SNR_M=snr_x(:,i);
     Ind=find((SNR_M>= 1.0*max(SNR_M))&(SNR_M>1));
     %Ind=find(SNR_M>50);
       if length(Ind)==0
             continue;
       end
        
    Date_max=[Date_max;Date_p(Ind(1),i)];
    Time_max=[Time_max;Time_p(Ind(1),i)];
    %Dist_max=[Dist_max;Dist_p(Ind(1),i)];
     snr_max=[snr_max;snr_x(Ind(1),i)];
 end

plot3(Time_max,Date_max,snr_max,'ro','markersize',10,'linew',2);hold on; 
view([0 78]);
xlim([2 2.02]);
%ylim([24.516 24.524]);
xlabel('Travel Time (s)','fontweight','bold','fontsize',18.0);hold on;
ylabel('Day from January 1, 2020','fontweight','bold','fontsize',18.0);
zlabel('SNR','fontweight','bold','fontsize',18.0);
set(gca,'fontweight','bold','fontsize',18.0);  
save TT3_max_data Date_max Time_max snr_max;
