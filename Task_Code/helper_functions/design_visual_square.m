function [ visParadigm ] = design_visual_square( nTrials, pVis, meanSOT )
%DESIGN_VISUAL_SQUARE Generates a sequence of visual stimuli for aMMN
%   Given the number of auditory trials, the probability of a visual
%   stimulus, this function returns a sequence of visual events
%   (vis) and a sequence of stimulus onset times (sot) for these events.

sot = NaN(1, nTrials);

%nVis = round(nTrials * pVis);
%nSide = round(nVis/2);
nSide = round(nTrials * pVis);
nVis = nSide * 2;

visO = [repmat(2, 1, nSide) ones(1, nSide) zeros(1, nTrials - nVis)];
vis = visO(randperm(length(visO)));

minDiff = 1;
while minDiff < 4
    vis = vis(randperm(length(vis)));
    minDiff = check_minimal_difference(vis);
end

% SOT (in ms) is counted from the end of the auditory stimulus presentation
% plus 50 ms (i.e., 150 ms in-trial)

rangeSOT = 200;

for i = 1: nTrials
    sot(i) = rand * rangeSOT - rangeSOT/2 + meanSOT;
end

visParadigm.vis = vis;
visParadigm.sot = sot;

end

function minDiff = check_minimal_difference(vis)

visIdx = find(vis);
idxDiff = diff(visIdx);
minDiff = min(idxDiff);

end
