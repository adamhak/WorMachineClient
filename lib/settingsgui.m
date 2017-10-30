function varargout = settingsgui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @settingsgui_OpeningFcn, ...
                   'gui_OutputFcn',  @settingsgui_OutputFcn, ...
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

% --- Executes just before settingsgui is made visible.
function settingsgui_OpeningFcn(hObject, eventdata, handles, varargin)
handles=opencofig(hObject, eventdata, handles);
handles.output = hObject;
guidata(hObject, handles);

function handles=opencofig(hObject, eventdata, handles)
[handles.names, handles.neighprecents, handles.thresholds, handles.pprecents]=textread('config.txt', ...
 '%s %f %f %f');
set(handles.all_settings,'String',handles.names);
set(handles.neighprecent,'String',handles.neighprecents(end));
set(handles.threshold,'String',handles.thresholds(end));
set(handles.pprecent,'String',handles.pprecents(end));
set(handles.all_settings,'Value',length(handles.names));
uicontrol(handles.all_settings);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = settingsgui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on button press in apply_settings.
function apply_settings_Callback(hObject, eventdata, handles)
h = findobj(allchild(0),'Tag','imageprocessor');
h2 = findobj('Tag','settings_gui');
custompreset=[str2double(get(handles.neighprecent,'String')) str2double(get(handles.threshold,'String')) str2double(get(handles.pprecent,'String'))];
guidata(hObject,handles);
if ~isempty(h)
    setappdata(h,'custompreset',custompreset);
end
ImageProcessorGUI()
h_handles = guidata(h);
set(h_handles.pprecent,'String',num2str(custompreset(3)));
set(h_handles.neighprecent,'String',num2str(custompreset(1)));
set(h_handles.threshold,'String',num2str(custompreset(2)));
close(h2)


%% Save settings to config file
function save_settings_Callback(hObject, eventdata, handles)
fileID = fopen('lib/config.txt','a+');
formatSpec='%s %d %d %d\n';    
name=get(handles.name,'String');
if isempty(name)
    name=datestr(datetime('now','TimeZone','local','Format','d-MMM-y_HH:mm:ss'));
    name(strfind(name,' '))='_';
end
fprintf(fileID,formatSpec,name,str2double(get(handles.neighprecent,'String')),...
    str2double(get(handles.threshold,'String')),str2double(get(handles.pprecent,'String')));
fclose(fileID);
handles=opencofig(hObject, eventdata, handles);
uicontrol(handles.all_settings);
set(handles.all_settings,'Value',length(handles.names));
guidata(hObject, handles);

% --- Executes when selected object changed in unitgroup.
function unitgroup_SelectionChangedFcn(hObject, eventdata, handles)


%% Settings List
function all_settings_Callback(hObject, eventdata, handles)
ind=get(handles.all_settings,'Value');
set(handles.neighprecent,'String',handles.neighprecents(ind));
set(handles.threshold,'String',handles.thresholds(ind));
set(handles.pprecent,'String',handles.pprecents(ind));
guidata(hObject, handles);



function all_settings_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Edit Boxes
function neighprecent_Callback(hObject, eventdata, handles)
neighprecent = str2double(get(hObject, 'String'));
if isnan(neighprecent)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

function neighprecent_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function threshold_Callback(hObject, eventdata, handles)
threshold = str2double(get(hObject, 'String'));
if isnan(threshold)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

function threshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pprecent_Callback(hObject, eventdata, handles)
pprecent = str2double(get(hObject, 'String'));
if isnan(pprecent)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

function pprecent_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function name_Callback(hObject, eventdata, handles)

function name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in delete.
function delete_Callback(hObject, eventdata, handles)
ind=get(handles.all_settings,'Value');
if ind==length(handles.names)
   set(handles.all_settings,'Value',ind-1)
end
if ind~=-1
    handles.neighprecents(ind)=[];
    handles.thresholds(ind)=[];
    handles.pprecents(ind)=[];
    handles.names(ind)=[];
    set(handles.all_settings,'String',handles.names)
end
uicontrol(handles.all_settings);
guidata(hObject, handles);
