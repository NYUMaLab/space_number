function handle = figd(fontSize, lineWidth, markerSize)
% handle = figd(fontSize, lineWidth, markerSize)
%
% - creates a figure with default fontSize, lineWidth, and markerSize
% - if not specified, these are initialized to 15, 2, and 10 respectively


if ~exist('fontSize','var') || isempty(fontSize)
    fontSize = 20;
end

if ~exist('lineWidth','var') || isempty(lineWidth)
    lineWidth = 3;
end

if ~exist('markerSize','var') || isempty(markerSize)
    markerSize = 14;
end

handle = figure;
set(handle, 'DefaultAxesFontSize', fontSize);
set(handle, 'DefaultLineLineWidth', lineWidth);
set(handle, 'DefaultLineMarkerSize', markerSize);