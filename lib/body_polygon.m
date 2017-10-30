function PolyMask=body_polygon(BW,SkelValues,SkelDist1,SkelDist2)
%%
%Settings
N=size(SkelValues,1);
neighbors=20;
SkelInd1=round(SkelDist1*N);
SkelInd2=round(SkelDist2*N);

%Get SkelDist Contour Points
[CurveCoords1, Pixels]=cross_section(SkelInd1, BW, SkelValues, neighbors);
[CurveCoords2, Pixels]=cross_section(SkelInd2, BW, SkelValues, neighbors);
CurveCoords1=round(CurveCoords1);

%Get Polygon Mask between edge and Contour Points
X=[CurveCoords1(1,1); CurveCoords1(2,1); CurveCoords2(2,1); CurveCoords2(1,1)];
Y=[CurveCoords1(1,2); CurveCoords1(2,2); CurveCoords2(2,2); CurveCoords2(1,2)];
PolyMask=poly2mask(X,Y,size(BW,1),size(BW,2));

%Verify poligon is within worm
PolyMask=BW & PolyMask;

% p=regionprops(PolyMask1,'Centroid');
% CC=bwconncomp(PolyMask);
SkelInd1b=SkelInd1; SkelInd2b=SkelInd2;
maxiter=6; i=0;
while SkelInd1b<=N && SkelInd2b>0 && i<maxiter
    SkelInd1b=SkelInd1b+round(0.02*N);
    SkelInd2b=SkelInd2b-round(0.02*N);
    [CurveCoords1, Pixels]=cross_section(SkelInd1b, BW, SkelValues, neighbors);
    [CurveCoords2, Pixels]=cross_section(SkelInd2b, BW, SkelValues, neighbors);
    X=[CurveCoords1(1,1); CurveCoords1(2,1); CurveCoords2(2,1); CurveCoords2(1,1)];
    Y=[CurveCoords1(1,2); CurveCoords1(2,2); CurveCoords2(2,2); CurveCoords2(1,2)];
    NewPolyMask=poly2mask(X,Y,size(BW,1),size(BW,2));
    PolyMask=BW & (PolyMask | NewPolyMask);
    i=i+1;
end

