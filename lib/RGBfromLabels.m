function RGB=RGBfromLabels(img)

RGB=label2rgb(img,'jet',[1 1 1],'shuffle');
logmat(:,:,1)=RGB(:,:,1)==ones(size(img))*255 ;
logmat(:,:,2)=RGB(:,:,2)==ones(size(img))*255;
logmat(:,:,3)=RGB(:,:,3)==ones(size(img))*255;
newlogmat=repmat(all(logmat,3),1,1,3);
RGB(newlogmat)=0; 