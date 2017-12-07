function [sorted_xy]=IndexSkel(Skel)
%Input: a binary image with a continous line.
%Output: Sorted line coordinates in [x y] matrix

pixnum=sum(sum(Skel));
[x, y]=find(Skel);
data=[x y];

%Find an edge of the line
endpoints_mask=bwmorph(Skel, 'endpoints');
[endpoints(1,:), endpoints(2,:)]=find(endpoints_mask);
rowstart=find(ismember(data,endpoints(:,1)','rows'));
%Replace the edge so it is the first coordinate in data
data(rowstart,:)=data(1,:);
data(1,:)=endpoints(:,1)';
%Calculate distances between all coords
dist = pdist2(data,data);
%Find data coordinates order and save in 'results'
result = NaN(1,pixnum);
result(1) = 1; % first point is first row in data matrix
for ii=2:pixnum
    dist(:,result(ii-1)) = Inf;
    [~, closest_idx] = min(dist(result(ii-1),:));
    result(ii) = closest_idx;
end
%Sort coordinates order using result
sorted_xy=data(result,:);