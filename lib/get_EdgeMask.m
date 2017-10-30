function finalmask=get_EdgeMask(BW,SkelValues,SkelDist)

%Settigns
N=size(SkelValues,1);
SkelInd=round(SkelDist*N);
neighbors=20;
x1=SkelValues(SkelInd,2);  y1=SkelValues(SkelInd,1);

%Verify neighbors is even
if mod(neighbors,2)
    neighbors=neighbors+1;
end

%Fit Quadratic Curve
if SkelInd<=neighbors/2
    coeffs = fit(SkelValues(SkelInd:(SkelInd+neighbors),2), SkelValues(SkelInd:(SkelInd+neighbors),1), 'poly2');
elseif SkelInd>(length(SkelValues)-neighbors/2)
    coeffs = fit(SkelValues((SkelInd-neighbors):SkelInd,2), SkelValues((SkelInd-neighbors):SkelInd,1), 'poly2');
else
    coeffs = fit(SkelValues((SkelInd-neighbors/2):(SkelInd+neighbors/2),2), SkelValues((SkelInd-neighbors/2):(SkelInd+neighbors/2),1),  'poly2');
end

%Set parameters for line equation y=mx+b
slope=2*x1*coeffs.p1+coeffs.p2;
m=-1/slope; maxslope=500;
%Set m limits
if abs(m)<0.000001
    m=0;
elseif m>maxslope
    m=maxslope;
elseif m<-maxslope
    m=-maxslope;
end
b=y1-m*x1;

%Set Cross section limits
first_x=1; last_x=size(BW,2);
first_y=round(first_x*m+b); 
last_y=round(last_x*m+b);

%Obtain Cross Section Data
[cx,cy,c,xi,yi]=improfile(BW,[first_x last_x], [first_y last_y]);mask1 = poly2mask([0; size(BW,2); xi(end:-1:1)] ,[0 ; 0; yi(end:-1:1)],size(BW,1),size(BW,2));

%Choose Appropriate Side of the Image
mask2 = ~mask1;
if SkelDist<=0.5
    SkelValueCheck=SkelValues(1,:);
else
    SkelValueCheck=SkelValues(N,:);
end
if mask1(SkelValueCheck(1),SkelValueCheck(2))
    mask=mask1;
else
    mask=mask2;
end

%Clear any other objects that are not the edge in the mask
tempmask=BW & mask;
s= regionprops(tempmask);
for ii=1:length(s)
    d(ii)=pdist([x1 y1;s(ii).Centroid],'euclidean');
end
finalmask=tempmask;
for i3=1:length(s)
    if d(i3)>min(d)
        BB=round(s(i3).BoundingBox);
        finalmask(BB(2):(BB(2)+BB(4)),BB(1):(BB(1)+BB(3)))=0;
    end
end

