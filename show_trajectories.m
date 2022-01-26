function good_float_ids = show_trajectories(float_ids,varargin)
% show_trajectories  This function is part of the
% MATLAB toolbox for accessing BGC Argo float data.
%
% USAGE:
%   show_trajectories(float_ids,varargin)
%
% DESCRIPTION:
%   This is an intermediary function that downloads profiles for at least
%   one given float and calls plot_trajectories to create the plot.
%
% INPUT:
%   float_ids : WMO ID(s) of one or more floats
%               (if not set: Settings.demo_float is used as a demo)
%
% OPTIONAL INPUTS:
%   'color',color : color (string) can be either 'multiple' (different
%                   colors for different floats), or any standard Matlab
%                   color descriptor ('r', 'k', 'b', 'g' etc.)
%                   (all trajectories will be plotted in the same color);
%                   default value is 'r' (red);
%                   if color is 'mode', the data mode of the given sensor
%                   is used to color the profiles (blue for R,
%                   yellow for A, green for D);
%                   color can also be 'dac'; in this case, the trajectories
%                   are colored by the DAC responsible for the floats
%                   (Both 'dac' and 'mode' color options are only implemented
%                   for Matlab-native trajectory plots, not m_map or plain.)
%   'float_profs',fp : fp is an array with the per-float indices of the
%                   selected profiles, as returned by function
%                   select_profiles - use this optional argument if you
%                   don't want to plot the full trajectories of the
%                   given floats, but only those locations that match
%                   spatial and/or temporal constraints
%   'interp_lonlat', intp : if intp is 'yes' (default), missing lon/lat
%                   values (typically under ice) will be interpolated;
%                   set intp to 'no' to suppress interpolation
%   'mark_estim',mark: if mark is 'yes', show estimated locations in
%                   light gray (set by Settings.color_estim_loc);
%                   if 'no' (default) use the same color for known and
%                   estimated locations
%   'position', pos: show only the selected position (either 'first' or
%                   'last')
%   'png',fn_png  : save the plot to a png file with the given
%                   file name (fn_png)
%   'sensor',sensor: name of the sensor to use for coloring by data mode -
%                   this option is ignored if color is not 'mode'
%   'title',title : title for the plot (default: "Float trajectories")
%   'lines',lines : lines (string) can be 'yes' to connect float positions
%                   with a line or 'no' (default)
%   'legend',legend: legend (string) can be 'yes' to show legend along with
%                   plot (default) or 'no'
%   'size',sz     : sz (positive integer) defines the size of plotted
%                   points (default: 36)
%
% OUTPUT:
%   good_float_ids : array of the float IDs whose Sprof files were
%                    successfully downloaded or existed already
%
% AUTHORS:
%   H. Frenzel, J. Sharp, A. Fassbender (NOAA-PMEL), N. Buzby (UW),
%   J. Plant, T. Maurer, Y. Takeshita (MBARI), D. Nicholson (WHOI),
%   and A. Gray (UW)
%
% CITATION:
%   H. Frenzel*, J. Sharp*, A. Fassbender, N. Buzby, J. Plant, T. Maurer,
%   Y. Takeshita, D. Nicholson, A. Gray, 2021. BGC-Argo-Mat: A MATLAB
%   toolbox for accessing and visualizing Biogeochemical Argo data.
%   Zenodo. https://doi.org/10.5281/zenodo.4971318.
%   (*These authors contributed equally to the code.)
%
% LICENSE: bgc_argo_mat_license.m
%
% DATE: DECEMBER 1, 2021  (Version 1.1)

global Settings;

% make sure Settings is initialized
if isempty(Settings)
    initialize_argo();
end

if ~nargin
    float_ids = Settings.demo_float;
end

% set defaults
color = 'r'; % red
float_profs = [];
pos = [];
fn_png = [];
title = 'Float trajectories';
lines = 'no';
lgnd = 'yes';
sz = 36;
mark_estim = 'no';
interp_lonlat = 'yes';
sensor = [];

% parse optional arguments
for i = 1:2:length(varargin)-1
    if strcmpi(varargin{i}, 'color')
        color = varargin{i+1};
    elseif strcmpi(varargin{i}, 'float_profs')
        float_profs = varargin{i+1};
    elseif strcmpi(varargin{i}, 'position')
        pos = varargin{i+1};
    elseif strcmpi(varargin{i}, 'png')
        fn_png = varargin{i+1};
    elseif strcmpi(varargin{i}, 'title')
        title = varargin{i+1};
    elseif strcmpi(varargin{i}, 'lines')
        lines = varargin{i+1};
    elseif strcmpi(varargin{i}, 'legend')
        lgnd = varargin{i+1};
    elseif strcmpi(varargin{i}, 'size')
        if round(varargin{i+1}) > 0
            sz = round(varargin{i+1});
        else
            warning('size must be a positive integer')
        end
    elseif strcmpi(varargin{i}, 'mark_estim')
        mark_estim = varargin{i+1};
    elseif strcmpi(varargin{i}, 'interp_lonlat')
        interp_lonlat = varargin{i+1};
    elseif strcmpi(varargin{i}, 'sensor')
        sensor = varargin{i+1};
    else
        warning('unknown option: %s', varargin{i});
    end
end

if strcmp(color, 'mode') && isempty(sensor)
    warning('sensor must be specified for "mode" colors')
    return;
end

% download Sprof files if necessary
good_float_ids = download_multi_floats(float_ids);

if isempty(good_float_ids)
    warning('no valid floats found')
else
    % meta data return values and observations are not needed here
    Data = load_float_data(good_float_ids, sensor, float_profs, ...
        'interp_lonlat', interp_lonlat);
    if ~isempty(pos)
        floats = fieldnames(Data);
        nfloats = length(floats);
        if strcmp(pos, 'first')
            for f = 1:nfloats
                % only lon/lat fields are used by plot_trajectories
                Data.(floats{f}).LONGITUDE = ...
                    Data.(floats{f}).LONGITUDE(:,1);
                Data.(floats{f}).LATITUDE = ...
                    Data.(floats{f}).LATITUDE(:,1);
            end
        elseif strcmp(pos, 'last')
            for f = 1:nfloats
                Data.(floats{f}).LONGITUDE = ...
                    Data.(floats{f}).LONGITUDE(:,end);
                Data.(floats{f}).LATITUDE = ...
                    Data.(floats{f}).LATITUDE(:,end);
            end
        end
    end
    plot_trajectories(Data, color, title, fn_png, float_ids, lines, ...
        lgnd, sz, mark_estim, sensor);
end
