function [R2, Coords]=get_R2(BW, SkelValues, pheight)
  
%Settings
neighbors=20; error=0.3; X1_X2jump=20; 
X1_begin=10; default_X1=0.025;

%Get X locations Edge 2
X1=length(SkelValues)-round(X1_begin/pheight);
[CurveCoords, Pixels]=cross_section(X1, BW, SkelValues, neighbors);
X1_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;

%Get Maximum distance from (last pixel - X1_begin/pheight pixels) to 0.9 of length
new_dist=X1_dist;
while new_dist+error > X1_dist && X1>(0.9*length(SkelValues)) 
    X1_dist=new_dist; X1=X1-1;
    [CurveCoords, Pixels]=cross_section(X1, BW, SkelValues, neighbors);
    new_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;
end

%Return to default value if no max cross-section found
if X1<=(0.9*length(SkelValues)) 
    X1=round((1-default_X1)*length(SkelValues));
    [CurveCoords, Pixels]=cross_section(X1, BW, SkelValues, neighbors);
    new_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;
end
X1_dist=new_dist;
Coords{1}=CurveCoords;

%Get Minimum distance from (25/pheight pixels below X1) to 8/10 of length
X2=X1-round(X1_X2jump/pheight);
[CurveCoords, Pixels]=cross_section(X2, BW, SkelValues, neighbors);
X2_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;
new_dist=X2_dist;
while  new_dist - error < X2_dist && X2>((8/10)*length(SkelValues))
    X2_dist=new_dist; X2=X2-1;
    [CurveCoords, Pixels]=cross_section(X2, BW, SkelValues, neighbors);
    new_dist=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;
end
Coords{2}=CurveCoords;
X2_dist=new_dist;

R2=X1_dist/X2_dist;
end
