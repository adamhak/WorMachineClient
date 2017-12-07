function WormNetImages=prepare4wormnet(CurrentImages)

%Collect size and rotate all to horizontal
for i=1:length(CurrentImages)
    sizes(i,:)=size(CurrentImages{i});
    if sizes(i,1)>sizes(i,2)
            CurrentImages{i}=CurrentImages{i}';
            sizes(i,:)=size(CurrentImages{i});
    end
end

%Parameters
scaledsize=[64,128];
q=0.65;
nq = quantile(sizes(:,1),q); mq = quantile(sizes(:,2),q); 
n=nq ; m=nq*2;

%Padding and Rescale
for i=1:length(CurrentImages)
    img=CurrentImages{i};
    %Match Wanted Aspect Ratio with padding
    ratio=size(img,1)/size(img,2);
    if size(img,1)<n && size(img,2)>=m
        %Pad rows to obtain wanted aspect ratio
        neededn=round((size(img,2)/m)*n);
        img2=padarray(img,[round(0.5*(neededn-sizes(i,1))) 0]);
    elseif size(img,1)>=n && size(img,2)<m
        %Pad columns to obtain wanted aspect ratio
        neededm=round((size(img,1)/n)*m);
        img2=padarray(img,[0 round(0.5*(neededm-sizes(i,2)))]);
    elseif size(img,1)<n && size(img,2)<m
        %Pad Smaller Objects on both dimensions
        img2=padarray(img,[round(0.5*(n-sizes(i,1))) round(0.5*(m-sizes(i,2)))]);
    elseif size(img,1)>=n && size(img,2)>=m
        %Pad only 1 dimension of larger objects, to obtain ratio
        if ratio<n/m
           neededn=round((size(img,2)/m)*n);
           img2=padarray(img,[round(0.5*(neededn-sizes(i,1))) 0]);
        else
            neededm=round((size(img,1)/n)*m);
            img2=padarray(img,[0 round(0.5*(neededm-sizes(i,2)))]);
        end
    end    
    
    %Scale all images to 'scaledsize'
    img3=imresize(img2,scaledsize);
    WormNetImages(:,:,1,i)=double(img3);
end
