function middlepoint=get_midpoint(Skel)
midlength=floor(sum(sum(Skel))*0.5);
new_skel=Skel;
endpoints_mask=bwmorph(new_skel, 'endpoints');
[endpoints(:,1), endpoints(:,2)]=find(endpoints_mask);
prev_endpoints=[endpoints(1,1),endpoints(1,2)];

for iter=1:midlength %crop edges of skeleton skel_dist times to find the (skel_dist)th point on the skeleton
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