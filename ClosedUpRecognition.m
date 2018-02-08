clc
close all;
clear;
load imgfildataLetter;
load imgfildataNumber;

% One Picture only
% [file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
% s=[path,file];
% picture=imread(s);

file = fopen('number_Plate.txt', 'wt');
for i = 1:35
    picture=imread(strcat('mobil',num2str(i, '%i'),'.jpg'));
%endmultiple
[~,cc]=size(picture);
picture=imresize(picture,[480 NaN]);
a=picture;
if size(picture,3)==3
  picture=rgb2gray(picture);
end
threshold = graythresh(picture);
picture =im2bw(picture,threshold);
% Opening
picture = bwareaopen(picture,200);
%
picture1=bwareaopen(picture,2700);
%Minus
picture2=picture-picture1;
scrsz = get(groot,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
imshow(picture2);
[L,Ne]=bwlabel(picture2);
propied=regionprops(L,'BoundingBox');
hold on
%
squareletter =[];
letterypos =[];
allypos =[];
%Cek panjang lebar, dan y pos
for n=1:size(propied,1)
    if (propied(n).BoundingBox(3)<propied(n).BoundingBox(4))
    squareletter(n)=1;
    letterypos = [letterypos;propied(n).BoundingBox(2)];
    else
    squareletter(n)=0;  
    end
    allypos(n)=propied(n).BoundingBox(2);
end
%Eliminate different position box
letterymedian = median(letterypos);
allarea = [];
for n=1:size(propied,1)
    if (squareletter(n)== 1 && abs(allypos(n)-letterymedian)<20 )
    allarea = [allarea;(propied(n).BoundingBox(3)*propied(n).BoundingBox(4))];  
    
    else
    squareletter(n)=0;    
    end
end
areamedian = median(allarea);
platechar = [];
for n=1:size(propied,1)
    if (squareletter(n)== 1 && ((propied(n).BoundingBox(3)*propied(n).BoundingBox(4))<1.4*areamedian))
    platechar = [platechar n];
    %rectangle('Position',propied(n).BoundingBox,'EdgeColor','b','LineWidth',2)
    else
    squareletter(n)=0;    
    end
end
hold off
plateparsing=0;
Xseparate= [0];
for n=2:size(platechar,2)
    Xseparate = [Xseparate ;(propied(platechar(n)).BoundingBox(1)-propied(platechar(n-1)).BoundingBox(1))];
end
separatemedian = median(Xseparate);
k = 1;
for n=1:size(platechar,2)
    if(Xseparate(n)>separatemedian*1.5)
    k = k*-1;
    end
    if(k==1)
        %huruf
        rectangle('Position',propied(platechar(n)).BoundingBox,'EdgeColor','g','LineWidth',2)
        squareletter(platechar(n))=2;
    end
    if(k==-1)
        %angka
        rectangle('Position',propied(platechar(n)).BoundingBox,'EdgeColor','r','LineWidth',2)
        squareletter(platechar(n))=3;
    end
    
end




final_output=[];
% figure
t=[];
for n=1:Ne
 if(squareletter(n)==2)
  [r,c] = find(L==n);
  n1=picture(min(r):max(r),min(c):max(c));
  n1=imresize(n1,[42,24]);
  %imshow(n1)
  pause(0.2)
  x=[ ];

totalLetters=size(imgfileLetter,2);

 for k=1:totalLetters
    
    y=corr2(imgfileLetter{1,k},n1);
    x=[x y];
    
 end
 t=[t max(x)];
 if max(x)>.45
 z=find(x==max(x));
 out=cell2mat(imgfileLetter(2,z));

final_output=[final_output out];
 end

 end
 
 if(squareletter(n)==3)
  [r,c] = find(L==n);
  n1=picture(min(r):max(r),min(c):max(c));
  n1=imresize(n1,[42,24]);
  %imshow(n1)
  pause(0.2)
  x=[ ];

totalLetters=size(imgfileNumber,2);

 for k=1:totalLetters
    
    y=corr2(imgfileNumber{1,k},n1);
    x=[x y];
    
 end
 t=[t max(x)];
 if max(x)>.45
 z=find(x==max(x));
 out=cell2mat(imgfileNumber(2,z));

final_output=[final_output out];
 end

 end
end
fprintf(file,'%s\t',final_output);

LastNumber=[];
    JustNumber=double(final_output);
    JustNumber=JustNumber(JustNumber<58);
    JustNumber=JustNumber(JustNumber>47);
    JustNumber=JustNumber-48;
    if (~isempty(JustNumber))
        LastNumber=JustNumber(end);
        if (JustNumber(1) >= 7 )
            fprintf(file,'Kendaraan Khusus\n',final_output);
        elseif (mod(LastNumber,2))
            fprintf(file,'Ganjil\n',final_output);
        else
            fprintf(file,'Genap\n',final_output);
        end
    end
end %endmultiple
%%  
    fclose(file);                     
    winopen('number_Plate.txt')
