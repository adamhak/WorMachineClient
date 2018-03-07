function varargout = WorMachine(varargin)
% WORMACHINE MATLAB code for WorMachine.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WorMachine_OpeningFcn, ...
                   'gui_OutputFcn',  @WorMachine_OutputFcn, ...
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


% --- Executes just before WorMachine is made visible.
function WorMachine_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

clc
addpath(genpath('lib'));
[PATHSTR,~,~]=fileparts((which(mfilename)));
cd(PATHSTR);
handles.logo=imread('lib\WMlogo.png');
axes(handles.axes1); imshow(handles.logo);
k=get(gcf,'color');
set(gcf,'color','w')

guidata(hObject, handles);

% UIWAIT makes WorMachine wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WorMachine_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
close all
ImageProcessorGUI


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
close all
FeaturesGUI

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
close all
LearnerGUI
