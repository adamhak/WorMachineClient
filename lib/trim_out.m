function outlierIndex=trim_out(x)
newx=x;
percntiles = prctile(x,[5 95]); %5th and 95th percentile
outlierIndex = x < percntiles(1) | x > percntiles(2);
