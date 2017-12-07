function [PeakAreas, FinalImg ,NewPeaks]=find_peakSizes(img,peaks)

FinalImg=zeros(size(img));
if isempty(peaks)
    PeakAreas=[];
    return
end

factor=0.8;
for i=1:size(peaks,1)
    bw=zeros(size(img));
    coords=[peaks(i,2) peaks(i,1)];
    IntesityValue=img(coords(1),coords(2));
    bw(img>factor*IntesityValue)=1;
    labeledImage=bwlabel(bw, 8);
    peaklabel=labeledImage(coords(1),coords(2));
    PeakAreas(i)=bwarea(labeledImage==peaklabel);
    FinalImg(labeledImage==peaklabel)=i;
end
NewPeaks=peaks;

%% Second Method
% %Smooth out the uneven illumination
% I2 = imtophat(img, strel('disk', 10));
% %Sharpen
% sharp_I=imsharpen(I2,'Amount',1, 'Radius',1);
% %Binarize
% level = graythresh(sharp_I);
% BW=im2bw(sharp_I,level);
% %Calculate Distance Matrix
% D = -bwdist(~BW);
% %Watershed
% D(~BW) = -Inf;
% L = watershed(D);
% 
% FinalImg=zeros(size(img)); PeakAreas=[]; ObjectValue=[];
% for i=1:size(peaks,1)
%     BWtemp=zeros(size(img));
%     coords=[peaks(i,2) peaks(i,1)];
% %     linind=sub2ind(size(bw),coords(1),coords(2));
%     ObjectValue(i)=max([L(coords(1),coords(2)),L(coords(1),coords(2)+1),L(coords(1)+1,coords(2)),L(coords(1)-1,coords(2)),L(coords(1),coords(2)-1)...
%         L(coords(1)+1,coords(2)+1),L(coords(1)-1,coords(2)-1),L(coords(1)+1,coords(2)-1),L(coords(1)-1,coords(2)+1)]);
%     if ObjectValue(i)==0 || ObjectValue(i)==1
%         continue
%     end
%     BWtemp= imfill(L==ObjectValue(i),'holes');
%     PeakAreas(i)=bwarea(BWtemp);
%     FinalImg(BWtemp)=i;
% end
% NewPeaks=peaks(ObjectValue~=1 & ObjectValue~=0,:);

%% Plotting
% close all
% figure;
% subplot(2,3,1); 
% imshow(I)
% subplot(2,3,2); imshow(I2);
% title('Filtered Image');
% subplot(2,3,3); imshow(sharp_I);
% title('Sharpened Image');
% subplot(2,3,4); imshow(BW);
% title('Binarized Image');
% subplot(2,3,5); imshow(mat2gray(-D));
% title('Distance Image');
% subplot(2,3,6);
% imshow(label2rgb(L,'jet','w'))
% title('Watershed')
% 
% %Final Image
% Final=I; Final(L==0)=255;
% figure;
% imshow(Final)
% figure;
% imshow(FinalImg)


%% Method 3 Attempt
% hy = fspecial('sobel');
% hx = hy';
% Iy = imfilter(double(I), hy, 'replicate');
% Ix = imfilter(double(I), hx, 'replicate');
% gradmag = sqrt(Ix.^2 + Iy.^2);
% imshow(gradmag)
% se = strel('disk', 2);
% Io = imopen(I, se);
% figure
% imshow(Io)
% Ie = imerode(I, se);
% Iobr = imreconstruct(Ie, I);
% figure
% imshow(Iobr)
% Ioc = imclose(Io, se);
% figure
% imshow(Ioc)
% Iobrd = imdilate(Iobr, se);
% Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
% Iobrcbr = imcomplement(Iobrcbr);
% figure
% imshow(Iobrcbr)
% fgm = imregionalmax(Iobrcbr);
% figure
% imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')
% se2 = strel(ones(2,2));
% fgm2 = imclose(fgm, se2);
% fgm3 = imerode(fgm2, se2);
% % fgm4 = bwareaopen(fgm3, 2);
% I3 = I;
% I3(fgm4) = 255;
% figure
% imshow(I3)
% title('Modified regional maxima superimposed on original image (fgm4)')
% bw = imbinarize(Iobrcbr);

% fgm4=zeros(size(I));
% for i=1:size(Peaks,1)
%     fgm4(Peaks(i,2), Peaks(i,1))=1;
%     fgm4(Peaks(i,2)+1, Peaks(i,1))=1;
%     fgm4(Peaks(i,2)-1, Peaks(i,1))=1;
%     fgm4(Peaks(i,2), Peaks(i,1)+1)=1;
%     fgm4(Peaks(i,2), Peaks(i,1)-1)=1;
% end
% bgm = L == 0;
% gradmag2 = imimposemin(gradmag, bgm | fgm4);
% L = watershed(gradmag2);
% L(L==mode(mode(L)))=1;
