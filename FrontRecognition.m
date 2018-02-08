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
I=imread(strcat('mobil',num2str(i, '%i'),'.jpg'));
    %%Lokalisasi
    
    %offset = [50 20 100 40];
offset = [40 10 90 40];
%https://www.mathworks.com/matlabcentral/answers/61441-how-can-select-a-region-in-image
answer = 1;
    hasil = [];
    counthasil = 0;
    counterhasil = 0;
    im1=rgb2gray(I);
    im1=medfilt2(im1,[2 2]);
    %figure(1), imshow(im1);

    %%Edge detect using sobel
    Mhe = [-1 -1 -1; 0 0 0; 1 1 1]; % horizontal edge detection
    Mve = [-1 0 1; -1 0 1; -1 0 1]; % vertical edge detection
    hor = imfilter(im1,Mhe);
    %figure, imshow(hor);
    ver = imfilter(im1,Mve);
    %figure, imshow(ver);
    s_wynikowy = abs(ver) + abs(hor);
    [RR CC]=size(s_wynikowy);

    for i=1:RR
        for j=1:CC
            if (s_wynikowy(i,j)<100) % intensity of pixel which is below the thresold ... = 0
                s_wynikowy(i,j)=0;
            end 
        end 
    end

    BW=im2bw(s_wynikowy,0.15);
    %figure(2); imshow(s_wynikowy)

    %%Dilasi dan Opening
    [rr cc]=size(BW);
    %figure(3); imshow(BW)
    msk=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
         1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
         1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
         1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
         0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;];

     dil=imdilate(BW, msk);
     %figure(4); imshow(dil);

     %se=ones (13, 52);
     se=ones (20, 72);
     I_opened = imopen(dil,se);
    %figure(9); imshow(I_opened);
    SE = strel('square', 5)
     I_opened=imdilate(I_opened, SE);
    L = bwlabel(I_opened,8);
    mx=max(max(L))

    b_meas = regionprops(L, 'all'); 
    stats = [regionprops(I_opened); regionprops(not(I_opened))]
    numberOfBlobs = size(b_meas, 1);
    %figure(5), imshow(I_opened,[])

    %%%
    %for k = 1 : numberOfBlobs
    %
    %    rectangle('Position', stats(k).BoundingBox, ...
    %    'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
    %end
    %%%
    
    
    
    %figure; imagesc(I); axis;
    
    %hold on;
    boundaries = bwboundaries(I_opened);	
    for k = 1 : numberOfBlobs
        luas = stats(k).BoundingBox(3) * stats(k).BoundingBox(4) ;
        if luas < 12000 & luas > 1800
            rasio = stats(k).BoundingBox(3) / stats(k).BoundingBox(4);
            %rasio > 3 & stats(k).BoundingBox(1) < 500 & stats(k).BoundingBox(1)> 200
            if rasio > 1.6 & rasio< 6.7 & stats(k).Centroid(1) < 420 & stats(k).Centroid(1)> 200 & stats(k).Centroid(2) > 240
                counthasil = counthasil+1;
                hasil = [hasil k] 
            end
        end
    end
    
    if (counthasil < 2 & counthasil > 0)
        
        posx = stats(hasil(1)).BoundingBox(1) - offset(1);
    posy = stats(hasil(1)).BoundingBox(2) - offset(2);
    lengthx = stats(hasil(1)).BoundingBox(3)+ offset(3);
    lengthy = stats(hasil(1)).BoundingBox(4)+ offset(4);
    potongan = imcrop(I,[posx posy lengthx lengthy]);
    
    if (lengthx / lengthy) < (191/64)
        lengthy = lengthx * (64/191);
    end
    
       % rectangle('Position', [posx posy lengthx lengthy], ...
         %           'Linewidth', 3, 'EdgeColor', 'g');
    
   %figure,imshow(potongan);
    end
    
    
    
    if (counthasil > 1)
        
        for j = 1 : counthasil
            
        %rectangle('Position', stats(hasil(j)).BoundingBox, ...
        %            'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
        
        
        end

        answer = 1;
        middledistance = abs (stats(hasil(1)).Centroid(1) - 300);
        
        for k = 2 : counthasil
            
            test = abs (stats(hasil(k)).Centroid(1) - 300);
            luas = stats(hasil(k)).BoundingBox(3) * stats(hasil(k)).BoundingBox(4) ;
            if test < middledistance && luas > 3000 && stats(hasil(k)).Centroid(2) > 260
                middledistance = test;
                answer = k;
            end
            
        end
        
    posx = stats(hasil(answer)).BoundingBox(1) - offset(1);
    posy = stats(hasil(answer)).BoundingBox(2) - offset(2);
    lengthx = stats(hasil(answer)).BoundingBox(3) + offset(3);
    lengthy = stats(hasil(answer)).BoundingBox(4) + offset(4);
    potongan = imcrop(I,[posx posy lengthx lengthy]);
    
    if (lengthx / lengthy) < (191/64)
        lengthy = lengthx * (64/191);
    end
    
        %rectangle('Position', [posx posy lengthx lengthy], ...
                   % 'Linewidth', 3, 'EdgeColor', 'g');
        %figure,imshow(potongan);
    end
    
    
    %hold off;
%%EndLokalisasi
%Rekognisi
%imshow(potongan);
picture=potongan;
[~,cc]=size(picture);
picture=imresize(picture,[480 NaN]);
a=picture;
if size(picture,3)==3
  picture=rgb2gray(picture);
end
threshold = graythresh(picture);
picture =im2bw(picture,threshold);



% Opening
picture = bwareaopen(picture,2000);
%
picture1=bwareaopen(picture,15000);
%Minus
picture2=picture-picture1;
scrsz = get(groot,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
imshow(a);



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
    if (squareletter(n)== 1 && abs(allypos(n)-letterymedian)<50 )
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
    %%
    winopen('number_Plate.txt')
