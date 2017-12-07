function data=scaledata(data) 

scaleData.shift = - mean(data);
stdVals = std(data);
scaleData.scaleFactor = 1./stdVals;
% leave zero-variance data unscaled:
scaleData.scaleFactor(~isfinite(scaleData.scaleFactor)) = 1;

% shift and scale columns of data matrix:
for c = 1:size(data, 2)
    data(:,c) = scaleData.scaleFactor(c) * ...
        (data(:,c) +  scaleData.shift(c));
end

% data=zscore(data);

end