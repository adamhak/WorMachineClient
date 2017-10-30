function cleanmask=keeplargestobject(bw)
% Return the same BW Image, with only the largest identified object
% remaining.
s= regionprops(bw,'area');
cleanmask=bw;
if length(cat(1,s.Area))>1
maxarea=floor(max(cat(1,s.Area)));
cleanmask=bwareaopen(bw,maxarea-1);
end
end