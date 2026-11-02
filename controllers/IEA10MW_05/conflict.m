clearvars;clc
A = load('Statistics_FeedbackOnly','Statistics');      % DLC 1.2: 11 URef x 6 seeds, URef changes fastest
B = load('Statistics_OverspeedStudy','Statistics');    % study: 3 URef x 6 seeds x 4 scales

seeds   = 1:6;
rowA    = (seeds-1)*11 + 11;     % URef = 24 is the 11th wind speed (4:2:24)
rowB    = (seeds-1)*3  + 3;      % URef = 24 is the 3rd wind speed (20 22 24), GainScale = 1 is the first block
Compare = table(seeds', A.Statistics.Overshoot_GenSpeed(rowA), B.Statistics.Overshoot_GenSpeed(rowB), ...
    'VariableNames',{'Seed','DLC1p2','Study_Scale1'})