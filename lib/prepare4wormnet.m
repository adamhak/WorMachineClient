function WormNetImages=prepare4wormnet(CurrentImages)

%Collect size and rotate all to horizontal
for i=1:length(CurrentImages)
    sizes(i,:)=size(CurrentImages{i});
    if sizes(i,1)>sizes(i,2)
            CurrentImages{i}=CurrentImages{i}';
            sizes(i,:)=size(CurrentImages{i});
    end
end

% maxsize=max(sizes,[],1);
% nmax=maxsize(1);  mmax=maxsize(2);
% meansize=round(mean(sizes,1));
% nmean=meansize(1); mmean=meansize(2);
% mediansize=round(median(sizes,1));
% nmedian=mediansize(1); mmedian=mediansize(2);
zscored=zscore(sizes);
nz=sizes(find(zscored(:,1)>1 & zscored(:,1)<1.2,1,'first'),1);
mz=sizes(find(zscored(:,2)>1 & zscored(:,2)<1.2,1,'first'),2);

scaledsize=[64,128];
n=nz ; m=mz;
for i=1:length(CurrentImages)
    img=CurrentImages{i};
    
    %Match Aspect Ratio with padding
    ratio=size(img,1)/size(img,2);
    if size(img,1)<n & size(img,2)>=m
        neededn=round((size(img,2)/m)*n);
        img2=padarray(img,[round(0.5*(neededn-sizes(i,1))) 0]);
    elseif size(img,1)>=n & size(img,2)<m
        neededm=round((size(img,1)/n)*m);
        img2=padarray(img,[0 round(0.5*(neededm-sizes(i,2)))]);
    else
        if ratio<n/m
           neededn=round((size(img,2)/m)*n);
           img2=padarray(img,[round(0.5*(neededn-sizes(i,1))) 0]);
        else
            neededm=round((size(img,1)/n)*m);
            img2=padarray(img,[0 round(0.5*(neededm-sizes(i,2)))]);
        end
    end
    
    %Pad Smaller Objects
    if size(img,1)<n & size(img,2)<m
       img2=padarray(img2,[round(0.5*(n-sizes(i,1))) round(0.5*(m-sizes(i,2)))]);
    end
    
    %Scale all images to 'scaledsize'
    img3=imresize(img2,scaledsize);
    WormNetImages(:,:,1,i)=double(img3);
end