function varargout = LearnerGUI(varargin)
% LEARNERGUI MATLAB code for LearnerGUI.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LearnerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LearnerGUI_OutputFcn, ...
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

% --- Executes just before LearnerGUI is made visible.
function LearnerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.filesep=filesep;
clc;
addpath(genpath('lib'));
[PATHSTR,~,~]=fileparts((which(mfilename)));
cd(PATHSTR);
%Display Logo
logo=imread(['lib' handles.filesep 'WMlogo_Small.png']);
axes(handles.logo_axes); imshow(logo);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = LearnerGUI_OutputFcn(hObject, eventdata, handles) 
if isfield(handles,'output')
varargout{1} = handles.output;
end

%% Import WormData. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Import_Callback(hObject, eventdata, handles)

function imp_wormdata_Callback(hObject, eventdata, handles)
uicontrol(handles.included);
[filename, filepath]=uigetfile('*','Browse for WormData','MultiSelect','off');
if strcmp(num2str(filename),'0')
    return
end
handles.Filename=filename;
handles.Labeled=0;
handles.inpath=filepath;
loadedfile=load(fullfile(filepath, filename));
handles.WormData=loadedfile.WormData;
handles.Features=handles.WormData.Features;
[n, m]=size(handles.WormData.X);

%Update GUI
set(handles.included,'string',handles.Features);
set(handles.included,'value',1);
set(handles.excluded,'string',{});
set(handles.excluded,'value',1);
set(handles.samples,'string',n);
set(handles.features,'string',m);
if isfield(handles.WormData,'Y')
    if all(iscell(handles.WormData.Y))
   handles.WormData.Y=cell2mat(handles.WormData.Y);
    end
   handles.Labeled=1;
   classes=unique(handles.WormData.Y);
   printing=num2str(classes(1));
   for i=2:length(classes)
        printing=sprintf('%s, %s',printing,num2str(classes(i)));
   end
   set(handles.classes,'string',printing);
end
guidata(hObject, handles);

function load_Callback(hObject, eventdata, handles)


% --- Executes on button press in include.
function include_Callback(hObject, eventdata, handles)
uicontrol(handles.included);
exlist=get(handles.excluded,'string');
inlist=get(handles.included,'string');
if isempty(exlist)
    return
end
ind=get(handles.excluded,'Value');
set(handles.included,'string',[inlist; exlist(ind)]);
exlist(ind)=[];
if ind>length(exlist) && ind>1
    set(handles.excluded,'value',ind-1);
end
set(handles.excluded,'string',exlist);
guidata(hObject, handles);

% --- Executes on button press in exclude.
function exclude_Callback(hObject, eventdata, handles)
uicontrol(handles.included);
exlist=get(handles.excluded,'string');
inlist=get(handles.included,'string');
if isempty(inlist)
    return
end
ind=get(handles.included,'Value');
set(handles.excluded,'string',[exlist; inlist(ind)]);
inlist(ind)=[];
if ind>length(inlist) && ind>1
    set(handles.included,'value',ind-1);
end
set(handles.included,'string',inlist);
guidata(hObject, handles);

function standard_Callback(hObject, eventdata, handles)
uicontrol(handles.included);

function trim_Callback(hObject, eventdata, handles)
uicontrol(handles.included);

function excluded_Callback(hObject, eventdata, handles)

function excluded_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white'); end

function included_Callback(hObject, eventdata, handles)

function included_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white'); end

% --- Executes on button press in disp_feature.
function disp_feature_Callback(hObject, eventdata, handles)
uicontrol(handles.included);
axes(handles.general_fig); cla reset; axis on; 
ind=get(handles.included,'Value');
inlist=get(handles.included,'string');
Feature=inlist(ind);
col=find(strcmp(Feature,handles.Features));
x=handles.WormData.X(:,col);
OutInds=[];
if get(handles.trim,'Value')
    OutInds=trim_out(x);
    x(OutInds)=[];
end
if handles.Labeled
    Y=handles.WormData.Y;
    Y(OutInds)=[];
    violinplot(x,Y);
else
    histogram(x,20,'Normalization','probability');
end
xlabel(Feature);
guidata(hObject, handles);


%% CLASSIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in run_svm.
function run_svm_Callback(hObject, eventdata, handles)
if ~handles.Labeled
    return
end
X=handles.WormData.X;
Y=handles.WormData.Y;
% Collect Parameters
str=get(handles.kernelfunction,'String');
val=get(handles.kernelfunction,'Value');
switch strtrim(str{val})
    case 'Linear'
        handles.kernel='linear';
    case 'RBF (Gaussian)'
        handles.kernel='rbf';
    case 'Polynomial'
        handles.kernel='polynomial';
end
%Standardize
if get(handles.standard,'Value')
    X=scaledata(X);
end
folds=str2double(get(handles.cv,'String'));
%Exclude Features as Selected
exlist=get(handles.excluded,'string'); cols=[];
for i=1:length(exlist)
    Feature=exlist(i);
    cols(i)=find(strcmp(Feature,handles.Features));
end
X(:,cols)=[];
if isempty(X)
   return
end
% Train CV-SVM
CVSVMModel=fitcsvm(X,Y,'KernelFunction',handles.kernel,...
      'Standardize',0,'KernelScale','auto','BoxConstraint',0.5,'Crossval','on','KFold',folds);
classLoss=kfoldLoss(CVSVMModel);
set(handles.errrate,'string',sprintf('%1.2f %%',100*classLoss));
% Train Full SVM
handles.SVM_mdl=fitcsvm(X,Y,'KernelFunction',handles.kernel,'Standardize',0,...
    'KernelScale','auto','BoxConstraint',0.5);
C=predict(handles.SVM_mdl,X);
% Update Figure 
h=figure; 
targets=zeros(2,length(Y)); targets(1,:)=(Y==0); targets(2,:)=(Y==1); 
outputs=zeros(2,length(C)); outputs(1,:)=(C==0); outputs(2,:)=(C==1);
plotconfusion(targets,outputs);
cp1 = gcf; ax1 = findobj(cp1,'Type','Axes');
axes(handles.general_fig); cla reset; axis on;
copyobj(allchild(ax1),handles.general_fig);
close(h);
xticks([1,2]); yticks([1,2]); xlabel('Train Results');
xticklabels({'Label 1', 'Label 2'});
yticklabels({'Predicted 1', 'Predicted 2'});
ytickangle(90)
guidata(hObject, handles);


% --- Executes on button press in load_unlabeled.
function load_unlabeled_Callback(hObject, eventdata, handles)
[filename, filepath]=uigetfile([handles.inpath '*'],'Browse for WormData File','MultiSelect','off');
loadedfile=load(fullfile(filepath, filename));
handles.UnlabeledWormData=loadedfile.WormData;
handles.UnlabeledFilename=filename;
handles.Unlabeledinpath=filepath;
handles.Features2=handles.UnlabeledWormData.Features;
[n, m]=size(handles.UnlabeledWormData.X);
set(handles.samples2,'string',num2str(n))
set(handles.features2,'string',num2str(m))
guidata(hObject, handles);


% --- Executes on button press in classify.
function classify_Callback(hObject, eventdata, handles)
if ~handles.Labeled
    return
end
%Include Features as Selected
inlist=get(handles.included,'string'); cols=[];
for i=1:length(inlist)
    Feature=inlist(i);
    cols(i)=find(strcmp(Feature,handles.Features2));
end
cols=sort(cols);
X=handles.UnlabeledWormData.X(:,cols);
if isempty(X)
   return
end
if get(handles.standard,'Value')
    X=scaledata(X);
end
C=predict(handles.SVM_mdl,X);

%Test Results if New Data is Labeled
if isfield(handles.UnlabeledWormData,'Y')
    axes(handles.general_fig); cla reset; axis on;
    Y=handles.UnlabeledWormData.Y;
    errors=sum(Y~=C);
    set(handles.error_new,'string',errors);
    %Update Figure
    h=figure;
    targets=zeros(2,length(Y)); targets(1,:)=(Y==0); targets(2,:)=(Y==1); 
    outputs=zeros(2,length(C)); outputs(1,:)=(C==0); outputs(2,:)=(C==1);
    plotconfusion(targets,outputs);
    cp1 = gcf; ax1 = findobj(cp1,'Type','Axes');
    copyobj(allchild(ax1),handles.general_fig);
    close(h);
    xticks([1,2]); yticks([1,2]); xlabel('Classification Results');
    xticklabels({'Label 1', 'Label 2'});
    yticklabels({'Predicted 1', 'Predicted 2'});
    ytickangle(90)
end

set(handles.ones,'string',sum(C));
set(handles.zeros,'string',sum(~C));
handles.UnlabeledWormData.NewLabels=C;
guidata(hObject, handles);


function kernelfunction_Callback(hObject, eventdata, handles)

function kernelfunction_CreateFcn(hObject, eventdata, handles)

function cv_Callback(hObject, eventdata, handles)

function cv_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in tsne.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tsne_Callback(hObject, eventdata, handles)
axes(handles.general_fig); cla reset;
if isfield(handles.WormData,'TSNE')
    handles.WormData=rmfield(handles.WormData,'TSNE');
end
X=handles.WormData.X;
%Exclude Features as Selected
exlist=get(handles.excluded,'string'); cols=[];
for i=1:length(exlist)
    Feature=exlist(i);
    cols(i)=find(strcmp(Feature,handles.Features));
end
X(:,cols)=[];
if isempty(X)
   return
end
%Standardize
if get(handles.standard,'Value')
    X=scaledata(X);
end
%Determine Y
if ~isfield(handles.WormData,'Y')
    Y=ones(size(X,1),1);
else
    Y=handles.WormData.Y;
end
PCA_dims=min([str2double(get(handles.pca_dims,'string')),size(X,2)]);
TSNE_dims=min([str2double(get(handles.tsne_dims,'string')),size(X,2)]);
Perplexity=str2double(get(handles.perplexity,'string'));
handles.WormData.TSNE=tsne(X,Y, TSNE_dims, PCA_dims, Perplexity);
WormData=handles.WormData;
save(fullfile(handles.inpath,handles.Filename), 'WormData');
guidata(hObject, handles);

%% %%%%  --- Executes on button press in run_pca.
function run_pca_Callback(hObject, eventdata, handles)
axes(handles.general_fig); cla reset;
if isfield(handles.WormData,'PCA')
    handles.WormData=rmfield(handles.WormData,'PCA');
end
X=handles.WormData.X;
%Exclude Features as Selected
exlist=get(handles.excluded,'string'); cols=[];
for i=1:length(exlist)
    Feature=exlist(i);
    cols(i)=find(strcmp(Feature,handles.Features));
end
X(:,cols)=[];
if isempty(X)
   return
end
%Standardize
if get(handles.standard,'Value')
    X=scaledata(X);
end
%Determine Y
if ~isfield(handles.WormData,'Y')
    Y=ones(size(X,1),1);
else
    Y=handles.WormData.Y;
end
PCA_dims=min([str2double(get(handles.pca_dims,'string')),size(X,2)]);
[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED, MU] = pca(X);
scatter(SCORE(:,1),SCORE(:,2),[],Y,'filled');
xlabel('Comp. 1'); ylabel('Comp. 2');
handles.WormData.PCA.COEFF=COEFF;
handles.WormData.PCA.SCORE=SCORE;
handles.WormData.PCA.LATENT=LATENT;
handles.WormData.PCA.TSQUARED=TSQUARED;
handles.WormData.PCA.EXPLAINED=EXPLAINED;
WormData=handles.WormData;
save(fullfile(handles.inpath,handles.Filename), 'WormData');


function tsne_dims_Callback(hObject, eventdata, handles)

function tsne_dims_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pca_dims_Callback(hObject, eventdata, handles)

function pca_dims_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function perplexity_Callback(hObject, eventdata, handles)

function perplexity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Clustering %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cluster_Callback(hObject, eventdata, handles)
axes(handles.general_fig); cla reset; axis on;
if isfield(handles.WormData,'Cluster')
    handles.WormData=rmfield(handles.WormData,'Cluster');
end
X=handles.WormData.X;
%Exclude Features as Selected
exlist=get(handles.excluded,'string'); cols=[];
for i=1:length(exlist)
    Feature=exlist(i);
    cols(i)=find(strcmp(Feature,handles.Features));
end
X(:,cols)=[];
if isempty(X)
   return
end
%Standardize
if get(handles.standard,'Value')
    X=scaledata(X);
end
k=str2double(get(handles.k_clusters,'string'));
idx = kmeans(X,k,'display','off');
%plot
silhouette(X,idx)
axes(handles.clust_display); cla reset;
histogram(idx); xlim([min(idx)-1,max(idx)+1]);
xticks(unique(idx));
%save
handles.WormData.Cluster=idx;
WormData=handles.WormData;
save(fullfile(handles.inpath,handles.Filename), 'WormData');
guidata(hObject, handles);

function k_clusters_Callback(hObject, eventdata, handles)

function k_clusters_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% --- Executes on button press in SAVE_LABELS. %%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_labels_Callback(hObject, eventdata, handles)
if isfield(handles.UnlabeledWormData,'NewLabels')
    WormData=handles.UnlabeledWormData;
    save(fullfile(handles.Unlabeledinpath,handles.UnlabeledFilename), 'WormData');
end
guidata(hObject, handles);

function export_Callback(hObject, eventdata, handles)

% --- Executes on button press in save_fig.
function save_fig_Callback(hObject, eventdata, handles)
toBeSaved=getframe(handles.general_fig);
[fileName, filePath]=uiputfile([handles.inpath '*.bmp'], 'Save Image As...');
if strcmp(num2str(fileName),'0')
    return
end
fileName = fullfile(filePath, fileName);
imwrite(toBeSaved.cdata, fileName, 'bmp');


%% --- Executes on button press in back. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function back_ClickedCallback(hObject, eventdata, handles)
close all
WorMachine


%% HELP  ------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)

function about_Callback(hObject, eventdata, handles)
web('http://www.odedrechavilab.com/')

function manual_Callback(hObject, eventdata, handles)
open(['lib' handles.filesep 'WorMachine_Manual.pdf'])
