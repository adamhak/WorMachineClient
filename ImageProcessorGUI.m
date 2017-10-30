function varargout = ImageProcessorGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageProcessorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageProcessorGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before ImageProcessorGUI is made visible.
function ImageProcessorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
clc
addpath(genpath('lib'));
[PATHSTR,~,~]=fileparts((which(mfilename)));
cd(PATHSTR);
handles.output = hObject;
handles.settings=2;
handles.saved=0;

%Display Logo
logo=imread('lib\WMlogo_Small.png');
axes(handles.logo_axes); imshow(logo);
guidata(hObject, handles);

function varargout = ImageProcessorGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;



%% IMPORT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function single_tiff_Callback(hObject, eventdata, handles)
try
    [filename, filepath]=uigetfile('*','Browse for Image File','MultiSelect','off');
    handles.outpath=filepath;
    handles.inpath=fullfile(filepath, filename);
    handles.imgpath=filepath;
    handles.FirstCopy=imread(handles.inpath);
    handles.Planes{1}=handles.FirstCopy;
    handles.planenames{1}=['Plane ' num2str(1)];
    set(handles.input_path,'String',handles.inpath)
    set(handles.worms_path,'string',handles.outpath)
    set(handles.planes_list,'string',handles.planenames)
    set(handles.ovlp_list,'string',handles.planenames)
    set(handles.planes_list,'Value',1)
catch
    set(handles.status,'String','Status: Image too large. Try cropping to smaller segments.')
end
guidata(hObject, handles)

% --------------------------------------------------------------------
function multi_tiff_Callback(hObject, eventdata, handles)
try
    %Browse and Save Paths
    [filename, filepath]=uigetfile('*','Browse for Image File','MultiSelect','off');
    set(handles.status,'String',['Status: Importing Image...'])
    pause(0.0001)
    handles.outpath=filepath;
    handles.inpath=fullfile(filepath, filename);
    handles.imgpath=filepath;
    %Load Images
    info = imfinfo(handles.inpath);
    for i=1:length(info)
        if length(info)>1
        handles.Planes{i}=imread(handles.inpath,'Index',i);
        else
        handles.Planes{i}=imread(handles.inpath);
        end
        tempimg=handles.Planes{i}(:,:,1);
        tempimg=tempimg(tempimg>0.2*mean(mean(tempimg)));
        modes(i)=mode(mode(tempimg));
        handles.planenames{i}=['Plane ' num2str(i)];
    end
    BFind=find(modes==max(modes));
    handles.FirstCopy=handles.Planes{BFind(1)};
    %Update GUI
    set(handles.input_path,'String',handles.inpath)
    set(handles.worms_path,'string',handles.outpath)
    set(handles.planes_list,'string',handles.planenames)
    set(handles.ovlp_list,'string',handles.planenames)
    set(handles.planes_list,'Value',BFind(1))
    %Locate Overlapping image
    if length(handles.Planes)>1
       inds=1:length(handles.Planes);
       inds(BFind(1))=[];
       handles.OvlpImg{1}=handles.Planes{inds(1)};
       set(handles.overlap_save,'Value',1);
       set(handles.ovlp_list,'Value',inds(1));
    end
catch
    set(handles.status,'String','Status: Image too large. Try cropping to smaller segments.')
end
set(handles.status,'String',['Status: Importing Image...Ready!'])
guidata(hObject, handles)


% --------------------------------------------------------------------
function bio_format_Callback(hObject, eventdata, handles)
try
    result=bfopen;
    set(handles.status,'String',['Status: Importing Image...'])
    pause(0.0001)
    Images=result{1,1};
    for i=1:size(Images,1)
        handles.planenames{i}=['Plane ' num2str(i)];
        handles.Planes{i}=Images{i,1};
        tempimg=handles.Planes{i}(:,:,1);
        tempimg=tempimg(tempimg>0.2*mean(mean(tempimg)));
        modes(i)=mode(mode(tempimg));
    end
    BFind=find(modes==max(modes));
    handles.FirstCopy=Images{BFind(1),1};
    set(handles.planes_list,'Value',BFind(1))
    %Save Paths
    pathind=find(Images{BFind(1),2}==';',1,'first');
    pathend=find(Images{BFind(1),2}=='\',1,'last');
    if isempty(pathind)
        pathind=length(Images{BFind(1),2})+1;
    end
    handles.inpath=Images{BFind(1),2}(1:pathind-1);
    handles.imgpath=Images{BFind(1),2}(1:pathend);
    handles.outpath=handles.imgpath;
    %Update GUI
    set(handles.input_path,'String',handles.inpath)
    set(handles.worms_path,'string',handles.outpath)
    set(handles.planes_list,'string',handles.planenames)
    set(handles.ovlp_list,'string',handles.planenames)
    %Locate Overlapping image
    if size(Images,1)>1
       inds=1:length(Images);
       inds(BFind(1))=[];
       handles.OvlpImg{1}=Images{inds(1),1};
       set(handles.overlap_save,'Value',1)
       set(handles.ovlp_list,'Value',inds(1));
    end
catch
    set(handles.status,'String','Status: Image too large. Try cropping to smaller segments.')
end
set(handles.status,'String',['Status: Importing Image...Ready!'])
guidata(hObject, handles)


%% %%%% -------- Executes on button press in loadimage. -------------------
function loadimage_Callback(hObject, eventdata, handles)
%Check for import
if ~isfield(handles,'imgpath')
    set(handles.status,'String','Status: Failed! No Image Imported.')
    return
end

%Reset Variables
if isfield(handles, 'ClsdWorms')
    handles=rmfield(handles,'OrgWorms');
    handles=rmfield(handles,'ClsdWorms');
    handles=rmfield(handles,'Bounds');
    handles=rmfield(handles,'WormCount');
    handles=rmfield(handles,'ObjCount');
    if isfield(handles,'OvlpWorms')
        handles=rmfield(handles,'OvlpWorms');
    end
end
handles.saved=0;

set(handles.status,'String',['Status: Loading Image...'])
pause(0.0001);
handles.OrgImg=handles.FirstCopy;
handles.adjustments=0; %restart adjustment counts for this image
axes(handles.axes1);
[x, y, z]=size(handles.OrgImg);
if z>=3 %Turn 3D Images to 2D
    handles.OrgImg=rgb2gray(handles.OrgImg(:,:,1:3)); end
if x>20000
    handles.OrgImg=handles.OrgImg(1:20000,1:end); end
if y>20000
    handles.OrgImg=handles.OrgImg(1:end,1:20000);
end
imshow(handles.OrgImg);
guidata(hObject, handles)
handles=default_values(hObject, eventdata, handles);
set(handles.actual_neighbors,'string',num2str(handles.defaultniegh));
set(handles.pamount,'string',num2str(handles.def_pamount));
handles=set_gray(hObject, eventdata, handles);
set(handles.ovlp_list,'Max',length(handles.planenames));
set(handles.status,'String',['Status: Loading Image...Completed!'])
guidata(hObject, handles)

function preset_values(hObject, eventdata, handles)
switch handles.settings
    case 1
        neighprecent=0.15*100;
        pprecent=0.001*100;
        threshold=18;
    case 2
        neighprecent=0.05*100;
        pprecent=0.0001*100;
        threshold=35;
    case 3
        neighprecent=0.05*100;
        pprecent=0.0001*100;
        threshold=40;
    case 4
        h = findobj('Tag','imageprocessor');
        custompreset=getappdata(h,'custompreset');
        neighprecent=custompreset(1);
        pprecent=custompreset(3);
        threshold=custompreset(2);    
end
set(handles.pprecent,'String',num2str(pprecent));
set(handles.neighprecent,'String',num2str(neighprecent));
set(handles.threshold,'String',num2str(threshold));
if isfield(handles,'OrgImg')
    neighprecent_Callback(hObject, eventdata, handles)
end
guidata(hObject, handles)

function handles=default_values(hObject, eventdata, handles)
[m, n]=size(handles.OrgImg);
pprecent=str2double(get(handles.pprecent,'String'))/100;
neighprecent=str2double(get(handles.neighprecent,'String'))/100;
handles.defaultniegh=round((m+n)/2*neighprecent);
handles.def_pamount=round((m*n)*pprecent);

% --- Executes on selection change in planes_list.
function planes_list_Callback(hObject, eventdata, handles)
ind=get(handles.planes_list,'Value');
handles.FirstCopy=handles.Planes{ind};
loadimage_Callback(hObject, eventdata, handles)
handles=guidata(hObject);
guidata(hObject, handles)

function planes_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in ovlp_list.
function ovlp_list_Callback(hObject, eventdata, handles)
inds=get(handles.ovlp_list,'Value');
if ~isempty(inds)
    planesstring='Plane';
    for i=1:length(inds)
        handles.OvlpImg{i}=handles.Planes{inds(i)};
        planesstring=[planesstring ' ' num2str(inds(i))];
    end
    set(handles.saveplane,'String',planesstring);
else
    set(handles.saveplane,'String','-');
end
guidata(hObject, handles)


function ovlp_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObjecNeighborhoodSizet,'BackgroundColor','white');
end

% --- Executes on button press in grayscale.-------------------------------
function grayscale_Callback(hObject, eventdata, handles)
%Check for loaded
if ~isfield(handles,'OrgImg')
    set(handles.status,'String','Status: Failed! No Image Loaded.')
    return
end
handles=set_gray(hObject, eventdata, handles);
guidata(hObject, handles)

function handles=set_gray(hObject, eventdata, handles)
value = get(handles.grayscale, 'Value');
if value
    axes(handles.axes1)
    high=double(max(max(handles.OrgImg)));
    low=double(min(min(handles.OrgImg)));
    mid=double((high+low)/2)+1000;
    handles.OrgImg=mat2gray(handles.OrgImg,[low mid]);
    imshow(handles.OrgImg);
else
    handles.OrgImg=handles.FirstCopy;
    axes(handles.axes1);
    imshow(handles.OrgImg);
end
guidata(hObject, handles)

% --- Executes on button press in adjust.----------------------------------
function adjust_Callback(hObject, eventdata, handles)
%Check for loaded
if ~isfield(handles,'OrgImg')
    set(handles.status,'String','Status: Failed! No Image Loaded.')
    return
end
handles.adjustments=handles.adjustments+1;
guidata(hObject, handles)
axes(handles.axes1)
if handles.adjustments<20
low=0.01*handles.adjustments;
high=1-0.01*handles.adjustments;
handles.OrgImg=imadjust(handles.OrgImg,[low high],[0 1],1);
end
imshow(handles.OrgImg);
guidata(hObject, handles)

function import_image_Callback(hObject, eventdata, handles)

function input_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function input_path_Callback(hObject, eventdata, handles)
handles.inpath=get(hObject,'String');
guidata(hObject, handles)

function worms_path_Callback(hObject, eventdata, handles)
handles.outpath=get(hObject,'String');
guidata(hObject, handles)

function worms_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% --- Executes on button press in Filter_Image. %%%%%%%%%%%%%%%%%%%%%%%%%
function Filter_Image_Callback(hObject, eventdata, handles)
%Check for loaded
if ~isfield(handles,'OrgImg')
    set(handles.status,'String','Status: Failed! No Image Loaded.')
    return
end
set(handles.status,'String',['Status: Binarizing Image...'])
pause(0.0001);
neighprecent_Callback(hObject, eventdata, handles)
handles=default_values(hObject, eventdata, handles);
neighbor=str2double(get(handles.actual_neighbors,'String'));
if isnan(neighbor)
    set(handles.actual_neighbors,'string',num2str(handles.defaultniegh));
    neighbor=handles.defaultniegh;
end
InvImg=bradley(handles.OrgImg, [neighbor neighbor], str2double(get(handles.threshold,'String')));
handles.FiltImg=InvImg==0; %Inverse logicals
axes(handles.axes2); imshow(handles.FiltImg);
set(handles.status,'String',['Status: Binarizing Image... Completed!'])
guidata(hObject, handles);

function neighbors_Callback(hObject, eventdata, handles)

function neighprecent_Callback(hObject, eventdata, handles)
[m, n]=size(handles.OrgImg);
neighprecent=str2double(get(handles.neighprecent,'String'))/100;
set(handles.actual_neighbors,'String',num2str(round((m+n)/2*neighprecent)));
guidata(hObject, handles);

function actual_neighbors_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function threshold_Callback(hObject, eventdata, handles)
threshold=str2double(get(hObject,'string'));
   if isnan(threshold)
      set(handles.threshold,'string','35');   % when not input a number ,the contents is 5;
   end 
guidata(hObject, handles);

function threshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% --- Executes on button press in noise_filter.%%%%%%%%%%%%%%%%%%%%%%%%%%%
function noise_filter_Callback(hObject, eventdata, handles)
%Check for loaded
if ~isfield(handles,'FiltImg')
    set(handles.status,'String','Status: Failed! No Image Binarized.')
    return
end
set(handles.status,'String',['Status: Clearing small objects...'])
pause(0.000001)
pamount=str2double(get(handles.pamount,'String'));
pprecent_Callback(hObject, eventdata, handles)
handles.FiltImg=imclearborder(handles.FiltImg);
handles.FiltImg=bwareaopen(handles.FiltImg,pamount);
axes(handles.axes2); imshow(handles.FiltImg);
set(handles.status,'String',['Status: Clearing small objects... Completed!'])
guidata(hObject, handles);

function pamount_Callback(hObject, eventdata, handles)

function pamount_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pprecent_Callback(hObject, eventdata, handles)
[m, n]=size(handles.OrgImg);
pprecent=str2double(get(handles.pprecent,'String'))/100;
set(handles.pamount,'String',num2str(round((m*n)*pprecent)));
guidata(hObject, handles);


%% %%%% --- Executes on button press in display_worms. %%%%%%%%%%%%%%%%%%%%
function display_worms_Callback(hObject, eventdata, handles)
%Check for Binarized
if ~isfield(handles,'FiltImg')
    set(handles.status,'String','Status: Failed! No Image Binarized.')
    return
end

set(handles.status,'String',['Status: Identifying Worms...'])
pause(0.0001)
%Gather SD Range
SD_Bottom=-get(handles.idsmall,'Value');
SD_Top=get(handles.idlarge,'Value');

%Collect Region Properties
s=regionprops(handles.FiltImg,'centroid');
handles.NoWormsFlag=0;
if isempty(s)
    handles.NoWormsFlag=1;
    guidata(hObject, handles);
    return
end
BB=regionprops(handles.FiltImg,'BoundingBox');
centroids = cat(1, s.Centroid);
axes(handles.axes2); imshow(handles.FiltImg);
hold on
plot(centroids(:,1),centroids(:,2), 'b*','MarkerSize',3)

%Create Object Area Distribution
for i=1:length(BB)
%     Areas(i)=BB(i).BoundingBox(4)*BB(i).BoundingBox(3);
    Areas(i)=bwarea(imcrop(handles.OrgImg, BB(i).BoundingBox+[-1 -1 1 1]));
end
handles.ObjCount=length(Areas);
SDAreas=(Areas-mean(Areas))./std(Areas);
handles.SDAreas=SDAreas;
handles.Areas=Areas;

%Reset Variables
if isfield(handles, 'ClsdWorms')
    handles=rmfield(handles,'OrgWorms');
    handles=rmfield(handles,'ClsdWorms');
    handles=rmfield(handles,'Bounds');
    handles=rmfield(handles,'WormCount');
end
wormcount=0;
Worms=[];
handles.ClsdWorms=[];

%Update Top & Bottom Areas
Areas_in_Range=Areas(SDAreas>SD_Bottom & SDAreas<SD_Top);
set(handles.bottom_area,'string',num2str(min(Areas_in_Range)));
set(handles.top_area,'string',num2str(max((Areas_in_Range))));


%Mark Objects only in SD Range.
for i=1:length(BB)
    if (SDAreas(i)>SD_Bottom && SDAreas(i)<SD_Top) || length(BB)==1
    wormcount=wormcount+1;
    rectangle('Position', BB(i).BoundingBox,'EdgeColor','r', 'LineWidth', 1); % Add Rectangle
    pause(0.000000000001);
    handles.OrgWorms{wormcount}=imcrop(handles.OrgImg, BB(i).BoundingBox+[-1 -1 1 1]);
    Worms{wormcount}=imcrop(handles.FiltImg, BB(i).BoundingBox+[-1 -1 1 1]); % Save Worm
    handles.ClsdWorms{wormcount}=imclearborder(medfilt2(imfill(Worms{wormcount},'holes'),[15 15]));
    handles.ClsdWorms{wormcount}=keeplargestobject(handles.ClsdWorms{wormcount});
    handles.Bounds{wormcount}=BB(i).BoundingBox+[-1 -1 1 1];
    end
    handles.BBs{i}=BB(i).BoundingBox;
end
hold off

if ~logical(wormcount)
    handles.NoWormsFlag=1;
    guidata(hObject, handles);
    return
end

handles.WormCount=wormcount;
set(handles.wcount,'string',num2str(handles.WormCount));
set(handles.ocount,'string',num2str(handles.ObjCount));
set(handles.status,'String',['Status: Identifying Worms... Completed!'])
pause(0.000000001);
guidata(hObject, handles);


function refresh_idObjects(hObject, eventdata, handles)
SD_Bottom=-get(handles.idsmall,'Value');
SD_Top=get(handles.idlarge,'Value');
%NEED TO DECIDE if to allow these button to update only the rectangles,
%without adding the worms.
% axes(handles.axes2);
% if isfield(handles,'BBs')
% for i=1:length(handles.BBs)
%     rectangle('Position',handles.BBs{i},'EdgeColor','black', 'LineWidth', 1); % Add Rectangle
%     if (handles.SDAreas(i)>SD_Bottom && handles.SDAreas(i)<SD_Top) || length(handles.BBs)==1
%     rectangle('Position',handles.BBs{i},'EdgeColor','r', 'LineWidth', 1); % Add Rectangle
%     end
% end
Areas_in_Range=handles.Areas(handles.SDAreas>SD_Bottom & handles.SDAreas<SD_Top);
set(handles.bottom_area,'string',num2str(min(Areas_in_Range)));
set(handles.top_area,'string',num2str(max((Areas_in_Range))));
% end

function idsmall_Callback(hObject, eventdata, handles)
if isfield(handles,'SDAreas')
refresh_idObjects(hObject, eventdata, handles)
end

function idsmall_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function idlarge_Callback(hObject, eventdata, handles)
if isfield(handles,'SDAreas')
refresh_idObjects(hObject, eventdata, handles)
end

function idlarge_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




%% --- Executes on button press in save_worms. %%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_worms_Callback(hObject, eventdata, handles)
%Check for Identified
if ~isfield(handles,'ClsdWorms')
    set(handles.status,'String','Status: Failed! No Worms Identified.')
    return
end

handles = guidata(hObject);
axes(handles.savefig);
WormsNum=length(handles.ClsdWorms);
set(handles.status,'String',['Status:Saving Worms...'])

%Check for existing output folders
masknums=[];
if logical(exist([handles.outpath 'Masks'],'dir'))
    maskdir=dir([handles.outpath 'Masks']);
    for i=1:length(maskdir)
        if logical(strfind(maskdir(i).name,'Mask'))
            masknums=[masknums str2double(maskdir(i).name(6:9))];
        end
    end
    StartWorm=max(masknums);
else
    StartWorm=0;
end
            
%%%% Save Mask Images %%%%
pad=10; %Pixel number for padding image before closing.
if logical(get(handles.mask_save,'Value'))
    if ~logical(exist([handles.outpath 'Masks'],'dir'))
        mkdir(handles.outpath,'Masks');
    end
    for k=1:WormsNum
        wormnum=num2str(k+StartWorm);
        wormname='0000';
        wormname(end-length(wormnum)+1:end)=wormnum;
        name=sprintf('Mask_%s.bmp',wormname);
        set(handles.savetext,'string',name);
        se = strel('disk',10);
        handles.ClsdWorms{k}=padarray(handles.ClsdWorms{k},[10 10]);
        handles.ClsdWorms{k}=imclose(handles.ClsdWorms{k},se);
        handles.ClsdWorms{k}=imfill(handles.ClsdWorms{k},'holes');
        handles.ClsdWorms{k}=handles.ClsdWorms{k}((pad+1):(end-pad),(pad+1):(end-pad));
        imshow(handles.ClsdWorms{k});
        imwrite(handles.ClsdWorms{k},[handles.outpath,'/Masks/',name],'bmp');
        pause(0.00000001)
    end
end

%%%% Save Original Images %%%%
if logical(get(handles.org_save,'Value'))
    if ~logical(exist([handles.outpath 'Originals'],'dir'))
        mkdir(handles.outpath,'Originals');
    end
    for k=1:WormsNum
        wormnum=num2str(k+StartWorm);
        wormname='0000';
        wormname(end-length(wormnum)+1:end)=wormnum;
        name=sprintf('Worm_%s.bmp',wormname);
        set(handles.savetext,'string',name);
        imshow(handles.OrgWorms{k});
        imwrite(handles.OrgWorms{k},[handles.outpath,'/Originals/',name],'tif');
        pause(0.00000001)
    end
end

%%%% Save Overlapping Images %%%%
%Check if all planes
if logical(get(handles.allplanes_check,'Value'))
    BFind=get(handles.planes_list,'value');
    ovlpinds=1:length(handles.planenames);
    ovlpinds(BFind)=[];
    for i=1:length(ovlpinds)
        handles.OvlpImg{i}=handles.Planes{ovlpinds(i)};
    end
end
        
if logical(get(handles.overlap_save,'Value')) || logical(get(handles.allplanes_check,'Value'))
    %If no overlap image present, search for GFP Image
    if ~isfield(handles,'OvlpImg')
        BFi=strfind(handles.inpath,'BF');
        if logical(exist([handles.inpath(1:BFi-1), 'GFP',handles.inpath(BFi+2:end)],'file')) %find GFP file automatically
            inpath=[handles.inpath(1:BFi-1), 'GFP',handles.inpath(BFi+2:end)];
        else
            [filename, filepath]=uigetfile([handles.imgpath '*'],'Choose Overlapping Image');
            inpath=fullfile(filepath, filename);
        end
        handles.OvlpImg{1}=imread(inpath);
    end
    %Loop over all Overlapping Planes
    for ovlp_plane=1:length(handles.OvlpImg)
       %Create Overlap Folder
        if ovlp_plane==1
            foldname='Overlap';
            if ~logical(exist([handles.outpath foldname],'dir'))
                mkdir(handles.outpath,foldname);
            end
        else
            foldname=['Overlap' num2str(ovlp_plane)];
            if ~logical(exist([handles.outpath foldname],'dir'))
                mkdir(handles.outpath,foldname);
            end
        end
        %Crop and save overlapping worms
        for k=1:WormsNum
                handles.OvlpWorms{k}=imcrop(handles.OvlpImg{ovlp_plane}, handles.Bounds{k});
                wormnum=num2str(k+StartWorm);
                wormname='0000';
                wormname(end-length(wormnum)+1:end)=wormnum;
                name=sprintf('Ovlp_%s.bmp',wormname);
                if ~isempty(handles.OvlpWorms{k})
                set(handles.savetext,'string',name);
                imshow(handles.OvlpWorms{k});
                imwrite(handles.OvlpWorms{k},[handles.outpath,'/' foldname '/',name],'tif');
                pause(0.0000001)
                end
        end
    end
end

handles.saved=1;
set(handles.status,'String',['Status:Saving Worms... Completed!'])
guidata(hObject, handles);


function org_save_Callback(hObject, eventdata, handles)

function mask_save_Callback(hObject, eventdata, handles)

function overlap_save_Callback(hObject, eventdata, handles)

function allplanes_check_Callback(hObject, eventdata, handles)

function save_type_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function savetext_CreateFcn(hObject, eventdata, handles)


%% %%%%% ----------------- Batch Processing ---------------------------%%%%
function auto_Callback(hObject, eventdata, handles)
%Choose folders
folders=uipickfiles('Prompt','Select Folders For Automatic Batch Analysis', 'Output','cell','REFilter','*dir');
%Return if no folder chosen.
if ~iscell(folders)
    return
end

for folder=1:length(folders) %folders loop
        if logical(exist(folders{folder},'dir')) %verify folder is valid
            handles.indir=folders{folder};
            msg=sprintf('Folder: %s',handles.indir);
            set(handles.folder,'string',msg)
            set(handles.folder,'ForegroundColor',[0 0 0])
        else
            msg=sprintf('Folder: %s',folders{folder});
            set(handles.folder,'string',msg)
            set(handles.folder,'ForegroundColor',[1 0 0])
            set(handles.status,'string','Status: Folder Invalid!')
            pause(0.1)
            continue
        end
        dirfiles=dir(handles.indir);
        imgnum=0;
        
        for img=1:length(dirfiles) %images in folder loop
            cons=[~isempty(strfind(dirfiles(img).name,'GFP')), isempty(strfind(dirfiles(img).name,'tif'))];
            if  any(cons) %Skip if not a tiff file, or if has GFP in name.
                continue
            end
            imgnum=imgnum+1;
            filepath=[handles.indir '\'];
            filename=dirfiles(img).name;
%             try
                %Reset
                if isfield(handles,'Planes')
                    handles=rmfield(handles,'Planes');
                    handles=rmfield(handles,'planenames');
                    if isfield(handles,'OvlpImg')
                        handles=rmfield(handles,'OvlpImg');
                    end
                end
                %Load & Import Image
                set(handles.status,'string',sprintf('Status: Image %d, Importing ',imgnum))
                pause(0.000001)
                handles.outpath=filepath;
                handles.inpath=fullfile(filepath, filename);
                handles.imgpath=filepath;
                info = imfinfo(handles.inpath);
                modes=[];
                for i=1:length(info)
                    if length(info)>1
                    handles.Planes{i}=imread(handles.inpath,'Index',i);
                    else
                    handles.Planes{i}=imread(handles.inpath);
                    end
                    tempimg=handles.Planes{i}(:,:,1);
                    tempimg=tempimg(tempimg>0.2*mean(mean(tempimg)));
                    modes(i)=mode(mode(tempimg));
                    handles.planenames{i}=['Plane ' num2str(i)];
                end
                BFind=find(modes==max(modes));
                handles.FirstCopy=handles.Planes{BFind};
                %Update GUI
                set(handles.input_path,'String',handles.inpath)
                set(handles.planes_list,'string',handles.planenames)
                set(handles.planes_list,'Value',BFind)
                set(handles.worms_path,'string',handles.outpath)
                set(handles.ovlp_list,'string',handles.planenames)
                %Locate Overlapping image
                if length(handles.Planes)>1
                   inds=1:length(handles.Planes);
                   inds(BFind)=[];
                   handles.OvlpImg{1}=handles.Planes{inds(1)};
                   set(handles.overlap_save,'Value',1)
                   set(handles.ovlp_list,'Value',inds(1));
                end
                guidata(hObject, handles);
                pause(0.000001)
                
                %Run Step 1
                set(handles.status,'string',sprintf('Status: Image %d, Loading ',imgnum))
                pause(0.000001)
                loadimage_Callback(hObject, eventdata, handles)
                handles=guidata(hObject);
                %Run Step 2
                set(handles.status,'string',sprintf('Status: Image %d, Binarizing',imgnum))
                pause(0.000001)
                Filter_Image_Callback(hObject, eventdata, handles)
                handles=guidata(hObject);
                %Run Step 2.1
                set(handles.status,'string',sprintf('Status: Image %d, Appling Filter',imgnum))
                pause(0.000001)
                noise_filter_Callback(hObject, eventdata, handles)
                handles=guidata(hObject);
                %Run Step 3
                set(handles.status,'string',sprintf('Status: Image %d, Identifying Worms',imgnum))
                pause(0.000001)
                display_worms_Callback(hObject, eventdata, handles)
                handles=guidata(hObject);
                if handles.NoWormsFlag %Continue if no worms in image
                    set(handles.status,'string',sprintf('Status: Image %d, No Worms Found!',imgnum))
                    pause(0.0000001)
                    continue
                end
                %Run Step 4
                set(handles.status,'string',sprintf('Status: Image %d, Saving Worms',imgnum))
                pause(0.0000001)
                save_worms_Callback(hObject, eventdata, handles)
                handles=guidata(hObject);
%             catch
%                 continue
%             end
        end
end
Congratulations()
guidata(hObject, handles);


%% --- Executes on button press in back. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function backtool_ClickedCallback(hObject, eventdata, handles)
close all
WorMachine

% --------------------------------------------------------------------
function next_ClickedCallback(hObject, eventdata, handles)
if isfield(handles, 'outpath') && handles.saved
   close all
   FeaturesGUI(handles.outpath) 
else
   close all
   FeaturesGUI
end


%% HELP ------------------------------------------------------------- %%%%
function help_Callback(hObject, eventdata, handles)

function import_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function tif_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function bio_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function formats_help_Callback(hObject, eventdata, handles)
web('https://www.openmicroscopy.org/site/support/bio-formats5.1/supported-formats.html');

% --------------------------------------------------------------------
function load_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function bin_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function id_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function save_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function preset_help_Callback(hObject, eventdata, handles)



%% Preset Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function presets_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function low_res_Callback(hObject, eventdata, handles)
handles.settings=1;
set(handles.low_res,'Checked','on');
set(handles.obj_4,'Checked','off');
set(handles.obj_10,'Checked','off');
set(handles.custom_preset,'Checked','off');
set(handles.threshold,'String','18');
preset_values(hObject, eventdata, handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function obj_4_Callback(hObject, eventdata, handles)
handles.settings=2;
set(handles.low_res,'Checked','off');
set(handles.obj_4,'Checked','on');
set(handles.obj_10,'Checked','off');
set(handles.custom_preset,'Checked','off');
set(handles.threshold,'String','35');
preset_values(hObject, eventdata, handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function obj_10_Callback(hObject, eventdata, handles)
handles.settings=3;
set(handles.low_res,'Checked','off');
set(handles.obj_4,'Checked','off');
set(handles.obj_10,'Checked','on');
set(handles.custom_preset,'Checked','off');
set(handles.threshold,'String','40');
preset_values(hObject, eventdata, handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function custom_preset_Callback(hObject, eventdata, handles)
handles.settings=4;
set(handles.low_res,'Checked','off');
set(handles.obj_4,'Checked','off');
set(handles.obj_10,'Checked','off');
set(handles.custom_preset,'Checked','on');
settingsgui()
guidata(hObject, handles);
