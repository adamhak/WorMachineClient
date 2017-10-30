function [sorted_xy]=IndexSkel(Skel)
%Input: a binary image with a continous line.
%Output: 
pixnum=sum(sum(Skel));
[x y]=find(Skel);
data=[x y];

%Find an edge of the line
rowstart=find(ismember(data,endpoints(:,1)','rows'))
%Replace the edge so it is the first coordinate in data
data(rowstart,:)=data(1,:);
data(1,:)=endpoints(:,1)';
dist = pdist2(data,data);
result = NaN(1,pixnum);
result(1) = 1; % first point is first row in data matrix

for ii=2:pixnum
    dist(:,result(ii-1)) = Inf;
    [~, closest_idx] = min(dist(result(ii-1),:));
    result(ii) = closest_idx;
end

sorted_xy=data(result,:);

for iter=1:pixnum %crop edges of skeleton skel_dist times to find the (skel_dist)th point on the skeleton
    last_skel=new_skel;
    endpoints_mask=bwmorph(last_skel, 'endpoints');
    [endpoints(:,1), endpoints(:,2)]=find(endpoints_mask);
    first_dist=max(abs(endpoints(1,:)-prev_endpoints));
    sec_dist=max(abs(endpoints(2,:)-prev_endpoints));
    [x, end_ind]=min([first_dist sec_dist]);
    prev_endpoints=[endpoints(end_ind,1),endpoints(end_ind,2)];
    last_skel(prev_endpoints(1,1),prev_endpoints(1,2))=0;
    new_skel=last_skel;
end

middlepoint=prev_endpoints;
end

test=zeros(size(BW));
figure;
for i=1:length(sorted_xy)/2
%     imshow(test)
    test(sorted_xy(i,1), sorted_xy(i,2))=1;
%     drawnow
%     pause(0.01)
end

stats = regionprops(test,'perimeter');
perims  = [stats.Perimeter];

%% 

endpoints_mask=bwmorph(Skel, 'endpoints');
[endpoints(1,:), endpoints(2,:)]=find(endpoints_mask);
test(endpoints(1,1),endpoints(2,1))=1



test=zeros(size(BW));
test(sortedrows(pixnum/2,1),sortedrows(pixnum/2,2))=1;
 imshow(test)