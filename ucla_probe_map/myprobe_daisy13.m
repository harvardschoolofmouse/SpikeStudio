probe_128D_bottom

% Probe view: Left to right, top to bottom, viewing from the front
map = zeros(32, 4);
for iShaft = 1:4
    inShaft = s.shaft == iShaft;
    [~, I] = sort(s.z(inShaft), 'descend');
    channels = find(inShaft);
    channels = channels(I);
    map(:, iShaft) = channels;
end
clear inShaft iShaft channels

% Convert to mouse view (medial to lateral), for Daisy13 (left SNr) this
% is mid to left, where shank 1 is most medial, shank 4 is lateral.
map = map(:, 1:4);