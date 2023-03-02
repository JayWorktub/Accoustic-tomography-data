% フォルダー内の全生データの相関計算をおこない、*.datファイルを作る
% dataが格納されているフォルダーにcorr.exeを置いておくこと

   clear all;   
   codenum=input('Please input code number (0-15):');
   start_time=input('Please input expected travel time (ms) :');
   duration_time=input('Please input travel time width (ms) :');
   
   space1=' ';
   code_char=num2str(codenum);
   start_char=num2str(start_time);
   duration_char=num2str(duration_time);
   
   com0='!corr_mcat.exe ';
   com1=[com0 space1 code_char space1];
   com2=[com1 start_char space1 duration_char];
   
   !dir/b/o:n *.raw > filename.txt
   fid=fopen('filename.txt','r');

   while(1)
      data_file_name=fgetl(fid);
      if data_file_name==-1
         fclose(fid);
         break;
      end
      if isempty(data_file_name)
         fclose(fid);
         break;
      end   
      
      le=length(data_file_name);
      data_file_name(le-3)=0;data_file_name(le-2)=0;
      data_file_name(le-1)=0;data_file_name(le)=0;
      command0=[com2 space1 data_file_name];

      % *** execute c_program(corr.exe) ***
      eval(command0);
      % **********************************
   end
   fclose all;
