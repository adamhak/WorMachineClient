function [CurveCoords, Pixels]=cross_section(SkelInd, BW, SkelValues, neighbors)

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
m=-1/slope;
% if m<0.00001
%     m=0;
% elseif m>100000
%     invslope=100000;
% end
b=y1-m*x1;

%Set Cross section limits
first_x=1; last_x=length(BW);
first_y=round(first_x*m+b); 
last_y=round(last_x*m+b);

%Obtain Cross Section Data
[cx,cy,c,xi,yi]=improfile(BW,[first_x last_x], [first_y last_y]);
valid_points=c(~isnan(c)); cx=cx(~isnan(c));cy=cy(~isnan(c)); %Remove NaNs
%Get Index of Curve Coordinates of cross section closest to Skeleton Coords
indice=find(valid_points)';
first_diff_ind=[true diff(indice)>1];
firstinds=indice(first_diff_ind);
last_diff_ind=[diff(indice)>1 true];
lastinds=indice(last_diff_ind);
if length(lastinds)>1 %In case Cross-Section passes through worm several times
    CurveCoords=[cx(lastinds'), cy(lastinds')]; %cx(firstinds'), cy(firstinds');
    dist = pdist2(CurveCoords,[x1 y1]);
    [~, closest_idx] = min(dist); %Choose index 
    lastind=lastinds(closest_idx); firstind=firstinds(closest_idx);
else 
    lastind=find(valid_points,1,'last'); firstind=find(valid_points,1,'first');
end

Pixels=sum(valid_points(firstind:lastind)); %Sum pixels
CurveCoords=[cx(firstind), cy(firstind); cx(lastind), cy(lastind)];
