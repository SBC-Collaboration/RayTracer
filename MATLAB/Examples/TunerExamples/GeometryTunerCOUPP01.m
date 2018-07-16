
function GeometryTunerCOUPP01()


%% platform dependent rescalings
if ispc
    edit_rescale = [1 1];
    fig_rescale = [1 1];
elseif ismac
    edit_rescale = [1 1.4];
    fig_rescale = [1.9 1.2];
else
    edit_rescale = [1 (get(0,'ScreenPixelsPerInch')/75)];
    fig_rescale = [1.75 (get(0,'ScreenPixelsPerInch')/75)];
end

%% build control figure
initial_figpos = [50 75 675 550];
initial_figsize = repmat(initial_figpos(3:4),1,2);
position_scale = 1./initial_figsize;

initial_figpos = initial_figpos .* [1 1 fig_rescale];

figdata = struct();
figdata.main = figure('Visible','on','Position',initial_figpos);
set(figdata.main, ...
    'Name','COUPP4kg Geometry Tuner (Control)', ...
    'MenuBar','none', ...
    'KeyPressFcn', @GTC2L_main_keyhit, ...
    'ToolBar','none');

%% add buttons to control figure
figdata.uihandles.buttons.display = uicontrol(figdata.main, ...
    'Style','pushbutton', ...
    'FontUnits','normalized', ...
    'Units','normalized', ...
    'String',sprintf('Update Display (space-bar)'), ...
    'TooltipString','Click or tap space bar to display current geometry setup', ...
    'Position',position_scale .* [560 470 100 35], ...
    'Callback',@GTC2L_update_display_button);


maskmode_list = {'none','small','all'};
figdata.uihandles.buttons.mask = zeros(1,3);
radiostrings = {'None','Regions of Interest','Full'};
for n=1:3
    figdata.uihandles.buttons.mask(n) = uicontrol(figdata.main, ...
        'Style','radiobutton', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'Min',0, ...
        'Max',n, ...
        'Value',n==1, ...
        'String',radiostrings{n}, ...
        'TooltipString','Only front fiducial marks reconstructed', ...
        'Position',position_scale .* [465 505-n*15 80 15], ...
        'Callback',@GTC2L_maskradio);
end

figdata.uihandles.buttons.masklabel = uicontrol(figdata.main, ...
    'Style','text', ...
    'FontUnits','normalized', ...
    'Units','normalized', ...
    'String','Ray Tracer Output Mask', ...
    'Position',position_scale .* [465 505 80 15]);

%% add background image specs to control figure
figdata.uihandles.images.datadir = uicontrol(figdata.main, ...
        'Style','edit', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'String', '  /bluearc/storage/COUPP01-Jan2013', ...
        'Position',position_scale .* [300 498 110 15], ...
        'HorizontalAlignment','left', ...
        'UserData', '/bluearc/storage/COUPP01-Jan2013', ...
        'TooltipString','Path containing run directories', ...
        'Callback',@GTC2L_datadir);

figdata.uihandles.images.runID = uicontrol(figdata.main, ...
        'Style','edit', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'String', '20130108_1  ', ...
        'Position',position_scale .* [300 473 50 15], ...
        'HorizontalAlignment','right', ...
        'UserData', [20130108, 1], ...
        'TooltipString','e.g. 20101129_3', ...
        'Callback',@GTC2L_runID);

figdata.uihandles.images.ev = uicontrol(figdata.main, ...
        'Style','edit', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'String', '0  ', ...
        'Position',position_scale .* [355 473 30 15], ...
        'HorizontalAlignment','right', ...
        'UserData', 0, ...
        'TooltipString','Event number', ...
        'Callback',@GTC2L_intedit);

figdata.uihandles.images.frame = uicontrol(figdata.main, ...
        'Style','edit', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'String', '5  ', ...
        'Position',position_scale .* [390 473 20 15], ...
        'HorizontalAlignment','right', ...
        'UserData', 5, ...
        'TooltipString','Frame number', ...
        'Callback',@GTC2L_intedit);

figdata.uihandles.images.dirlabel = uicontrol(figdata.main, ...
        'Style','text', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'String', 'Data Directory  ', ...
        'Position',position_scale .* [235 501 60 15], ...
        'HorizontalAlignment','right', ...
        'TooltipString','Frame number');
figdata.uihandles.images.evlabel = uicontrol(figdata.main, ...
        'Style','text', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'String', 'runID, event, frame  ', ...
        'Position',position_scale .* [235 476 60 15], ...
        'HorizontalAlignment','right', ...
        'TooltipString','Frame number');
    
    
%% add geospecs to control figure
geospec_list = { ...
    'n_CF3I', 'n_H2O', 'n_quartz', 'n_glycol', 'n_air', 'n_glass', ...
    'cf3i_mass', 'cf3i_density', ...
    'cam_f', 'cam_barreld', ...
    'cam_x', 'cam_y', 'cam_z', ...
    'cam_pitch', 'cam_yaw', 'cam_roll' ...
    'jar_cylrad', 'jar_axrad', 'jar_cylthick', 'jar_axthick', ...
    'bath_rad', 'plexi_thickness', ...
    };

geospec_tooltip = cell(size(geospec_list));
geospec_tooltip(1:6) = {'Index of refraction'};
geospec_tooltip(7) = {'CF3I mass (grams)'};
geospec_tooltip(8) = {'CF3I density (g/cc)'};
geospec_tooltip(9:10) = {'Focal length (cm)'};
geospec_tooltip(11:12) = {'Radial quadratic distortion coefficient'};
geospec_tooltip(13:18) = {'Camera position (cm): (x=0, z=0) at hemisphere center, y=0 at airside of window, +z is up, +y is toward jar'};
geospec_tooltip(19:24) = {'Camera rotation (degrees): roll about +y, then pitch about +x, then yaw about +z'};
geospec_tooltip(25) = {'Jar cylinder outer radius (cm)'};
geospec_tooltip(26) = {'Jar hemisphere outer vertical radius (cm)'};
geospec_tooltip(27) = {'Jar wall thickness in cylinder (cm)'};
geospec_tooltip(28) = {'Jar wall thickness at hemisphere apex (cm)'};
geospec_tooltip(29:31) = {'Jar rotation (degrees): roll about +z, then pitch about +x, then yaw about +z'};
geospec_tooltip(32) = {'Window position (cm): glycol-glass interface, y=0 at hemisphere center, +y away from cameras'};
geospec_tooltip(33) = {'Window thickness (cm)'};
geospec_tooltip(34:35) = {'Fiducial mark z (cm), z=0 at hemisphere apex'};
geospec_tooltip(36) = {'Distance along circumference to back fiducial marks (cm)'};
geospec_tooltip(37) = {'Fiducial mark cross size (center to edge, cm)'};
geospec_tooltip(38) = {'Fiducial mark pen size (half width, cm)'};
geospec_tooltip(39) = {'Cylinder wall test point z (z=0 at hemisphere center, cm)'};
geospec_tooltip(40) = {'Cylinder wall test point phi (phi = 0 towards camera, degrees)'};
geospec_tooltip(41) = {'Hemisphere wall test point z (z=0 at hemisphere center, cm)'};
geospec_tooltip(42) = {'Hemisphere wall test point phi (phi = 0 towards camera, degrees)'};
geospec_tooltip(43) = {'Wall test point spot radius (cm)'};

geospec_formatstring = cell(size(geospec_list));
geospec_formatstring([1:6 8:18 25:28 32:39 41 43]) = {'%.3f  '};
geospec_formatstring(7) = {'%.1f  '};
geospec_formatstring([19:24 29:31 40 42]) = {'%.1f  '};

geospec_defaults = [ ...
    1.20, 1.33, 1.458, 1.33, 1.00, 1.491, ...
    24, 1.38, ...
    1.12, 0.0, ...
    0, -25.527, .6477, ...
    3.4, 0, 0, ...
    2.1463, 2.1463, .9779, .9779, ...
    10.668, 0.762];

geospec_min = [ ...
    1, 1, 1, 1, 1, 1, ...
    0, 1, ...
    0, -10, ...
    -10, -35, -10, ...
    -45, -45, -45, ...
    0, 0, 0, 0, ...
    0, 0];

geospec_max = [ ...
    2, 2, 2, 2, 2, 2, ...
    5000, 3, ...
    2, 10, ...
    10, -15, 20, ...
    45, 45, 45, ...
    10, 10, 2, 2, ...
    20, 5];

geospec_xpos = [ ...
    50, 50, 50, 50, 50, 50, ...
    50, 50, ...
    275, 275, ...
    50, 50, 50, ...
    500, 500, 500, ...
    50, 50, 275, 275, ...
    50, 275];

geospec_ypos = [ ...
    500, 475, 450, 425, 400, 375, ...
    325, 300, ...
    250, 175, ...
    250, 225, 200, ...
    250, 225, 200, ...
    75, 50, 75, 50, ...
    25, 25];



for gsn=1:length(geospec_list)
    figdata.uihandles.geospecs.(geospec_list{gsn}).slider = uicontrol(figdata.main, ...
        'Style','slider', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'Value',geospec_defaults(gsn), ...
        'Min',geospec_min(gsn), ...
        'Max',geospec_max(gsn), ...
        'SliderStep',(10^(floor(log10(geospec_max(gsn)-geospec_min(gsn)))) * [.01 .1]) / (geospec_max(gsn)-geospec_min(gsn)), ...
        'Position',position_scale .* [geospec_xpos(gsn) geospec_ypos(gsn) 100 15], ...
        'HorizontalAlignment','right', ...
        'UserData', gsn, ...
        'TooltipString',geospec_tooltip{gsn}, ...
        'Callback',@GTC2L_geospec_slider);
    figdata.uihandles.geospecs.(geospec_list{gsn}).edit = uicontrol(figdata.main, ...
        'Style','edit', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'String', sprintf(geospec_formatstring{gsn},geospec_defaults(gsn)), ...
        'Position',position_scale .* [geospec_xpos(gsn)-40 geospec_ypos(gsn)-2 40 15], ...
        'HorizontalAlignment','right', ...
        'UserData', gsn, ...
        'TooltipString',geospec_tooltip{gsn}, ...
        'Callback',@GTC2L_geospec_edit);
    figdata.uihandles.geospecs.(geospec_list{gsn}).text = uicontrol(figdata.main, ...
        'Style','text', ...
        'FontUnits','normalized', ...
        'Units','normalized', ...
        'String', geospec_list{gsn}, ...
        'Position',position_scale .* [geospec_xpos(gsn)+100 geospec_ypos(gsn)+1 65 15], ...
        'HorizontalAlignment','left', ...
        'TooltipString',geospec_tooltip{gsn});
end
    
%% resize edit fields
edit_handles = findobj('parent',figdata.main,'type','uicontrol','style','edit');
set(edit_handles,'fontunits','points');
for ehn=1:length(edit_handles)
    set(edit_handles(ehn), 'position', ...
        get(edit_handles(ehn), 'position') .* [1 1 edit_rescale]);
end
set(edit_handles,'fontunits','normalized');

%% build display structure
figdata.display.fignum = 0;
figdata.display.axes = zeros(2,1);
figdata.display.lines = zeros(2,3);
figdata.display.images = zeros(2,1);

%% add some other fields
figdata.geospecs_changed = true;
figdata.imagedata_changed = true;
figdata.geospec_formatstring = geospec_formatstring;
figdata.geospec_list = geospec_list;
figdata.mask_ix = 1;
figdata.maskmode_list = maskmode_list;

%% store guidata
guidata(figdata.main, figdata);

%% all done
return


%% callback functions
function GTC2L_main_keyhit(varargin)
source = varargin{1};
evtdata = varargin{2};
switch evtdata.Key
    case 'space'
        GTC2L_update_display(source);
    case 'w'
        if length(evtdata.Modifier)==1 && strcmp(evtdata.Modifier{1},'command')
            close(source);
        end
end
return

function GTC2L_update_display_button(varargin)
source = varargin{1};
GTC2L_update_display(source);
return

function GTC2L_update_display(varargin)
source = varargin{1};
GTC2L_update_image(source);
GTC2L_update_sim(source);
figdata = guidata(source);
if ishandle(figdata.display.fignum) && ...
        strcmp(get(figdata.display.fignum, 'type'), 'figure')
    figure(figdata.display.fignum);
end
guidata(source,figdata);
return

function GTC2L_update_image(varargin)
source = varargin{1};
figdata = guidata(source);
if ishandle(figdata.display.fignum) && ...
        strcmp(get(figdata.display.fignum, 'type'), 'figure')
    figure(figdata.display.fignum);
else
    figdata.display.fignum = figure;
    set(figdata.display.fignum, 'position', [50 75 1400 805]);
    figdata.display.axes(1) = subplot(1,2,1);
    figdata.display.axes(2) = subplot(1,2,2);
    figdata.imagedata_changed = true;
    figdata.geospecs_changed = true;
end
if figdata.imagedata_changed
    old_images = figdata.display.images;
    old_images = old_images(ishandle(old_images));
    old_images = old_images(strcmp(get(old_images,'type'), 'image'));
    delete(old_images);
    datadir = get(figdata.uihandles.images.datadir,'UserData');
    runID = get(figdata.uihandles.images.runID,'UserData');
    ev = get(figdata.uihandles.images.ev,'UserData');
    framenum = get(figdata.uihandles.images.frame,'UserData');
    image0 = imread([datadir filesep sprintf('%d_%d',runID(1),runID(2)) filesep sprintf('%d',ev) filesep sprintf('cam0image%3d.bmp',framenum)]);
    image1 = imread([datadir filesep sprintf('%d_%d',runID(1),runID(2)) filesep sprintf('%d',ev) filesep sprintf('cam1image%3d.bmp',framenum)]);
    axes(figdata.display.axes(1));
    if length(size(image1))==2
        image(repmat(image1,[1,1,3]));
    else
        image(image1);
    end
    hold on;
    axes(figdata.display.axes(2));
    if length(size(image0))==2
        image(repmat(image0,[1 1 3]));
    else
        image(image0);
    end
    hold on;
    for c=1:2
        for l=1:3
            if ishandle(figdata.display.lines(c,l)) && strcmp(get(figdata.display.lines(c,l),'type'),'line')
                old_handle = figdata.display.lines(c,l);
                figdata.display.lines(c,l) = copyobj(old_handle, figdata.display.axes(c));
                delete(old_handle);
            end
        end
    end
    figdata.imagedata_changed = false;
end
guidata(source,figdata);
return

function GTC2L_update_sim(varargin)
source = varargin{1};
figdata = guidata(source);
if ishandle(figdata.display.fignum) && ...
        strcmp(get(figdata.display.fignum, 'type'), 'figure')
    figure(figdata.display.fignum);
else
    figdata.display.fignum = figure;
    set(figdata.display.fignum, 'position', [50 75 600 800]);
    figdata.display.axes(1) = subplot(1,2,1);
    figdata.display.axes(2) = subplot(1,2,2);
    figdata.imagedata_changed = true;
    figdata.geospecs_changed = true;
end
if figdata.geospecs_changed
    old_lines = figdata.display.lines;
    old_lines = old_lines(ishandle(old_lines));
    old_lines = old_lines(strcmp(get(old_lines,'type'),'line'));
    delete(old_lines);
    geospecs = struct();
%     geospecs.lens_type = 'theta';
    for n=1:length(figdata.geospec_list)
        geospecs.(figdata.geospec_list{n}) = ...
            get(figdata.uihandles.geospecs.(figdata.geospec_list{n}).slider, 'Value');
    end
    figdata.display.lines = OpticReconCOUPP01(geospecs, [], figdata.display.axes, figdata.maskmode_list{figdata.mask_ix});
    figdata.geospecs_changed = false;
end
guidata(source,figdata);
return

function GTC2L_intedit(varargin)
source = varargin{1};
figdata = guidata(source);
newval = str2double(get(source, 'string'));
newval = max(fix(newval),0);
set(source, 'UserData', newval, 'string', sprintf('%d  ', newval));
figdata.imagedata_changed = true;
guidata(source,figdata);
return

function GTC2L_runID(varargin)
source = varargin{1};
figdata = guidata(source);
newstr = get(source, 'string');
toks = regexp(newstr,'(\d+)_(\d+)','tokens');
if isempty(toks)
    newval = get(source, 'UserData');
else
    newval = [str2double(toks{1}{1}), str2double(toks{1}{2})];
end
set(source, 'UserData', newval, 'string', sprintf('%d_%d  ', newval(1),newval(2)));
figdata.imagedata_changed = true;
guidata(source,figdata);
return

function GTC2L_datadir(varargin)
source = varargin{1};
figdata = guidata(source);
newstr = get(source, 'string');
toks = regexp(newstr,'^\s*(\S.*)$','tokens');
if ~isempty(toks) && exist(toks{1}{1},'dir')
    newval = toks{1}{1};
else
    newval = char(get(source, 'UserData'));
end
set(source, 'UserData', newval, 'string', sprintf('  %s', newval));
figdata.imagedata_changed = true;
guidata(source,figdata);
return

function GTC2L_geospec_slider(varargin)
source = varargin{1};
figdata = guidata(source);
specnum = get(source,'UserData');
newval = get(source,'Value');
set(figdata.uihandles.geospecs.(figdata.geospec_list{specnum}).edit, 'String', ...
    sprintf(figdata.geospec_formatstring{specnum}, newval));
figdata.geospecs_changed = true;
guidata(source,figdata);
return

function GTC2L_geospec_edit(varargin)
source = varargin{1};
figdata = guidata(source);
specnum = get(source,'UserData');
newval = str2double(get(source, 'string'));
oldval = get(figdata.uihandles.geospecs.(figdata.geospec_list{specnum}).slider, 'Value');
if ~isnan(newval)
    newval = min(newval, get(figdata.uihandles.geospecs.(figdata.geospec_list{specnum}).slider, 'Max'));
    newval = max(newval, get(figdata.uihandles.geospecs.(figdata.geospec_list{specnum}).slider, 'Min'));
    if newval~=oldval
        figdata.geospecs_changed = true;
        set(figdata.uihandles.geospecs.(figdata.geospec_list{specnum}).slider, 'Value', newval);
    end
    set(source, 'string', sprintf(figdata.geospec_formatstring{specnum}, newval));
else
    set(source, 'string', sprintf(figdata.geospec_formatstring{specnum}, oldval));
end
guidata(source,figdata);
return

function GTC2L_maskradio(varargin)
source = varargin{1};
figdata = guidata(source);
thisradio = get(source,'Max');
if get(source,'Value')==0
    set(source,'Value',thisradio);
else
    set(figdata.uihandles.buttons.mask(figdata.mask_ix), 'Value', 0);
    if thisradio > figdata.mask_ix
        figdata.geospecs_changed = true;
    end
    figdata.mask_ix = thisradio;
end
guidata(source,figdata);
return
