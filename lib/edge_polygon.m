function PolyMask=edge_polygon(BW,SkelValues,SkelDist)
%%
%Settings
N=size(SkelValues,1);
SafetyDistance=round(0.015*N); %pixels to distant polygon from edge, for safety.
if SkelDist<=0.5 %Determine Edge index from which to start polygon
    Edgeind=SafetyDistance;
else
    Edgeind=N-SafetyDistance;
end
neighbors=20;
SkelInd=round(SkelDist*N);

%Get SkelDist Contour Points
[CurveCoords, Pixels]=cross_section(SkelInd, BW, SkelValues, neighbors);
CurveCoords=round(CurveCoords);

%Get Polygon Mask between edge and Contour Points
X=[SkelValues(Edgeind,2);CurveCoords(1,1); CurveCoords(2,1)];
Y=[SkelValues(Edgeind,1);CurveCoords(1,2); CurveCoords(2,2)];
PolyMask=poly2mask(X,Y,size(BW,1),size(BW,2));

%Verify poligon is within worm
PolyMask=BW & PolyMask;