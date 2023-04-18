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

% Convert to mouse view (medial to lateral), for Daisy12 (right SNr) this
% is mid to right, where shank 1 is on the right, shank 4 is in the middle.
map = map(:, 4:-1:1);