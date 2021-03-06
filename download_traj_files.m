function good_float_ids = download_traj_files(float_ids)
% download_traj_files  This function is part of the
% MATLAB toolbox for accessing BGC Argo float data.
%
% USAGE:
%   good_float_ids = download_traj_files(float_ids)
%
% DESCRIPTION:
%   This function downloads the traj netcdf files for the floats with
%   the specified WMO IDs into subdirectory Traj. Extracting relevant
%   information from these files can be done outside the toolbox.
%
% INPUT:
%   float_ids : array with WMO IDs of the floats to be considered
%
% OUTPUT:
%   good_float_ids : WMO ID(s) of the float(s) whose traj files were downloaded
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
% DATE: MAY 26, 2022  (Version 1.3)

global Settings;

if nargin < 1
    warning('Usage: download_traj_files(float_ids)')
    return
end

% make sure Settings is initialized
if isempty(Settings)
    initialize_argo();
end

is_good = ones(length(float_ids), 1);
not_found = '';
count = 0;
for i = 1:length(float_ids)
    if ~download_float(float_ids(i), 'traj')
        is_good(i) = 0;
        not_found = sprintf('%s %d', not_found, float_ids(i));
        count = count + 1;
        % avoid too long lines in command window display
        if count == 10
            not_found = [not_found, newline];
            count = 0;
        end
    end
end
good_float_ids = float_ids(is_good == 1);
if ~isempty(not_found)
    fprintf('traj files could not be downloaded for floats:\n%s\n', ...
        not_found);
end
