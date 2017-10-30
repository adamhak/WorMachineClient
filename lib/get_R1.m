function [R1, Coords]=get_R1(BW, SkelValues, pheight)

%Settings
neighbors=20; error=0.3; X1_X2jump=20; 
X1_begin=10; default_X1=0.025;

%Get X locations Edge 1
X1=round(X1_begin/pheight); 
[CurveCoords, Pixels]=cross_section(X1, BW, SkelValues, neighbors);
X1_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;

%Get Maximum distance from 15/pheight pixels to 0.1 of length
new_dist=X1_dist;
while new_dist+error > X1_dist && X1<(0.1*length(SkelValues))
    X1_dist=new_dist; X1=X1+1;
    [CurveCoords, Pixels]=cross_section(X1, BW, SkelValues, neighbors);
    new_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;
end

%Return to default value if no max cross-section found
if X1>=(0.1*length(SkelValues)) 
    X1=round(default_X1*length(SkelValues));
    [CurveCoords, Pixels]=cross_section(X1, BW, SkelValues, neighbors);
    new_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;
end
X1_dist=new_dist;
Coords{1}=CurveCoords;

%Get Minimum distance from (X1_X2jump/pheight pixels above X1) to 2/10 of length
X2=X1+round(X1_X2jump/pheight);
[CurveCoords, Pixels]=cross_section(X2, BW, SkelValues, neighbors);
X2_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;
new_dist=X2_dist;
while  new_dist-error < X2_dist && X2<(0.2*length(SkelValues))
    X2_dist=new_dist; X2=X2+1;
    [CurveCoords, Pixels]=cross_section(X2, BW, SkelValues, neighbors);
    new_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;
end
X2_dist=new_dist;
Coords{2}=CurveCoords;

R1=X1_dist/X2_dist;
end