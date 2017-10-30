function [X_start, X_end]=get_X12(skel, skel_dist)

new_skel=skel;
    for iter=1:skel_dist %crop edges of skeleton skel_dist times to find the (skel_dist)th point on the skeleton
        last_skel=new_skel;
        %endpoints=find_skel_ends(last_skel);
        endpoints_mask=bwmorph(last_skel, 'endpoints');
        [i j]=find(endpoints_mask);
        endpoints=[j, i];
        last_skel(endpoints(1,2),endpoints(1,1))=0;
        last_skel(endpoints(2,2),endpoints(2,1))=0;
        new_skel=last_skel;
    end
X_start=[endpoints(1,2),endpoints(1,1)];
X_end=[endpoints(2,2),endpoints(2,1)];
end