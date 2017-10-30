function peaks=fluorpeaks(img,thr,n)
%Finds peaks indices from a fluorescent img.

hLocalMax = vision.LocalMaximaFinder;
hLocalMax.MaximumNumLocalMaxima = 10000;
hLocalMax.NeighborhoodSize = [n n];
hLocalMax.Threshold =thr;
peaks=step(hLocalMax, img);

end

