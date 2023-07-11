function [w, window_idxs, window_idx] = binContinuous(an, events,win)
% function [w, widxs, widx] = binContinuous(an,ev,win)
%
% Bin sampled signal
%
% Args:
%   an: continuous signal from which to draw samples
%   ev: trigger indices
%   win: min and max time window

% Make an is a column vector!!
if size(an,1) < size(an,2)
    an=an';
end

window_idx = win(1):win(2);

% ev(isnan(ev)) = []; % remove impossible spikes
% ev(ev > size(an,1)) = [];

window_idxs = bsxfun(@plus, events(:), window_idx);
window_idxs(window_idxs(:,1) <= 0,:) = nan; % ignore very early spikes
window_idxs(window_idxs > size(an,1)) = nan;
% widxs(widxs(:,end) > size(an,1),:) = nan; % ignore very late spikes

w = nan(size(window_idxs));

w(~isnan(window_idxs)) = an(window_idxs(~isnan(window_idxs)));