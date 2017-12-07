function find_outliers(hObject, eventdata, handles)

for i=1:length(handles.liststring)
    Areas(i)=handles.Masks(i).Area;
    Lengths(i)=handles.Masks(i).Length;
    BPs(i)=handles.Masks(i).BP;
    Iters(i)=handles.Masks(i).Iter;
end

%Find Outliers
ZAreas=zscore(Areas);
indx=find([(ZAreas>1) + (ZAreas<-1)]);
for i=indx
    handles.wormflags{i}=1;
    handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'green', handles.Masks(i).Filenames);
end
ZLengths=zscore(Lengths);
indx=find([(ZLengths>1) + (ZLengths<-1)]);
for i=indx
    handles.wormflags{i}=1;
    handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'blue', handles.Masks(i).Filenames);
end
indx=find(Iters>8);
for i=indx
    handles.wormflags{i}=1;
    handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'orange', handles.Masks(i).Filenames);
end
indx=find(BPs>1);
for i=indx
    handles.wormflags{i}=1;
    handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'red', handles.Masks(i).Filenames);
end