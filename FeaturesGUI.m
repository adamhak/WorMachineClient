function varargout = FeaturesGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FeaturesGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FeaturesGUI_OutputFcn, ...
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


%% --- Executes just before FeaturesGUI is made visible.
function FeaturesGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.filesep=filesep;
clc
addpath(genpath('lib'));
[PATHSTR,~,~]=fileparts((which(mfilename)));
cd(PATHSTR);
handles.datasaved=1;
handles.fluortype=2;
if length(varargin)>0
    handles.dirname=varargin{1}(1:end-1);
    loadimages_Callback(hObject, eventdata, handles)
    handles=guidata(hObject);
end

%Display Logo
logo=imread(['lib' handles.filesep 'WMlogo_Small.png']);
axes(handles.logo_axes); imshow(logo);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = FeaturesGUI_OutputFcn(hObject, eventdata, handles) 
if isfield(handles,'output')
varargout{1} = handles.output;
end

%% Filepath for Image Importation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function import_Callback(hObject, eventdata, handles)

function worm_images_Callback(hObject, eventdata, handles)
dirname=uigetdir('','Browse for Mask Files');
if ~strcmp(num2str(dirname),'0')
    handles.dirname=dirname;
    set(handles.filespath,'string',handles.dirname)
end
guidata(hObject, handles)
   
function filespath_Callback(hObject, eventdata, handles)
dirname=get(hObject,'String');
if ~isempty(dirname)
    handles.dirname=dirname;
end
guidata(hObject, handles)

function filespath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function masknames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Remove Worms from dataset using previously analyzed set
function worm_names_Callback(hObject, eventdata, handles)
if ~isfield(handles,'Masks')
    return
end
[filename, pathname]=uigetfile({'*.mat;*.xlsx;*.csv','MAT/Excel/CSV'},'Browse for WormData .mat or .xlsx File',handles.dirname);
if contains(filename,'.xlsx')
   [~,~,RAW]=xlsread(fullfile(pathname,filename),'WormData');
   WormNames=RAW(2:end,strcmp('Worm_Names',RAW(1,:)));
elseif contains(filename,'.mat')
   tempdata=load(fullfile(pathname,filename));    
   WormNames=tempdata.WormData.Names;
elseif contains(filename,'.csv')
   M = csvread(fullfile(pathname,filename)); 
   WormNames=M(2:end,strcmp('Worm_Names',M(1,:)));
elseif filename==0
    return
end

clear tempdata RAW
actionflag=false;
for i=length(handles.Masks):-1:1
    if ~ismember(handles.Masks(i).Filenames,WormNames)
        set(handles.current_worm,'string','Removing Worms...');
        set(handles.masknames,'Value',i)
        handles=guidata(hObject);
        removeworm_Callback(hObject, eventdata, handles)
        actionflag=true;
    end
end
uicontrol(handles.masknames)
if actionflag
    set(handles.current_worm,'string','Objects Removal Complete!');
else
    set(handles.current_worm,'string','No Objects to Remove!');
end

%% Update Lables using previously analyzed set
function extract_labels_Callback(hObject, eventdata, handles)
if ~isfield(handles,'Masks')
    return
end
[filename, pathname]=uigetfile({'*.mat;*.xlsx','MAT/Excel'},'Browse for WormData .mat or .xlsx File',handles.dirname);
if ~isempty(strfind(filename,'.xlsx'))
   [~,~,RAW]=xlsread(fullfile(pathname,filename));
   WormNames=RAW(2:end,1);
   labelcol=find(strcmp(RAW(1,:),'Labels'));
   if isempty(labelcol)
       set(handles.current_worm,'string','Dataset Contains No Labels');
       return
   end
   Labels=(RAW(2:end,labelcol));
elseif ~isempty(strfind(filename,'.mat'))
   tempdata=load(fullfile(pathname,filename));    
   if ~isfield(tempdata.WormData,'Y')
       set(handles.current_worm,'string','Dataset Contains No Labels');
       return
   end
   WormNames=tempdata.WormData.Names;
   Labels=tempdata.WormData.Y;
end

if any(~iscell(Labels))
    Labels=num2cell(Labels);
end

clear tempdata RAW labelcol
actionflag=false;
for i=1:length(handles.Masks)
    if ismember(handles.Masks(i).Filenames,WormNames)
        ind=find(strcmp(WormNames,handles.Masks(i).Filenames),1,'first');
        handles.Masks(i).Label=Labels(ind);
        set(handles.current_worm,'string','Extracing and Updating Labels...');
        actionflag=true;
    end
end
if actionflag
    count_labels(hObject, eventdata, handles)
    set(handles.current_worm,'string','Worms Labels Updated!');
else
    set(handles.current_worm,'string','No Labels to Update.');
end
masknames_Callback(hObject, eventdata, handles)
uicontrol(handles.masknames)
guidata(hObject, handles)


%% --- Executes on button press in loadimages. %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadimages_Callback(hObject, eventdata, handles)
%Check for import
if ~isfield(handles,'dirname')
    set(handles.current_worm,'string','No Worms Imported!');
    return
end

%Check valid path
if isempty(strfind(handles.dirname,'Masks')) && ~exist([handles.dirname handles.filesep 'Masks'],'dir')
    set(handles.current_worm,'string','No Worms in Folder!');
    return
end

%Reset Variables
handles.currentmask=1;
if isfield(handles,'Masks')
    handles=rmfield(handles,'Masks');
    handles=rmfield(handles,'liststring');
    handles=rmfield(handles,'maindir');
    handles=rmfield(handles,'wormflags');
    handles=rmfield(handles,'OrgCount');
    handles=rmfield(handles,'imgtype');
    handles.datasaved=1;
end
handles.rmvcount=0;
handles.rmvnames={};
set(handles.current_worm,'string','Loading Mask Images...');
pause(0.0001);
set(handles.check_area,'Value',0);
set(handles.check_length,'Value',0);
set(handles.check_thick,'Value',0);
set(handles.check_mid,'Value',0);
set(handles.check_headtail,'Value',0);
set(handles.check_peaks,'Value',0);
set(handles.check_ctwf,'Value',0);
set(handles.check_labels,'Value',0);
set(handles.check_bodybf,'Value',0);
set(handles.check_rid,'Value',0);
set(handles.check_ht_ctfw,'Value',0);
set(handles.labeled,'string','');


%Load Mask Files
if ~strcmp(handles.dirname(end-4:end),'Masks')
    handles.maindir=[handles.dirname handles.filesep];
    handles.dirname=[handles.dirname handles.filesep 'Masks'];
    set(handles.filespath,'string',handles.dirname)
else
    handles.maindir=handles.dirname(1:end-5);
end

dirfiles=dir(handles.dirname);
dirfiles(1:2)=[]; ind=0;
for i=1:length(dirfiles)
    if ~isempty(strfind(dirfiles(i).name,'bmp'))
        ind=ind+1;
        handles.Masks(ind).Filenames=dirfiles(i).name;
        handles.Masks(ind).Fullfile=fullfile(handles.dirname, handles.Masks(ind).Filenames);
        handles.Masks(ind).Image=imread(handles.Masks(ind).Fullfile);
        handles.Masks(ind).WormNum=dirfiles(i).name((strfind(dirfiles(i).name,'_')+1):((strfind(dirfiles(i).name,'.')-1)));
        handles.Masks(ind).WormFlag=0;
        liststring{ind}=handles.Masks(i).Filenames;
        handles.Masks(ind).Size=size(handles.Masks(ind).Image);
    end
end

if ~exist('liststring','var')
    set(handles.current_worm,'string','No Worms Found!');
    return
end

handles.liststring=liststring;
handles.inds=1;
handles.wormflags=cell(length(liststring),1);
set(handles.masknames,'string',liststring);
handles.OrgCount=length(liststring);
WormCounts=sprintf('%d / %d',length(handles.Masks),handles.OrgCount);
set(handles.wormcount,'string',WormCounts);
axes(handles.maskimage)
imshow(handles.Masks(handles.currentmask).Image);

%Load Overlap file if present
if logical(exist([handles.maindir 'Overlap'],'dir'))
    handles.fluordir=[handles.maindir 'Overlap'];
    handles.imgtype=2;
    guidata(hObject, handles);
    overlap_Callback(hObject, eventdata, handles)
    handles=guidata(hObject);
    set(handles.current_worm,'string','Loading Overlapping Images...');
    pause(0.0001);
end

%Load Originals file if present
if logical(exist([handles.maindir 'Originals'],'dir'))
    handles.orgdir=[handles.maindir 'Originals'];
    handles.imgtype=1;
    guidata(hObject, handles);
    overlap_Callback(hObject, eventdata, handles)
    handles=guidata(hObject);
    set(handles.current_worm,'string','Loading Original Images...');
    pause(0.0001);
end

masknames_Callback(hObject, eventdata, handles)
set(handles.current_worm,'string','Loading Complete!');
set(handles.flag_count,'string','0')
pause(0.0001);
set(handles.img_type,'selectedobject',handles.original)
uicontrol(handles.masknames)
guidata(hObject, handles)

%% --- Executes on button press in wormnet.
function wormnet_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end
set(handles.current_worm,'string','Preparing Worms for WormNet...');
pause(0.00001)

%Prepare Images for WormNet
CurrentImages=[];
for i=1:length(handles.Masks)
    CurrentImages{i}=handles.Masks(i).Image;
end
WormNetImages=prepare4wormnet(CurrentImages);

%load WormNet
if ~isfield(handles,'WormNet')
    set(handles.current_worm,'string','Classifying Worms...');
    pause(0.00001)
    temp=load(['lib' handles.filesep 'WormNet.mat']);
    handles.WormNet=temp.WormNet;
    handles.NetOptions=temp.options;
end

%Predict
predY=double(classify(handles.WormNet,WormNetImages));

%Save Images and Prediction - for testing images preparations
% save('WormNetImages.mat','WormNetImages','predY') %%%%% SAVE %%%%

%Update Worm List
indx1=find(predY==2);
for i=1:length(handles.Masks)
    if ismember(i,indx1)
        handles.Masks(i).WormFlag=1;
        handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'yellow', handles.Masks(i).Filenames);
    else
        handles.Masks(i).WormFlag=0;
    end
end
set(handles.masknames,'string',handles.liststring);
temp=cat(1,handles.Masks);
set(handles.flag_count,'string',num2str(sum(cat(1,(temp.WormFlag)))));
set(handles.current_worm,'string','Worm Classification Complete!');
uicontrol(handles.masknames)
guidata(hObject, handles);


%% --- Executes on selection change in masknames. %%%%%%%%%%%%%%%%%%%%%%%%%
function masknames_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end

%Adjust for MultiSelect
ind=get(handles.masknames,'Value');
allinds=[ind handles.inds];
if length(ind)>1
    [u,i1] = unique(allinds); id=i1(histc(allinds,u) == 1); 
    handles.inds=ind;
    if isempty(id) || length(id)>1 %||  max(id)>length(ind) length(ind)<length(handles.inds)
        return
    end
    ind=allinds(id);
else
    handles.inds=ind;
end
if ind>length(handles.liststring)
    ind=1;
end
handles.currentmask=ind;

%Update Mask Image
axes(handles.maskimage)
img=(handles.Masks(ind).Image);
if strcmp(get(handles.real_size,'Checked'),'on')
    maxes=max(cat(1,handles.Masks.Size));
    nmax=maxes(1); mmax=maxes(2);
    img=padarray(img,[round(0.5*(nmax-size(img,1))) round(0.5*(mmax-size(img,2)))]);
end
imshow(img);
set(gca,'Visible','off');
clear img sizes

%Update SkCr Image
axes(handles.skelimg);
if isfield(handles.Masks, 'SkCr')
    imshow(handles.Masks(ind).SkCr)
    if isfield(handles.Masks(ind),'MidCurve') && isfield(handles.Masks(ind),'MidCurve')
    if ~isempty(handles.Masks(ind).MidCurve) && ~isempty(handles.Masks(ind).CurveX1_Edge1)
        hold on
        c1=handles.Masks(ind).C1;
        c2=handles.Masks(ind).C2;
        if length(c1)~=3 || length(c2)~=3
            c1=[1 1 1];
            c2=[1 1 1];
        end
        plot([handles.Masks(ind).MidCurve(1,1) handles.Masks(ind).MidCurve(2,1)], [handles.Masks(ind).MidCurve(1,2) handles.Masks(ind).MidCurve(2,2)],'Color',[0,0.7,0.9],'linewidth',2)
        plot([handles.Masks(ind).CurveX1_Edge1(1,1) handles.Masks(ind).CurveX1_Edge1(2,1)], [handles.Masks(ind).CurveX1_Edge1(1,2) handles.Masks(ind).CurveX1_Edge1(2,2)],'Color',c1,'linewidth',2)
        plot([handles.Masks(ind).CurveX2_Edge1(1,1) handles.Masks(ind).CurveX2_Edge1(2,1)], [handles.Masks(ind).CurveX2_Edge1(1,2) handles.Masks(ind).CurveX2_Edge1(2,2)],'Color',c1,'linewidth',2)
        plot([handles.Masks(ind).CurveX1_Edge2(1,1) handles.Masks(ind).CurveX1_Edge2(2,1)], [handles.Masks(ind).CurveX1_Edge2(1,2) handles.Masks(ind).CurveX1_Edge2(2,2)],'Color',c2,'linewidth',2)
        plot([handles.Masks(ind).CurveX2_Edge2(1,1) handles.Masks(ind).CurveX2_Edge2(2,1)], [handles.Masks(ind).CurveX2_Edge2(1,2) handles.Masks(ind).CurveX2_Edge2(2,2)],'Color',c2,'linewidth',2)
        hold off
    end
    end
else 
    cla
end
set(gca,'Visible','off');

%Update Morphology Data
if isfield(handles.Masks, 'Area')
    set(handles.area,'string',handles.Masks(ind).Area)
    set(handles.length,'string',handles.Masks(ind).Length)
    set(handles.thick,'string',handles.Masks(ind).Thick)
    set(handles.midwidth,'string',handles.Masks(ind).MidWidth)
    set(handles.headr,'string',handles.Masks(ind).Head)
    set(handles.tailr,'string',handles.Masks(ind).Tail)
    set(handles.headbf,'string',handles.Masks(ind).HeadBF);
    set(handles.tailbf,'string',handles.Masks(ind).TailBF);
end

%Update Overlapping Image
if isfield(handles, 'imgtype')
    axes(handles.fluorimg)
    switch handles.imgtype
        case 1
            if isfield(handles.Masks, 'OrgImg')
            imshow(handles.Masks(ind).OrgImg);
            end
        case 2
            if isfield(handles.Masks, 'FluorImg')
            imshow(handles.Masks(ind).FluorImg);
                if isfield(handles.Masks, 'Peaks') && handles.Masks(ind).NPeaks>0
                    if handles.fluortype==2
                    hold on
                    scatter(handles.Masks(ind).Peaks(:,1),handles.Masks(ind).Peaks(:,2),(handles.Masks(ind).PeakAreas/max(handles.Masks(ind).PeakAreas))*80,'MarkerEdgeColor',[1 0.2 0.2]);
    %                 scatter(handles.Masks(ind).Background(:,1),handles.Masks(ind).Background(:,2),10,'x','MarkerEdgeColor',[1 0.3 0.2]);
                    hold off
                    elseif handles.fluortype==3
                        img=handles.Masks(ind).LabeledImage;
                        RGB=RGBfromLabels(img);
                        imshowpair(RGB,handles.Masks(ind).FluorImg,'blend');
                    end
                end
            end
        case 3
            if isfield(handles.Masks, 'OtherImg')
            imshow(handles.Masks(ind).OtherImg);
            end
    end
end
set(gca,'Visible','off');

%Update Fluorescent Data
if isfield(handles.Masks, 'Peaks')
    set(handles.num_peaks,'string',handles.Masks(ind).NPeaks)
    set(handles.mean_peaks,'string',handles.Masks(ind).MeanPeaks)
    set(handles.std_peaks,'string',handles.Masks(ind).STDPeaks)
    set(handles.ctwf,'string',handles.Masks(ind).CTWF)
    set(handles.rid,'string',handles.Masks(ind).RID)
    set(handles.actual_thresh,'string',handles.Masks(ind).flour_thr);
end

%Update Labels
if isfield(handles.Masks,'Label')
    set(handles.labeled,'string',handles.Masks(ind).Label)
end

%Update Flag
if isfield(handles.Masks,'WormFlag')
    set(handles.flag,'Value',handles.Masks(ind).WormFlag)
    for i=1:length(handles.liststring)
        Flags(i)=handles.Masks(i).WormFlag;
    end
    set(handles.flag_count,'string',num2str(sum(Flags)));
end
guidata(hObject, handles)


%% --- Executes on button press in removeworm. %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removeworm_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end
handles.datasaved=0;
inds=get(handles.masknames,'Value');
for ind=inds(end:-1:1)
    %Log removed worm
    handles.rmvcount=handles.rmvcount+1;
    handles.rmvnames{handles.rmvcount}=handles.Masks(ind).Filenames;
    %Clear worm data
    handles.Masks(ind)=[];
    handles.liststring(ind)=[];
end

%Handle first and last index
if max(inds)>1 && max(inds)<length(handles.liststring)
    set(handles.masknames,'Value',min(inds));
    handles.currentmask=min(inds);
elseif max(inds)==1
    set(handles.masknames,'Value',1);
    handles.currentmask=1;
elseif max(inds)>=length(handles.liststring)
    set(handles.masknames,'Value',min(inds)-1);
    handles.currentmask=min(inds)-1;
end
%Refresh Screen
set(handles.masknames,'string',handles.liststring);
WormCounts=sprintf('%d / %d',length(handles.liststring),handles.OrgCount);
set(handles.wormcount,'string',WormCounts);
masknames_Callback(hObject, eventdata, handles)
%Recount Labels
if isfield(handles.Masks,'Label')
    guidata(hObject, handles);
    count_labels(hObject, eventdata, handles)
end
uicontrol(handles.masknames)
guidata(hObject, handles);

% --- Executes on button press in remove_all.
function remove_all_Callback(hObject, eventdata, handles)
for i=length(handles.Masks):-1:1
    if handles.Masks(i).WormFlag
        set(handles.masknames,'Value',i)
        handles=guidata(hObject);
        removeworm_Callback(hObject, eventdata, handles)
    end
end


%% ANALYSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --- Executes on button press in analyse. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function analyse_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end

TailColor=[0.64, 0.08, 0.18];
HeadColor=[0 0 1];
handles.datasaved=0;
pheight=str2double(get(handles.pheight,'String'));
pwidth=str2double(get(handles.pwidth,'String'));
Areas=NaN(1,length(handles.liststring));
Lengths=NaN(1,length(handles.liststring));
BPs=NaN(1,length(handles.liststring));
Ps=NaN(1,length(handles.liststring));

for i=1:length(handles.liststring)
    set(handles.current_worm,'string',['Analysing... ' handles.Masks(i).Filenames, '  !! Please Wait !!'])
    pause(0.0001)
    
    try
        %Skeletonize
        BW=handles.Masks(i).Image;
        Skel=bwmorph(BW,'thin', Inf);
        B=bwmorph(Skel, 'branchpoints');
        handles.Masks(i).BP=sum(sum(B));
        iter=1;
        %Smooth maximum 5 times or until a skeleton line is obtained with no branchpoints.
        while sum(sum(B))>0 && iter<=5
            BW=medfilt2(BW,[15 15]);
            Skel=bwmorph(BW,'thin', Inf);
            B=bwmorph(Skel, 'branchpoints');
            iter=iter+1;
        end
        handles.Masks(i).Iter=iter;
        
        %Morphological data
        handles.Masks(i).Skel=Skel;
        handles.Masks(i).IndexedSkel=IndexSkel(Skel);
        handles.Masks(i).Curve=edge(BW,'Sobel'); %use either 'Sobel', 'Roberts', 'Prewitt'
        handles.Masks(i).SkCr=handles.Masks(i).Skel+handles.Masks(i).Curve;
        handles.Masks(i).Area=bwarea(BW)*pheight*pwidth;
        handles.Masks(i).Length=bwarea(Skel)*pheight;
        handles.Masks(i).Thick=handles.Masks(i).Area/handles.Masks(i).Length; 
        
        SkelValues=handles.Masks(i).IndexedSkel;
        [k, j]=find(handles.Masks(i).Curve);
        CurveValues=[k,j];
        neighbors=20;
        warning('off','curvefit:fit:equationBadlyConditioned');
        
        %Calculate MidWidth
        [CurveCoords, Pixels]=cross_section(floor(length(SkelValues)/2), BW, SkelValues, neighbors);
        handles.Masks(i).MidWidth=sqrt(sum(bsxfun(@minus, CurveCoords(1,:), CurveCoords(2,:)).^2,2))*pheight;
        handles.Masks(i).MidCurve=round(CurveCoords);

        %Calculate head Ratio
        [R1, Coords]=get_R1(BW, SkelValues, pheight);
        handles.Masks(i).CurveX1_Edge1=Coords{1};
        handles.Masks(i).CurveX2_Edge1=Coords{2};
        handles.Masks(i).R1=R1;

        %Calculate tail Ratio
        [R2, Coords]=get_R2(BW, SkelValues, pheight);
        handles.Masks(i).CurveX1_Edge2=Coords{1};
        handles.Masks(i).CurveX2_Edge2=Coords{2};
        handles.Masks(i).R2=R2;
        
        %Calculate Edges Brightness & Masks
        edgeMask1=edge_polygon(BW,SkelValues,0.13);
        edgeMask2=edge_polygon(BW,SkelValues,0.87);
        MeanBF1=mean2(handles.Masks(i).OrgImg(edgeMask1));
        MeanBF2=mean2(handles.Masks(i).OrgImg(edgeMask2));
        EdgeMask1=get_EdgeMask(BW,SkelValues,0.1);
        EdgeMask2=get_EdgeMask(BW,SkelValues,0.9);

        
        %Calculate Body Brightness
        SkelDist1=0.13;
        SkelDist2=0.38;
        PolyMask1=body_polygon(BW,SkelValues,SkelDist1,SkelDist2);
        MeanBody1=mean2(handles.Masks(i).OrgImg(PolyMask1));

        SkelDist1=0.38;
        SkelDist2=0.62;
        PolyMask2=body_polygon(BW,SkelValues,SkelDist1,SkelDist2);
        MeanBody2=mean2(handles.Masks(i).OrgImg(PolyMask2));

        SkelDist1=0.62;
        SkelDist2=0.87;
        PolyMask3=body_polygon(BW,SkelValues,SkelDist1,SkelDist2);
        MeanBody3=mean2(handles.Masks(i).OrgImg(PolyMask3));

        %Set Head/Tail and Body BrightField Mean Intesities by Mean
        %Brightness in edges
        if MeanBF1>=MeanBF2
           handles.Masks(i).Head=handles.Masks(i).R1;
           handles.Masks(i).Tail=handles.Masks(i).R2;
           handles.Masks(i).HeadBF=MeanBF1;
           handles.Masks(i).TailBF=MeanBF2;
           handles.Masks(i).C1=HeadColor;
           handles.Masks(i).C2=TailColor;
           handles.Masks(i).AnteriorBodyBF=MeanBody1;
           handles.Masks(i).MidBodyBF=MeanBody2;
           handles.Masks(i).PosteriorBodyBF=MeanBody3;
           handles.Masks(i).NoHeadMask=~EdgeMask1 & logical(handles.Masks(i).Image);
           handles.Masks(i).HeadMask=EdgeMask1;
           handles.Masks(i).TailMask=EdgeMask2;
        else
           handles.Masks(i).Head=handles.Masks(i).R2;
           handles.Masks(i).Tail=handles.Masks(i).R1;
           handles.Masks(i).HeadBF=MeanBF2;
           handles.Masks(i).TailBF=MeanBF1;
           handles.Masks(i).C1=TailColor;
           handles.Masks(i).C2=HeadColor;
           handles.Masks(i).AnteriorBodyBF=MeanBody3;
           handles.Masks(i).MidBodyBF=MeanBody2;
           handles.Masks(i).PosteriorBodyBF=MeanBody1;
           handles.Masks(i).NoHeadMask=~EdgeMask2 & logical(handles.Masks(i).Image);
           handles.Masks(i).HeadMask=EdgeMask2;
           handles.Masks(i).TailMask=EdgeMask1;
        end 
                 
        handles.Masks(i).WormFlag=0;
        
    catch ME
        handles.Masks(i).WormFlag=1;
        handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'red', handles.Masks(i).Filenames);
        handles.Masks(i).MidWidth=NaN;
        handles.Masks(i).Head=NaN;
        handles.Masks(i).Tail=NaN;
        handles.Masks(i).Area=NaN;
        handles.Masks(i).Length=NaN;
        handles.Masks(i).Thick=NaN;
        handles.Masks(i).HeadBF=NaN;
        handles.Masks(i).TailBF=NaN;
        handles.Masks(i).AnteriorBodyBF=NaN;
        handles.Masks(i).MidBodyBF=NaN;
        handles.Masks(i).PosteriorBodyBF=NaN;
        handles.Masks(i).C1=[1 1 1];
        handles.Masks(i).C2=[1 1 1];
                    
        fileID = fopen('errorlog.txt','a+');
        fprintf(fileID,'\n\n****** Error in: %s \n\n',handles.Masks(i).Filenames)
        fprintf(fileID, '%s', ME.getReport('extended', 'hyperlinks','off'))
        fclose(fileID);
    end
end


%Correct Head\Tail using headr and tailr Sizes
AllHeadsBF=cat(1,handles.Masks.HeadBF);
AllTailsBF=cat(1,handles.Masks.TailBF);
ind2change=find(AllTailsBF>nanmean(AllHeadsBF));
for k=1:length(ind2change)
    i=ind2change(k);
    %Determine Head/Tail By headr and tailr sizes
    [Head, Tail]=HTbyR1R2(handles.Masks(i).R1, handles.Masks(i).R2);
    if Head ~= handles.Masks(i).Head
        NewHeadBF=handles.Masks(i).TailBF;
        NewTailBF=handles.Masks(i).HeadBF;
        handles.Masks(i).HeadBF=NewHeadBF;
        handles.Masks(i).TailBF=NewTailBF;
        handles.Masks(i).Head=Head;
        handles.Masks(i).Tail=Tail;
    end
end

%Find Outliers
guidata(hObject, handles);
handles=find_outliers(hObject, eventdata, handles);

%Update axes and data
uicontrol(handles.masknames)
guidata(hObject, handles);
masknames_Callback(hObject, eventdata, handles)
set(handles.current_worm,'string','Analysis Complete!');

%Update save checkboxed
set(handles.check_area,'Value',1);
set(handles.check_length,'Value',1);
set(handles.check_thick,'Value',1);
set(handles.check_mid,'Value',1);
set(handles.check_headtail,'Value',1);
set(handles.check_bodybf,'Value',1);

%Perform flouresence analysis if available
if isfield(handles.Masks,'FluorImg')
    guidata(hObject, handles);
    analyse_ovrlp_Callback(hObject, eventdata, handles)
    handles=guidata(hObject);
end
guidata(hObject, handles);


% --- Find outliers using Area, Length, Branchpoints and smoothing Iterations.
function handles=find_outliers(hObject, eventdata, handles)
for i=1:length(handles.liststring)
    Areas(i)=handles.Masks(i).Area;
    Lengths(i)=handles.Masks(i).Length;
    BPs(i)=handles.Masks(i).BP;
    Iters(i)=handles.Masks(i).Iter;
end

ZAreas=zscore(Areas);
indx1=find([(ZAreas>1.5) + (ZAreas<-1.5)]);
for i=indx1
    handles.Masks(i).WormFlag=1;
    handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'yellow', handles.Masks(i).Filenames);
end
ZLengths=zscore(Lengths);
indx2=find([(ZLengths>1.5) + (ZLengths<-1.5)]);
for i=indx2
    handles.Masks(i).WormFlag=1;
    handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'yellow', handles.Masks(i).Filenames);
end
indx3=find(Iters>2);
for i=indx3
    handles.Masks(i).WormFlag=1;
    handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'yellow', handles.Masks(i).Filenames);
end
indx4=find(BPs>2);
for i=indx4
    handles.Masks(i).WormFlag=1;
    handles.liststring{i}=sprintf('<HTML><BODY bgcolor="%s">%s', 'yellow', handles.Masks(i).Filenames);
end
set(handles.masknames,'string',handles.liststring);
temp=cat(1,handles.Masks);
set(handles.flag_count,'string',sum(cat(1,(temp.WormFlag))));
guidata(hObject, handles);

% --- Executes on button press in next_flag.
function next_flag_Callback(hObject, eventdata, handles)
%Check for Generated
if ~isfield(handles,'Masks')
    set(handles.current_worm,'string','No Worms Generated!');
    return
else
    %Check for Flagged
    if str2double(get(handles.flag_count,'string'))==0
        set(handles.current_worm,'string','No Worms Flagged!');
        return
    end
end

ind=max(get(handles.masknames,'Value'));
for i=1:length(handles.liststring)
    Flags(i)=handles.Masks(i).WormFlag;
end
flagind=find(Flags);
if isempty(flagind)
    return
end
k=find((flagind-ind)>0,1);
if isempty(k)
    next=flagind(1);
else
    next=flagind(k);
end
set(handles.masknames,'Value',next);
masknames_Callback(hObject, eventdata, handles)
uicontrol(handles.masknames)
guidata(hObject, handles);

% --- Executes on button press in flag.
function flag_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end
inds=get(handles.masknames,'Value');
for ind=inds
handles.Masks(ind).WormFlag=(~handles.Masks(ind).WormFlag);
if handles.Masks(ind).WormFlag
    handles.liststring{ind}=sprintf('<HTML><BODY bgcolor="%s">%s', 'yellow', handles.Masks(ind).Filenames);
else
    handles.liststring{ind}=handles.Masks(ind).Filenames;
end
end
temp=cat(1,handles.Masks);
set(handles.flag_count,'string',sum(cat(1,(temp.WormFlag))));
set(handles.masknames,'string',handles.liststring);
uicontrol(handles.masknames)
guidata(hObject, handles);


function area_Callback(hObject, eventdata, handles)

function area_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function length_Callback(hObject, eventdata, handles)

function length_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function thick_Callback(hObject, eventdata, handles)

function thick_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R1_Callback(hObject, eventdata, handles)

function headr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R2_Callback(hObject, eventdata, handles)

function tailr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pheight_Callback(hObject, eventdata, handles)
pheight=str2double(get(hObject,'string'));
   if isnan(pheight)
      set(handles.pheight,'String','1.14');
   end 
guidata(hObject, handles);

function pheight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pwidth_Callback(hObject, eventdata, handles)
pwidth=str2double(get(hObject,'String'));
   if isnan(pwidth)
      set(handles.pwidth,'String','1.14');
   end 
guidata(hObject, handles);

function pwidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function current_worm_CreateFcn(hObject, eventdata, handles)


%% Overlapping Images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes when selected object is changed in img_type.
function img_type_SelectionChangedFcn(hObject, eventdata, handles)
axes(handles.fluorimg);
imgtype=strtrim(get(eventdata.NewValue,'Tag'));
switch imgtype 
    case 'original'
        handles.imgtype=1;
    case 'fluor'
        handles.imgtype=2;
    case 'other'
        handles.imgtype=3;
end
guidata(hObject);
masknames_Callback(hObject, eventdata, handles)
uicontrol(handles.masknames)
guidata(hObject, handles);


%% --- Executes on button press in overlap. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function overlap_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end

if ~isfield(handles, 'imgtype')
    handles.imgtype=1;
end

%Locate Directory
switch handles.imgtype
    case 1
        if ~isfield(handles,'orgdir')
        dirname=uigetdir(handles.dirname,'Browse for Original Images');
        handles.orgdir=dirname;
        else
          dirname=handles.orgdir;
        end
    case 2
        if ~isfield(handles,'fluordir')
        dirname=uigetdir(handles.dirname,'Browse for Fluorescent Images');
        handles.fluordir=dirname;
        else
          dirname=handles.fluordir;
        end
    case 3
    dirname=uigetdir(handles.dirname,'Browse for Overlapping Images of Any Type');
    handles.otherdir=dirname;
end

%Check valid dirname
if strcmp(num2str(dirname),'0')
    return
end

%Gather files names in folder
dirfiles=dir(dirname);
for i=1:length(dirfiles)
    allfiles{i}=dirfiles(i).name;
end

%Load Images for each loaded mask file
for i=1:length(handles.Masks)
    ovpfile=handles.Masks(i).Filenames;
    ovpfile(1:4)=allfiles{end}(1:4);
    Fullfile=fullfile(dirname,ovpfile);
    if ismember(ovpfile,allfiles)
        switch handles.imgtype
            case 1
            handles.Masks(i).OrgImg=mat2gray(imread(Fullfile));
            case 2
            handles.Masks(i).FluorImg_noGS=imread(Fullfile);
            handles.Masks(i).FluorImg=mat2gray(handles.Masks(i).FluorImg_noGS);
            case 3
            handles.Masks(i).OtherImg=imread(Fullfile);   
        end
    else
       switch handles.imgtype
            case 1
            handles.Masks(i).OrgImg=zeros(size(handles.Masks(i).Image));
            case 2
            handles.Masks(i).FluorImg_noGS=zeros(size(handles.Masks(i).Image));
            handles.Masks(i).FluorImg=zeros(size(handles.Masks(i).Image));
            case 3
            handles.Masks(i).OtherImg=zeros(size(handles.Masks(i).Image));  
        end
    end
end

%Update Axes
axes(handles.fluorimg);
switch handles.imgtype
        case 1
        imshow(handles.Masks(handles.currentmask).OrgImg);
        case 2
        imshow(handles.Masks(handles.currentmask).FluorImg);    
        case 3
        imshow(handles.Masks(handles.currentmask).OtherImg);   
end
guidata(hObject, handles);


function neighborhood_Callback(hObject, eventdata, handles)
n=str2double(get(handles.neighborhood,'String'));
if mod(n,2)==0
    n=n+1;
    set(handles.neighborhood,'String',num2str(n));
end

function neighborhood_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function threshold_Callback(hObject, eventdata, handles)

function threshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exclude_head_Callback(hObject, eventdata, handles)


%% --- Executes on button press in analyse_ovrlp. %%%%%%%%%%%%%%%%%%%%%%%%%
function analyse_ovrlp_Callback(hObject, eventdata, handles)
%Check for Generated
if ~isfield(handles,'Masks')
    set(handles.current_worm,'string','No Worms Generated!');
    return
else
    %Check for Overlap
    if ~isfield(handles.Masks(1),'FluorImg_noGS')
        set(handles.current_worm,'string','No Flourescent Images!');
        return
    end
end

%Initialize
worms=length(handles.Masks);
BGpoints=1000;
thr_precent=str2double(get(handles.threshold,'String'))/100;
n=str2double(get(handles.neighborhood,'String'));
set(handles.current_worm,'string','Analysing Fluorescence...')
pause(0.0001)

%Calculate flouresent data
if isfield(handles.Masks,'FluorImg')
    for i=1:worms
        try
            if get(handles.exclude_head,'value') && isfield(handles.Masks(i),'NoHeadMask')
                mask=handles.Masks(i).NoHeadMask;
            else
                mask=handles.Masks(i).Image;
            end
        fluorimg=zeros(size(handles.Masks(i).FluorImg_noGS));
        fluorimg(mask)=handles.Masks(i).FluorImg_noGS(mask);
        %Skip worm if floursence if zeros image
        if all(all(fluorimg==zeros(size(fluorimg)))) 
            error();
        end
        handles.Masks(i).flour_thr=thr_precent*max(fluorimg(mask));
        neigh=min([min(size(fluorimg))+~mod(min(size(fluorimg)),2) n]);
        handles.Masks(i).Peaks=fluorpeaks(fluorimg,handles.Masks(i).flour_thr,neigh);
        handles.Masks(i).NPeaks=size(handles.Masks(i).Peaks,1);
        [background(:,2),background(:,1)]=find(~handles.Masks(i).Image);
        handles.Masks(i).Background=background(randi(length(background),1,BGpoints),:);
        for k=1:BGpoints
            BGIntensity(k)=handles.Masks(i).FluorImg_noGS(handles.Masks(i).Background(k,2),handles.Masks(i).Background(k,1));
        end
        handles.Masks(i).MeanBG=mean(BGIntensity);
        handles.Masks(i).RID=sum(sum(fluorimg))-sum(sum(mask))*mean(BGIntensity);
        handles.Masks(i).CTWF=mean2(fluorimg(mask))*bwarea(mask)-bwarea(mask)*mean(BGIntensity);
        if isfield(handles.Masks(i),'HeadMask')
            hmask=handles.Masks(i).HeadMask;
            tmask=handles.Masks(i).TailMask;
            handles.Masks(i).Head_CTWF=mean2(fluorimg(hmask))*bwarea(hmask)-bwarea(hmask)*mean(BGIntensity);
            handles.Masks(i).Tail_CTWF=mean2(fluorimg(tmask))*bwarea(tmask)-bwarea(tmask)*mean(BGIntensity);
        end
        clear background k
        if handles.Masks(i).NPeaks>0
            for k=1:handles.Masks(i).NPeaks
                Intensity(k)=double(handles.Masks(i).FluorImg_noGS(handles.Masks(i).Peaks(k,2),handles.Masks(i).Peaks(k,1)));
            end
            handles.Masks(i).MeanPeaks=mean(Intensity-mean(BGIntensity));
            handles.Masks(i).STDPeaks=std(Intensity);
        else
            handles.Masks(i).MeanPeaks=NaN;
            handles.Masks(i).STDPeaks=NaN;
        end
        %Get Peak Sizes and Labeled Image
        [PeakAreas, FinalImg, NewPeaks]=find_peakSizes(fluorimg,handles.Masks(i).Peaks);
        handles.Masks(i).Peaks=NewPeaks;
        handles.Masks(i).LabeledImage=FinalImg;
        handles.Masks(i).PeakAreas=PeakAreas;
        catch ME
            disp(['Worm Failed Fluorescent Analysis: ' handles.Masks(i).Filenames])
            handles.Masks(i).MeanPeaks=NaN;
            handles.Masks(i).STDPeaks=NaN;
            handles.Masks(i).CTWF=NaN;
            handles.Masks(i).NPeaks=NaN;
            handles.Masks(i).Peaks=NaN;
            handles.Masks(i).PeakAreas=NaN;
            handles.Masks(i).RID=NaN;
            handles.Masks(i).Head_CTWF=NaN;
            handles.Masks(i).Tail_CTWF=NaN;
            handles.Masks(i).LabeledImage=zeros(size(handles.Masks(i).FluorImg_noGS));
 
            fileID = fopen('errorlog.txt','a+');
            fprintf(fileID,'\n\n****** Error in: %s \n\n',handles.Masks(i).Filenames)
            fprintf(fileID, '%s', ME.getReport('extended', 'hyperlinks','off'))
            fclose(fileID);
        end
    end
    %Update checkbox and status
    set(handles.check_peaks,'Value',1);
    set(handles.check_ctwf,'Value',1);
    set(handles.check_rid,'Value',1);
    set(handles.check_ht_ctfw,'Value',1);
    set(handles.current_worm,'string','Analysis Complete!');
    handles.imgtype=2;
else
    set(handles.current_worm,'string','No Flour Images.');
end
set(handles.img_type,'selectedobject',handles.fluor)
guidata(hObject, handles);
masknames_Callback(hObject, eventdata, handles)
uicontrol(handles.masknames)
guidata(hObject, handles);
masks=handles.Masks;

% % --- Executes on button press in color_peaks.
% function color_peaks_Callback(hObject, eventdata, handles)
% masknames_Callback(hObject, eventdata, handles)
% guidata(hObject, handles);


%% Labeling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Count labels
function count_labels(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end
Numlabeled=0;
for i=1:length(handles.Masks)
    if ~isempty(handles.Masks(i).Label)
        Numlabeled=Numlabeled+1;
    end
end
total=sprintf('%d/%d',Numlabeled,length(handles.liststring));
set(handles.tlabels,'string',total)
if ~get(handles.check_labels,'Value')
    set(handles.check_labels,'Value',1);
end
uicontrol(handles.masknames)
guidata(hObject, handles);

% --- Executes on button press in single_label.
function single_label_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end
inds=get(handles.masknames,'Value');
label=get(handles.label_value,'string');
for ind=inds
    if isstrprop(label, 'digit')
        label=str2double(label);
    end
    handles.Masks(ind).Label={label};
    set(handles.labeled,'string',label)
end
count_labels(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes on button press in all_label.
function all_label_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end
label=get(handles.label_value,'string');
if isstrprop(label, 'digit')
    label=str2double(label);
end
for i=1:length(handles.Masks)
    handles.Masks(i).Label={label};
end
set(handles.labeled,'string',handles.Masks(handles.currentmask).Label)
guidata(hObject, handles);
count_labels(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on button press in clear_label.
function clear_label_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end
inds=get(handles.masknames,'Value');
for ind=inds
    handles.Masks(ind).Label=[];
end
set(handles.labeled,'string','')
count_labels(hObject, eventdata, handles)
guidata(hObject, handles);

function label_value_Callback(hObject, eventdata, handles)
single_label_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

function label_value_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Save! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Save New CSV File %%%%
function csvsave_Callback(hObject, eventdata, handles)
%Check for Generated
if ~isfield(handles,'Masks')
    set(handles.current_worm,'string','No Worms Generated!');
    return
else
    %Check for Analyzed
    if ~isfield(handles.Masks(1),'Skel') && ~isfield(handles.Masks(1),'Peaks')
        set(handles.current_worm,'string','No Worms Analyzed!');
        return
    end
end

%Collect Data for Saving
maindir=handles.dirname(1:(strfind(handles.dirname,'Masks')-1));
[FileName,PathName]=uiputfile('WormData.csv','Choose Save Location',[maindir 'WormData.csv']);
if isempty(strfind(FileName,'.csv'))
    FileName=[FileName '.csv'];
end
if strcmp(num2str(PathName),'0')
    return
end
WormData=collect_data(hObject, eventdata, handles);
CSVArray=WormData.Features;
CSVArray(2:(size(WormData.X,1)+1),1:size(WormData.X,2))=num2cell(WormData.X);

%Add Labels
if isfield(handles.Masks, 'Label') && get(handles.check_labels,'Value')
    CSVArray(:,end+1)={'Labels'};
    if isnumeric(WormData.Y)
        CSVArray(2:(size(WormData.Y,1)+1),size(CSVArray,2))=num2cell(WormData.Y);
    else
        CSVArray(2:(size(WormData.Y,1)+1),size(CSVArray,2))=cellstr(WormData.Y);
    end
end

%Add Worm Names
CSVArray(:,2:(size(CSVArray,2)+1))=CSVArray; CSVArray(1,1)={'Worm_Names'};
CSVArray(2:end,1)=WormData.Names(1:end);

%Add PeakSizes as Seperate CSV File
%%% Need to add

fid = fopen([PathName FileName],'wt');
fprintf(fid,[repmat('%s,',1,size(CSVArray,2)) '\n'],CSVArray{1,:});   
for k=2:size(CSVArray,1)
    fprintf(fid,'%s,',CSVArray{k,1});
    fprintf(fid,[repmat('%d,',1,(size(CSVArray,2)-1)) '\n'],CSVArray{k,2:end});    
end
fclose(fid);
handles.datasaved=1;
set(handles.current_worm,'string','CSV File Exported!')
guidata(hObject, handles);

%%%%% Save New MAT File %%%%
function matsave_Callback(hObject, eventdata, handles)
%Check for Generated
if ~isfield(handles,'Masks')
    set(handles.current_worm,'string','No Worms Generated!');
    return
else
    %Check for Analyzed
    if ~isfield(handles.Masks(1),'Skel') && ~isfield(handles.Masks(1),'Peaks')
        set(handles.current_worm,'string','No Worms Analyzed!');
        return
    end
end

WormData=collect_data(hObject, eventdata, handles);
maindir=handles.dirname(1:(strfind(handles.dirname,'Masks')-1));
[FileName,PathName]=uiputfile('WormData.mat','Choose Save Location',[maindir 'WormData.mat']);
if strcmp(num2str(PathName),'0')
    return
end
save([PathName FileName],'WormData')
set(handles.current_worm,'string','Saved New WormData mat File!')
handles.datasaved=1;
guidata(hObject, handles);


%%%%% Add to Existing MAT File %%%%
function addmatsave_Callback(hObject, eventdata, handles)
%Check for Generated
if ~isfield(handles,'Masks')
    set(handles.current_worm,'string','No Worms Generated!');
    return
else
    %Check for Analyzed
    if ~isfield(handles.Masks(1),'Skel')
        set(handles.current_worm,'string','No Worms Analyzed!');
        return
    end
end

NewWormData=collect_data(hObject, eventdata, handles);
maindir=handles.dirname(1:(strfind(handles.dirname,'Masks')-1));
[filename, pathname]=uigetfile('*.mat', 'Load Existing Matrix',maindir);
if strcmp(num2str(pathname),'0')
    return
end
oldmat=load(fullfile(pathname,filename));
try
    WormData.X=[oldmat.WormData.X ; NewWormData.X];
catch
    set(handles.current_worm,'string','ERROR - Unequal number of features!')
end
if isfield(handles.Masks, 'Label') && get(handles.check_labels,'Value')
   WormData.Y=[oldmat.WormData.Y ; NewWormData.Y];
end
WormData.Features=NewWormData.Features;
WormData.Names=[oldmat.WormData.Names ; NewWormData.Names];
save([pathname filename],'WormData')
set(handles.current_worm,'string','Added to Existing WormData!')
handles.datasaved=1;
guidata(hObject, handles);


%%%%% Save New EXCEL File %%%%
function excelsave_Callback(hObject, eventdata, handles)
%Check for Generated
if ~isfield(handles,'Masks')
    set(handles.current_worm,'string','No Worms Generated!');
    return
else
    %Check for Analyzed
    if ~isfield(handles.Masks(1),'Skel') && ~isfield(handles.Masks(1),'Peaks')
        set(handles.current_worm,'string','No Worms Analyzed!');
        return
    end
end

%Turn off warning
warning('off','MATLAB:xlswrite:AddSheet');

%Collect Data for Saving
maindir=handles.dirname(1:(strfind(handles.dirname,'Masks')-1));
[FileName,PathName]=uiputfile('WormData.xlsx','Choose Save Location',[maindir 'WormData.xlsx']);
if isempty(strfind(FileName,'.xlsx'))
    FileName=[FileName '.xlsx'];
end
if strcmp(num2str(PathName),'0')
    return
end
WormData=collect_data(hObject, eventdata, handles);
ExcArray=WormData.Features;
ExcArray(2:(size(WormData.X,1)+1),1:size(WormData.X,2))=num2cell(WormData.X);

%Add Labels
if isfield(handles.Masks, 'Label') && get(handles.check_labels,'Value')
    ExcArray(:,end+1)={'Labels'};
    ExcArray(2:(size(WormData.Y,1)+1),size(ExcArray,2))=WormData.Y;
%     if isnumeric(WormData.Y)
%         ExcArray(2:(size(WormData.Y,1)+1),size(ExcArray,2))=num2cell(WormData.Y);
%     else
%         ExcArray(2:(size(WormData.Y,1)+1),size(ExcArray,2))=cellstr(WormData.Y);
%     end
end

%Add Worm Names
ExcArray(:,2:(size(ExcArray,2)+1))=ExcArray;
ExcArray(1,1)={'Worm_Names'};
ExcArray(2:end,1)=WormData.Names(1:end); %{1:end};

%Save
xlswrite([PathName FileName],ExcArray);

%Add PeakSizes as Seperate Sheet
if get(handles.check_peaks,'Value')
    %Add Worm Names
    WormData.PeakSizes(:,2:(size(WormData.PeakSizes,2)+1))=WormData.PeakSizes;
    WormData.PeakSizes(1:end,1)=WormData.Names(1:end);

    xlswrite([PathName FileName],WormData.PeakSizes,'PeakAreas');
end

%Rename first sheet
e = actxserver('Excel.Application'); % # open Activex server
ewb = e.Workbooks.Open([PathName FileName]); % # open file (enter full path!)
ewb.Worksheets.Item(1).Name = 'WormData'; % # rename 1st sheet
ewb.Save
%Set first Sheet as Active
Sheets = e.ActiveWorkBook.Sheets;
sheet1 = get(Sheets, 'Item', 1);
invoke(sheet1, 'Activate');
%Save and Close
ewb.Save % # save to the same file
ewb.Close(false)
e.Quit

handles.datasaved=1;
set(handles.current_worm,'string','Excel Spreadsheet Exported!')
guidata(hObject, handles);

%%%% --- Collect all checked data types.%%%%
function WormData=collect_data(hObject, eventdata, handles)
for i=1:length(handles.Masks)
    col=1;
    if get(handles.check_area,'Value')
        WormData.X(i,col)=handles.Masks(i).Area;
        WormData.Features{col}='Area';
        col=col+1;
    end
    if get(handles.check_length,'Value')
        WormData.X(i,col)=handles.Masks(i).Length;
        WormData.Features{col}='Length';
        col=col+1;
    end
    if get(handles.check_thick,'Value')
        WormData.X(i,col)=handles.Masks(i).Thick;
        WormData.Features{col}='Thickness';
        col=col+1;
    end
    if get(handles.check_mid,'Value')
        WormData.X(i,col)=handles.Masks(i).MidWidth;
        WormData.Features{col}='MidWidth';
        col=col+1;
    end
    if get(handles.check_headtail,'Value')
        WormData.X(i,col)=handles.Masks(i).Head;
        WormData.Features{col}='Head';
        col=col+1;
        WormData.X(i,col)=handles.Masks(i).Tail;
        WormData.Features{col}='Tail';
        col=col+1;
    end
    if get(handles.check_peaks,'Value')
        WormData.X(i,col)=handles.Masks(i).NPeaks;
        WormData.Features{col}='Number_of_Peaks';
        col=col+1;
        WormData.X(i,col)=handles.Masks(i).MeanPeaks;
        WormData.Features{col}='Mean_Peak_Intensity';
        col=col+1;
        WormData.X(i,col)=handles.Masks(i).STDPeaks;
        WormData.Features{col}='STD_Peak_Intensity';
        col=col+1;
    end
    if get(handles.check_ctwf,'Value')
        WormData.X(i,col)=handles.Masks(i).CTWF;
        WormData.Features{col}='CTWF';
        col=col+1;
    end
    if get(handles.check_ht_ctfw,'Value')
        WormData.X(i,col)=handles.Masks(i).Head_CTWF;
        WormData.Features{col}='Head_CTWF';
        col=col+1;
        WormData.X(i,col)=handles.Masks(i).Tail_CTWF;
        WormData.Features{col}='Tail_CTWF';
        col=col+1;
    end
    if get(handles.check_rid,'Value')
        WormData.X(i,col)=handles.Masks(i).RID;
        WormData.Features{col}='RawIntegratedDensity';
        col=col+1;
    end 
    if get(handles.check_bodybf,'Value')
        WormData.X(i,col)=handles.Masks(i).HeadBF;
        WormData.Features{col}='HeadBF';
        col=col+1;
        WormData.X(i,col)=handles.Masks(i).AnteriorBodyBF;
        WormData.Features{col}='AnteriorBodyBF';
        col=col+1;
        WormData.X(i,col)=handles.Masks(i).MidBodyBF;
        WormData.Features{col}='MidBodyBF';
        col=col+1;
        WormData.X(i,col)=handles.Masks(i).PosteriorBodyBF;
        WormData.Features{col}='PosteriorBodyBF';
        col=col+1;
        WormData.X(i,col)=handles.Masks(i).TailBF;
        WormData.Features{col}='TailBF';
        col=col+1;
    end
    if isfield(handles.Masks, 'Label') && get(handles.check_labels,'Value')
        if ~isempty(handles.Masks(i).Label)
            if ~iscell(handles.Masks(i).Label)
                handles.Masks(i).Label={handles.Masks(i).Label};
            end
            WormData.Y(i,1)=handles.Masks(i).Label;
        else
            WormData.Y(i,1)={NaN};
        end
    end
    WormData.Names(i,1)={handles.Masks(i).Filenames};
end

if isfield(WormData,'Y')
    if all(~iscell(WormData.Y))
        WormData.Y=num2cell(WormData.Y);
    end
end

%Add Peak Sizes
if get(handles.check_peaks,'Value')
    peaks_col=find(strcmp(WormData.Features,'Number_of_Peaks'));
    max_peaks=max(WormData.X(:,peaks_col));
    if ~isnan(max_peaks)
        WormData.PeakSizes=cell(size(WormData.X,1),max_peaks);
        for i=1:size(WormData.X,1)
           WormData.PeakSizes(i,1:length(handles.Masks(i).PeakAreas))=num2cell(handles.Masks(i).PeakAreas);
        end
    end
end

% --- Executes on button press in check_ht_ctfw.
function check_ht_ctfw_Callback(hObject, eventdata, handles)

%% --- Executes on button press in back.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function backtool_ClickedCallback(hObject, eventdata, handles)
if handles.datasaved
    close all
    WorMachine
else
    verify_exit
end


% --------------------------------------------------------------------
function nexttool_ClickedCallback(hObject, eventdata, handles)
if handles.datasaved
    close all
    LearnerGUI
else
    verify_exit
end


%% DISPLAY OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function display_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function real_size_Callback(hObject, eventdata, handles)
if strcmp(get(handles.real_size,'Checked'),'on')
    set(handles.real_size,'Checked','off')
else
    set(handles.real_size,'Checked','on')
end
masknames_Callback(hObject, eventdata, handles)

%% Retrain WormNet %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function wmnet_Callback(hObject,eventdata,handles)

function retrain_Callback(hObject, eventdata, handles)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end
set(handles.current_worm,'string','Preparing Worms for WormNet...');
pause(0.00001)

%Validate ReTraining
output = retrain_validate;
if strcmp(output,'No')
    set(handles.current_worm,'string','Retraining Aborted!');
    return
end

%Prepare Images for WormNet
CurrentImages=[];
for i=1:length(handles.Masks)
    CurrentImages{i}=handles.Masks(i).Image;
end
WormNetImages=prepare4wormnet(CurrentImages);

%load
if ~isfield(handles,'WormNet')
    set(handles.current_worm,'string','ReTraining WormNet...');
    pause(0.00001)
    temp=load(['lib' handles.filesep 'WormNet.mat']);
    handles.WormNet=temp.WormNet;
    handles.NetOptions=temp.options;
end

%Collect Labels
Y=zeros(size(WormNetImages,4),1);
for i=1:length(handles.Masks)
    if handles.Masks(i).WormFlag
        Y(i)=1;
    end
end

%Retrain Network
handles.WormNet = trainNetwork(WormNetImages,categorical(Y),handles.WormNet.Layers,handles.NetOptions);
set(handles.current_worm,'string','WormNet Trained with New Worms!');
guidata(hObject, handles);

%--------------------------------------------------------------------------
function save_wormnet_Callback(hObject, eventdata, handles)
temp=load(['lib' handles.filesep 'WormNet.mat']);
WormNet=handles.WormNet;
layers=temp.layers; imds=temp.imds; trainData=temp.trainData;
testData=temp.testData; options=temp.options;
save(['lib' handles.filesep 'WormNet.mat'],'WormNet','layers','imds','trainData','testData','options')
set(handles.current_worm,'string','New WormNet Saved!');


%% Help %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function about_Callback(hObject, eventdata, handles)
web('http://www.odedrechavilab.com/')

function manual_Callback(hObject, eventdata, handles)
open(['lib' handles.filesep 'WorMachine_Manual.pdf'])


%% Key Shortcuts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on key press with focus on masknames and none of its controls.
function masknames_KeyPressFcn(hObject, eventdata, handles)
switch eventdata.Key
  case 'r'
    removeworm_Callback(hObject, eventdata, handles)
  case 'f'
    flag_Callback(hObject, eventdata, handles)
  case 'd'
    next_flag_Callback(hObject, eventdata, handles)
  case 'l'
    single_label_Callback(hObject, eventdata, handles)
  case 'x'  
    clear_label_Callback(hObject, eventdata, handles)
  case 'backquote'
        switch handles.imgtype 
            case 1
                set(handles.fluor,'Value',1)
                handles.imgtype=2;
            case 2
                set(handles.original,'Value',1)
                handles.imgtype=1;
            case 'other'
        end
        guidata(hObject, handles);
        masknames_Callback(hObject, eventdata, handles)
        uicontrol(handles.masknames)
        guidata(hObject, handles);
  case 'semicolon'
        switch handles.imgtype 
            case 1
                set(handles.fluor,'Value',1)
                handles.imgtype=2;
            case 2
                set(handles.original,'Value',1)
                handles.imgtype=1;
            case 'other'
        end
        guidata(hObject, handles);
        masknames_Callback(hObject, eventdata, handles)
        uicontrol(handles.masknames)
        guidata(hObject, handles);
end

if contains('1234567890',eventdata.Key)
        num_shortkey(hObject, eventdata, handles, eventdata.Key)
end

function num_shortkey(hObject, eventdata, handles, key)
%Check for generated
if ~isfield(handles,'liststring')
    set(handles.current_worm,'string','No Worms Generated!');
    return
end
% ind=handles.currentmask;
inds=get(handles.masknames,'Value');
for ind=inds
    handles.Masks(ind).Label={str2double(key)};
end
set(handles.labeled,'string',key)
count_labels(hObject, eventdata, handles)
guidata(hObject, handles);

%% Do NOT Delete
% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)

% --------------------------------------------------------------------
function export_Callback(hObject, eventdata, handles)


% --- Executes when selected object is changed in fluortype.
function fluortype_SelectionChangedFcn(hObject, eventdata, handles)
axes(handles.fluorimg);
fluortype=strtrim(get(eventdata.NewValue,'Tag'));
switch fluortype 
    case 'clear_image_radio'
        handles.fluortype=1;
    case 'circle_peaks_radio'
        handles.fluortype=2;
    case 'color_peaks_radio'
        handles.fluortype=3;
end
guidata(hObject);
masknames_Callback(hObject, eventdata, handles)
uicontrol(handles.masknames)
guidata(hObject, handles);
